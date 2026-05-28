<?php

require 'vendor/autoload.php';
require_once 'flow_auth.php';

date_default_timezone_set("America/Lima");

function validarCupon($cupon, $paymentid)
{
    try {
        global $pdo;

        // 1. Buscar cupón
        $sqlCupon = "SELECT * FROM cupones WHERE codigo = ? LIMIT 1";
        $cuponData = select($pdo, $sqlCupon, [$cupon]);

        if (!$cuponData) {
            return ["success" => false, "mensaje" => "Cupón no existe."];
        }

        $cuponData = $cuponData[0];

        if ($cuponData['activo'] != 1) {
            return ["success" => false, "mensaje" => "Cupón inactivo."];
        }

        // 2. Validar fecha de expiración
        if (!empty($cuponData['vigencia_fin'])) {
            $vigencia = strtotime($cuponData['vigencia_fin']);

            if ($vigencia < time()) {
                return ["success" => false, "mensaje" => "Cupón expirado."];
            }
        }

        // 3. Obtener pago original
        $sqlPago = "SELECT * FROM pagos WHERE stripe_payment_intent_id = ? LIMIT 1";
        $pago = select($pdo, $sqlPago, [$paymentid]);

        if (!$pago) {
            return ["success" => false, "mensaje" => "PaymentIntent inválido."];
        }

        $pago = $pago[0];
        $montoOriginal = floatval($pago['monto']);

        // 4. Calcular descuento
        $descuento = floatval($cuponData['monto_descuento']);
        $montoFinal = max(0, $montoOriginal - $descuento);

        // 5. Actualizar el PaymentIntent en Stripe
        $montoEnCentavos = intval($montoFinal * 100);

        $pi = \Stripe\PaymentIntent::update(
            $paymentid,
            ['amount' => $montoEnCentavos]
        );

        // Obtener nuevo client_secret
        $nuevoClientSecret = $pi->client_secret;

        $sqlUpdate = "UPDATE asignaciones_pagos 
                      SET codigostripe = ?
                      WHERE pago_id = ?";

        $stmt = $pdo->prepare($sqlUpdate);

        $stmt->execute([
            $nuevoClientSecret,
            $pago["id"]
        ]);


        // 6. Respuesta para Flutter
        return [
            "success" => true,
            "mensaje" => "Cupón aplicado correctamente",
            "nuevo_amount" => $montoFinal,
            "client_secret" => $nuevoClientSecret,
            "data" => [
                "monto_original" => $montoOriginal,
                "descuento" => $descuento,
                "monto_final" => $montoFinal,
                "cupon_id" => $cuponData['id'],
                "tipo" => $cuponData['tipo'],
                "cupon" => $cuponData['codigo'],
            ]
        ];
    } catch (Exception $e) {
        return ["success" => false, "mensaje" => $e->getMessage()];
    }
}
function validarCodigo($cupon, $usuario_id)
{
    try {
        global $pdo;

        // 1. Buscar cupón
        $sqlCupon = "SELECT * FROM codigos_publicacion WHERE codigo = ? LIMIT 1";
        $cuponData = select($pdo, $sqlCupon, [$cupon]);

        if (!$cuponData) {
            return ["success" => false, "mensaje" => "Codigo no existe."];
        }

        $cuponData = $cuponData[0];

        if ($cuponData['activo'] != 1) {
            return ["success" => false, "mensaje" => "Codigo inactivo."];
        }

        // 2. Validar fecha de expiración
        if (!empty($cuponData['fecha_fin'])) {
            $vigencia = strtotime($cuponData['fecha_fin']);

            if ($vigencia < time()) {
                return ["success" => false, "mensaje" => "Codigo expirado."];
            }
        }
        $hoy = date("Y-m-d H:i:s");
        $insert_usuario_cupon = "INSERT INTO usuario_cupon(usuario_id,cupon_id,fecha) VALUES(?,?,?)";
        $pdo->prepare($insert_usuario_cupon)->execute([$usuario_id, $cuponData['id'], $hoy]);

        return [
            "success" => true,
            "mensaje" => "Codigo aplicado correctamente",
        ];
    } catch (Exception $e) {
        return ["success" => false, "mensaje" => $e->getMessage()];
    }
}
