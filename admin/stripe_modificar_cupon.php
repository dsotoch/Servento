<?php

use Stripe\PromotionCode;

include_once("conexion.php");
require 'stripe_auth.php';

try {

    if ($operacion == "eliminar") {
        // Desactivar Promo Code
        PromotionCode::update($promo_id, [
            'active' => false
        ]);
    } else {

        if ($new == 1) {

            // Obtener datos actuales
            $promoData   = \Stripe\PromotionCode::retrieve($promo_id);

            // Verificar que NO haya expirado
            if ($promoData->expires_at && $promoData->expires_at < time()) {
                throw new Exception("El código ya expiró. No se puede reactivar.");
            }
            // Reactivar código promocional
            \Stripe\PromotionCode::update($promo_id, ['active' => true]);
        } else {

            \Stripe\PromotionCode::update($promo_id, ['active' => false]);
        }
    }
} catch (\Exception $e) {
    throw new Exception($e->getMessage());
}
