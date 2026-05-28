<?php
include_once("conexion.php");
require_once 'flow_auth.php';

try {

    if ($operacion == "eliminar") {
        
        eliminarCuponFlow($cupon_id);
    }
} catch (\Exception $e) {
    throw new Exception($e->getMessage());
}
