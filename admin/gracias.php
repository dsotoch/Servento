<?php

require_once "flow_auth.php";
require_once "conexion.php";

date_default_timezone_set("America/Lima");
$token = $_POST["token"] ?? null;
$orden = $_GET["commerceOrder"] ?? null;

$titulo = "Pago realizado";
$mensaje = "Tu transacción fue procesada correctamente.";
$icono = "✔";
$clase = "#22c55e";
$respuesta = getOrdenPago($token);

if (
    isset($respuesta->status) &&
    $respuesta->status != 2
) {

    $metodoPago     = $respuesta->paymentData->media ?? '';
    $fecha_pago     = $respuesta->paymentData->date ?? date("Y-m-d H:i:s");
    $stripe_charge_id = $respuesta->flowOrder ?? '';

    // Actualizar asignaciones_pagos
    $stmt = $pdo->prepare("
            UPDATE asignaciones_pagos 
            SET metodo_pago = ?, estado = ?,fecha_asignada=?
            WHERE codigostripe LIKE ?
        ");

    $stmt->execute([
        $metodoPago,
        'fallido',
        date("Y-m-d"),
        "%$token%"
    ]);

    // Obtener pago_id
    $stmt = $pdo->prepare("
            SELECT pago_id 
            FROM asignaciones_pagos 
            WHERE codigostripe LIKE ?
            LIMIT 1
        ");

    $stmt->execute([
        "%$token%"
    ]);

    $res = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($res) {

        $id_pago = $res["pago_id"];

        // Actualizar pagos
        $stmt = $pdo->prepare("
                UPDATE pagos 
                SET stripe_charge_id = ?,
                    metodo_pago = ?,
                    estado = ?,
                    fecha_pago = ?
                WHERE id = ?
            ");

        $stmt->execute([
            $stripe_charge_id,
            $metodoPago,
            'fallido',
            $fecha_pago,
            $id_pago
        ]);
    }
    $titulo = "Pago no completado";

    $mensaje = "La transacción fue cancelada o rechazada.";

    $icono = "✖";

    $clase = "#ef4444";
}

?>

<!DOCTYPE html>
<html lang="es">

<head>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title><?= $titulo ?></title>

    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f4f6f9;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            text-align: center;
        }

        .card {
            background: white;
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
            width: 400px;
        }

        .icono {
            font-size: 70px;
            color: <?= $clase ?>;
        }

        h1 {
            margin: 15px 0;
            color: #333;
        }

        p {
            color: #666;
            font-size: 15px;
        }

        .order {
            margin-top: 10px;
            font-size: 13px;
            color: #999;
        }

        .btn {
            display: inline-block;
            margin-top: 20px;
            background: #1877f2;
            color: white;
            padding: 12px 25px;
            border-radius: 12px;
            text-decoration: none;
        }
    </style>

</head>

<body>

    <div class="card">

        <div class="icono">
            <?= $icono ?>
        </div>

        <h1>
            <?= $titulo ?>
        </h1>

        <p>
            <?= $mensaje ?>
        </p>

        <?php if ($orden): ?>

            <div class="order">
                Orden:
                <?= htmlspecialchars($orden) ?>
            </div>

        <?php endif; ?>

    </div>

</body>

</html>