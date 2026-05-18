<?php
require 'vendor/autoload.php';
require 'stripe_auth.php';
require_once "conexion.php";

date_default_timezone_set("America/Lima");

// Cargar .env
$dotenv = Dotenv\Dotenv::createImmutable(__DIR__);
$dotenv->load();

// Definir secret según entorno
$apihook = $_ENV["TEST"] === "SI" ? $_ENV['STRIPE_SECRET_HOOK_TEST'] : $_ENV['STRIPE_SECRET_HOOK'];

// Leer payload y firma
$payload = @file_get_contents('php://input');
$sig_header = $_SERVER['HTTP_STRIPE_SIGNATURE'] ?? '';
$endpoint_secret = $apihook;

try {
    // Validar evento Stripe
    $event = \Stripe\Webhook::constructEvent($payload, $sig_header, $endpoint_secret);
    file_put_contents('webhook_debug.txt', date('Y-m-d H:i:s') . " - ⚡ Evento Stripe recibido: {$event->type}\n", FILE_APPEND);
} catch (\UnexpectedValueException $e) {
    http_response_code(400);
    file_put_contents('webhook_debug.txt', date('Y-m-d H:i:s') . " - ❌ Payload inválido: " . $e->getMessage() . "\n", FILE_APPEND);
    exit();
} catch (\Stripe\Exception\SignatureVerificationException $e) {
    http_response_code(400);
    file_put_contents('webhook_debug.txt', date('Y-m-d H:i:s') . " - ❌ Firma inválida: " . $e->getMessage() . "\n", FILE_APPEND);
    exit();
}

try {
    $paymentIntent = $event->data->object;
    $idPagoStripe = $paymentIntent->id;
    $stripe_charge_id = $paymentIntent->charges->data[0]->id ?? null;
    $monto = $paymentIntent->amount / 100;
    $moneda = $paymentIntent->currency;
    $estadoStripe = $paymentIntent->status;
    $metodo = $paymentIntent->payment_method_types[0] ?? 'desconocido';

    file_put_contents('webhook_debug.txt', date('Y-m-d H:i:s') . " - Procesando pago Stripe: $idPagoStripe\n", FILE_APPEND);

    // Buscar pago local
    $stmt = $pdo->prepare("SELECT id FROM pagos WHERE stripe_payment_intent_id = ?");
    $stmt->execute([$idPagoStripe]);
    $idPagoLocal = $stmt->fetchColumn();

    if (!$idPagoLocal) {
        file_put_contents('webhook_debug.txt', date('Y-m-d H:i:s') . " - ⚠️ No se encontró registro local para $idPagoStripe\n", FILE_APPEND);
        http_response_code(200);
        exit();
    }

    file_put_contents('webhook_debug.txt', date('Y-m-d H:i:s') . " - Pago local encontrado: $idPagoLocal\n", FILE_APPEND);

    // Determinar estado local
    $estadoLocal = ($event->type === 'payment_intent.succeeded') ? 'exitoso' : 'fallido';
    $estadoAsignacion = ($event->type === 'payment_intent.succeeded') ? 'exitoso' : 'fallido';

    // Actualizar tabla pagos
    $stmt = $pdo->prepare("
        UPDATE pagos
        SET estado = ?, stripe_charge_id = ?, metodo_pago = ?, fecha_pago = NOW()
        WHERE stripe_payment_intent_id = ?
    ");
    $stmt->execute([$estadoLocal, $stripe_charge_id, $metodo, $idPagoStripe]);
    file_put_contents('webhook_debug.txt', date('Y-m-d H:i:s') . " - Tabla pagos actualizada\n", FILE_APPEND);

    // Actualizar tabla asignaciones_pagos
    $stmt = $pdo->prepare("
        UPDATE asignaciones_pagos
        SET estado = ?, metodo_pago = ?
        WHERE pago_id = ?
    ");
    $stmt->execute([$estadoAsignacion, $metodo, $idPagoLocal]);
    file_put_contents('webhook_debug.txt', date('Y-m-d H:i:s') . " - Tabla asignaciones_pagos actualizada\n", FILE_APPEND);

    // Obtener datos de asignación
    $stmt = $pdo->prepare("SELECT * FROM asignaciones_pagos WHERE pago_id = ? LIMIT 1");
    $stmt->execute([$idPagoLocal]);
    $rows = $stmt->fetch(PDO::FETCH_ASSOC);
    $cliente_id = $rows["usuario_id"];
    $fecha_pago = date("Y-m-d");

    // Obtener días de vigencia del plan
    $stmt = $pdo->prepare("SELECT * FROM promociones WHERE titulo = ? LIMIT 1");
    $stmt->execute([$rows["descripcion_plan"]]);
    $plan = $stmt->fetch(PDO::FETCH_ASSOC);
    $diasvigencia = $plan["dias_vigencia"] ?? 1;

    // Calcular fecha de recordatorio
    $fechaRecordatorio = new DateTime($fecha_pago);
    $fechaRecordatorio->modify('+' . ($diasvigencia - 2) . ' days');
    $fecha_recordatorio = $fechaRecordatorio->format("Y-m-d");

    // Insertar recordatorio
    $stmt = $pdo->prepare("
        INSERT INTO recordatorios (cliente_id, fecha_pago, fecha_recordatorio, estado)
        VALUES (:cliente_id, :fecha_pago, :fecha_recordatorio, :estado)
    ");
    $stmt->execute([
        ':cliente_id' => $cliente_id,
        ':fecha_pago' => $fecha_pago,
        ':fecha_recordatorio' => $fecha_recordatorio,
        ':estado' => 'activo'
    ]);
    file_put_contents('webhook_debug.txt', date('Y-m-d H:i:s') . " - Recordatorio creado para cliente $cliente_id\n", FILE_APPEND);

    // Actualizar estado del cliente
    cambiar_estado_Cliente($cliente_id);

    // Log final
    file_put_contents('webhook_debug.txt', date('Y-m-d H:i:s') . " - ✅ Webhook procesado correctamente | Stripe: $idPagoStripe | Local: $idPagoLocal | Estado: $estadoLocal | Monto: $monto $moneda\n", FILE_APPEND);

    http_response_code(200);

} catch (PDOException $e) {
    file_put_contents('webhook_debug.txt', date('Y-m-d H:i:s') . " - ❌ PDO Exception: " . $e->getMessage() . "\n", FILE_APPEND);
    http_response_code(500);
    exit();
} catch (Exception $e) {
    file_put_contents('webhook_debug.txt', date('Y-m-d H:i:s') . " - ❌ General Exception: " . $e->getMessage() . "\n", FILE_APPEND);
    http_response_code(500);
    exit();
}

// Función para cambiar estado del cliente
function cambiar_estado_Cliente($id)
{
    global $pdo;

    try {
        $stmt = $pdo->prepare("SELECT estado FROM usuarios WHERE id = ? LIMIT 1");
        $stmt->execute([$id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$row) {
            file_put_contents('webhook_debug.txt', date('Y-m-d H:i:s') . " - ⚠️ Usuario $id no encontrado\n", FILE_APPEND);
            return;
        }

        $nuevoEstado = "ACTIVO";
        $stmt = $pdo->prepare("UPDATE usuarios SET estado = ? WHERE id = ?");
        $stmt->execute([$nuevoEstado, $id]);
        file_put_contents('webhook_debug.txt', date('Y-m-d H:i:s') . " - Usuario $id actualizado a ACTIVO\n", FILE_APPEND);
    } catch (Exception $e) {
        file_put_contents('webhook_debug.txt', date('Y-m-d H:i:s') . " - ❌ Error actualizar usuario $id: " . $e->getMessage() . "\n", FILE_APPEND);
    }
}

exit();
