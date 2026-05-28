<?php

set_error_handler(function ($severity, $message, $file, $line) {
    throw new ErrorException($message, 0, $severity, $file, $line);
});
include_once("conexion.php");
$sql = "SELECT * FROM configuraciones LIMIT 1";
$stmt = $pdo->prepare($sql);
$stmt->execute();
$row = $stmt->fetch(PDO::FETCH_ASSOC);
$MONEDA = $row["moneda"] ?? "";
try {
    require 'vendor/autoload.php';
    require_once('flow_auth.php');

    $montoStripe = floatval($_POST['monto']) * 100;
    $moneda = $MONEDA ?? 'mxn';
    $descripcion = $_POST['promocion'] ?? 'Plan asignado';
    $usuario_id = $_POST['usuario_id'];
    $tienePagoPendiente = $pdo->prepare("
    SELECT id FROM pagos WHERE usuario_id = :usuario_id AND estado = 'pendiente' LIMIT 1
");
    $tienePagoPendiente->execute([':usuario_id' => $usuario_id]);
    $pagoExistente = $tienePagoPendiente->fetch(PDO::FETCH_ASSOC);

    if ($pagoExistente) {
        jsonError("El usuario ya tiene un pago pendiente (ID: {$pagoExistente['id']}).");
        exit;
    }

    // Crear PaymentIntent
    $paymentIntent = \Stripe\PaymentIntent::create([
        'amount' => $montoStripe,
        'currency' => $moneda,
        'description' => $descripcion,
        'automatic_payment_methods' => [
            'enabled' => true,
        ],
    ]);

    // Guardar en tabla pagos
    $stmt = $pdo->prepare("
        INSERT INTO pagos (usuario_id, stripe_payment_intent_id, monto, moneda, descripcion, estado, fecha_pago) 
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ");
    $stmt->execute([
        $usuario_id,
        $paymentIntent->id,
        $_POST['monto'],
        $moneda,
        $descripcion,
        'pendiente',
        null
    ]);

    $ultimoPagoId = $pdo->lastInsertId();

    // Asignar la promoción al usuario
    $stmt2 = $pdo->prepare("
        INSERT INTO asignaciones_pagos (usuario_id, descripcion_plan, monto, fecha_asignada, pago_id,codigostripe,dias) 
        VALUES (?, ?, ?, ?, ?,?,?)
    ");
    $stmt2->execute([
        $usuario_id,
        $descripcion,
        $_POST['monto'],
        $_POST['fecha_asignada'] ?? date('Y-m-d'),
        $ultimoPagoId,
        $paymentIntent->client_secret,
        $_POST['dias'],

    ]);

    jsonOk([
        'mensaje' => 'Pago y asignación creados correctamente',
        'client_secret' => $paymentIntent->client_secret
    ]);
} catch (\Stripe\Exception\ApiErrorException $e) {
    jsonError("Error en Stripe: " . $e->getMessage());
} catch (\PDOException $e) {
    jsonError("Error en la base de datos: " . $e->getMessage());
} catch (\Exception $e) {
    jsonError("Error general: " . $e->getMessage());
}
function jsonOk($data)
{
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['success' => true, 'data' => $data], JSON_UNESCAPED_UNICODE);
    exit;
}
function jsonError($msg)
{
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['success' => false, 'error' => $msg], JSON_UNESCAPED_UNICODE);
    exit;
}
