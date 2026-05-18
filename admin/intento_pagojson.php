<?php

set_error_handler(function ($severity, $message, $file, $line) {
    throw new ErrorException($message, 0, $severity, $file, $line);
});
date_default_timezone_set("America/Lima");
include_once("funciones.php");
global $pdo;
$sql = "SELECT * FROM configuraciones LIMIT 1";
$stmt = $pdo->prepare($sql);
$stmt->execute();
$row = $stmt->fetch(PDO::FETCH_ASSOC);
$MONEDA = $row["moneda"] ?? "";


$sql = "SELECT * FROM promociones WHERE id=$promocion LIMIT 1";
$stmt = $pdo->prepare($sql);
$stmt->execute();
$row = $stmt->fetch(PDO::FETCH_ASSOC);
$monto = $row["costo"] ?? 1;
$promocion = $row["titulo"] ?? "";
$dias = $row["dias_vigencia"] ?? "";

try {
    require 'vendor/autoload.php';
    require_once('stripe_auth.php');

    $montoStripe = floatval($monto) * 100;
    $moneda = $MONEDA ?? 'mxn';
    $descripcion = $promocion ?? 'Plan asignado';
    $usuario_id = $usuario_id;
    $tienePagoPendiente = $pdo->prepare("
    SELECT id FROM pagos WHERE usuario_id = :usuario_id AND estado = 'pendiente' LIMIT 1
");
    $tienePagoPendiente->execute([':usuario_id' => $usuario_id]);
    $pagoExistente = $tienePagoPendiente->fetch(PDO::FETCH_ASSOC);

    if ($pagoExistente) {
        throw new Exception("El usuario ya tiene un pago pendiente (ID: {$pagoExistente['id']}).");
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
        $monto,
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
        $monto,
        date('Y-m-d'),
        $ultimoPagoId,
        $paymentIntent->client_secret,
        $dias
    ]);

} catch (\Stripe\Exception\ApiErrorException $e) {
    throw new Exception("Error en Stripe: " . $e->getMessage());
} catch (\PDOException $e) {
    throw new Exception("Error en la base de datos: " . $e->getMessage());
} catch (\Exception $e) {
    throw new Exception("Error general: " . $e->getMessage());
}
