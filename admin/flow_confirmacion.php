<?php

require_once "flow_auth.php";
require_once "conexion.php";

date_default_timezone_set("America/Lima");

// Datos enviados por Flow
$data = $_POST;

// Crear carpeta logs
$dir = __DIR__ . "/logs";

if (!is_dir($dir)) {
    mkdir($dir, 0777, true);
}

$archivo = $dir . "/flow_confirmaciones.log";

// Token
$token = $data["token"] ?? "";

if (!empty($token)) {

    // Consultar Flow
    $respuesta = getOrdenPago($token);

    // Guardar log
    file_put_contents(
        $archivo,
        "\n\n" . print_r($respuesta, true),
        FILE_APPEND
    );

    // Pago aprobado
    if (
        isset($respuesta->status) &&
        $respuesta->status == 2
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
            'exitoso',
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
                'exitoso',
                $fecha_pago,
                $id_pago
            ]);
        }
    } else {
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
    }
}

// Respuesta obligatoria
http_response_code(200);
echo "OK";
