<?php
include_once("conexion.php");
require_once 'flow_auth.php';

try {
    // Configuración
    $sql = "SELECT * FROM configuraciones LIMIT 1";
    $stmt = $pdo->prepare($sql);
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    $MONEDA = strtolower($row["moneda"] ?? "usd");

    $vigencia = $vigencia ?? date("Y-m-d");
    $monto = $porcentaje_descuento ?? 100;
    $codigo = $codigo ?? "PROMO" . time();

    // Calcular meses
    $hoy = new DateTime();
    $expiraDate = new DateTime($vigencia);
    $diff = $hoy->diff($expiraDate);
    $meses = $diff->y * 12 + $diff->m;
    if ($meses < 1) $meses = 1;



    $cupon=crearCuponFlow($codigo,$monto,$vigencia);

    $promo_id = $cupon->id;
} catch (\Exception $e) {
    throw new Exception($e->getMessage());
}
