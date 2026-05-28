<?php


function listarComentarios($usuario_id)
{
    try {
        global $pdo;
        date_default_timezone_set("America/Lima");
        $hoy = new DateTime();

        $sql_user = "SELECT fecha_creacion 
             FROM usuarios 
             WHERE id = $usuario_id";

        $data_user = select($pdo, $sql_user)[0];

        $fecha_creacion = new DateTime($data_user["fecha_creacion"]);

        $diferencia = $fecha_creacion->diff($hoy);

        if ($diferencia->days > 7) {
            $sql = "SELECT * FROM promociones WHERE estado='activo' AND tipo != 'nuevo_usuario' ";
        } else {
            $sql = "SELECT * FROM promociones WHERE estado='activo'";
        }
        $data = select($pdo, $sql);
        return ["success" => true, "mensaje" => $data];
    } catch (Exception $e) {
        return ["success" => false, "mensaje" => $e->getMessage()];
    }
}
function listaPlan($id)
{
    try {
        global $pdo;
        $sql = "SELECT * FROM asignaciones_pagos  
            WHERE usuario_id = ?  
            ORDER BY id DESC";
        $data = select($pdo, $sql, [$id]);
        return ["success" => true, "mensaje" => $data];
    } catch (Exception $e) {
        return ["success" => false, "mensaje" => $e->getMessage()];
    }
}
function paymentSecret($id)
{
    try {
        global $pdo;
        $sql = "SELECT * FROM asignaciones_pagos as ap INNER JOIN pagos as p ON ap.pago_id=p.id
            WHERE ap.usuario_id = ?  and ap.estado !='fallido'
            ORDER BY ap.id DESC LIMIT 1";
        $data = select($pdo, $sql, [$id]);
        return ["success" => true, "mensaje" => $data];
    } catch (Exception $e) {
        return ["success" => false, "mensaje" => $e->getMessage()];
    }
}

function listaPlanTodos($id)
{

    try {
        global $pdo;
        $sql = "SELECT * FROM pagos  
            WHERE usuario_id = ?  
            ORDER BY id DESC";
        $data = select($pdo, $sql, [$id]);
        return ["success" => true, "mensaje" => $data];
    } catch (Exception $e) {
        return ["success" => false, "mensaje" => $e->getMessage()];
    }
}
function listarMensajes($id)
{
    try {
        global $pdo;
        date_default_timezone_set("America/Lima");
        $hoy = date("Y-m-d");
        $id = (int) $id;

        // Mensajes generales
        $sql = "SELECT * FROM servicios_mensajes WHERE usuario_id=? ORDER BY id DESC";
        $data = select($pdo, $sql, [$id]);

        // Mensajes con imagen y vigencia activa
        $sql2 = "SELECT imagen FROM servicios_mensajes 
                 WHERE usuario_id=? AND imagen IS NOT NULL AND vigencia >= ? 
                 ORDER BY id DESC";
        $data2 = select($pdo, $sql2, [$id, $hoy]);

        return ["success" => true, "mensaje" => $data, "imagenes" => $data2];
    } catch (Exception $e) {
        return ["success" => false, "mensaje" => $e->getMessage()];
    }
}

function listarMensajesNuevos($id, $viene)
{
    try {
        global $pdo;
        $id = (int) $id;

        if ($viene == "chat") {
            $sql = "SELECT COUNT(*) as total
                    FROM servicios_mensajes 
                    WHERE usuario_id = ? AND imagen IS NULL ";
            $params = [$id];
        } else {
            $sql = "SELECT COUNT(*) as total
                    FROM servicios_mensajes 
                    WHERE usuario_id = ?";
            $params = [$id];
        }

        $data = select($pdo, $sql, $params);
        return ["success" => true, "mensaje" => $data];
    } catch (Exception $e) {
        logSQL("Error: " . $e->getMessage());
        return ["success" => false, "mensaje" => $e->getMessage()];
    }
}

function logSQL($mensaje)
{
    // Ruta del archivo de log (puedes cambiarla)
    $archivo = __DIR__ . '/logs/sql_log.txt';

    // Crear carpeta logs si no existe
    $carpeta = dirname($archivo);
    if (!is_dir($carpeta)) {
        mkdir($carpeta, 0777, true);
    }

    // Preparar mensaje con fecha
    $texto = "[" . date("Y-m-d H:i:s") . "] " . $mensaje . PHP_EOL;

    // Escribir en el archivo (append)
    file_put_contents($archivo, $texto, FILE_APPEND);
}
