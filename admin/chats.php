<?php
date_default_timezone_set("America/Lima");
$hoy = date("Y-m-d H:i:s");

function guardarMensaje()
{
    global $pdo, $hoy;
    $in = getJsonInput();

    $remitente = $in['remitente'] ?? '';
    $destinatario = $in['destinatario'] ?? '';
    $mensaje = $in['mensaje'] ?? '';

    if ($remitente && $destinatario && $mensaje) {
        $stmt = $pdo->prepare("SELECT nombres FROM usuarios WHERE id = :remitente LIMIT 1");

        // Ejecutar pasando el parámetro
        $stmt->execute(['remitente' => $remitente]);

        // Obtener el resultado
        $usuario = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($usuario) {
            $nombre = $usuario['nombres'];
            // $nombre contiene el nombre del remitente
        } else {
            $nombre = "Desconocido";
        }

        $stmt = $pdo->prepare("INSERT INTO mensajes (remitente, destinatario, mensaje,fecha,usuario) VALUES (?, ?, ?,?,?)");
        $stmt->execute([$remitente, $destinatario, $mensaje, $hoy, $nombre]);

        $stmtPago = $pdo->prepare(
            "INSERT INTO servicios_mensajes (mensaje, usuario_id, servicio) VALUES (?, ?,?)"
        );
        $mensaje = "Nuevo Mensaje de " . $nombre;
        $servicio = "Chat." . $remitente;
        $id = $destinatario;
        $stmtPago->execute([$mensaje, $id, $servicio]);
        return ["success" => true, "mensaje" => "Mensaje enviado"];
    } else {
        return ["success" => false, "mensaje" => "Datos incompletos"];
    }
}

function obtenerMensajes()
{
    global $pdo;
    $usuario1 = $_GET['remitente'] ?? '';
    $usuario2 = $_GET['destinatario'] ?? '';

    if ($usuario1 && $usuario2) {
        $stmt = $pdo->prepare("
        SELECT * FROM mensajes 
        WHERE (remitente=? AND destinatario=?) 
           OR (remitente=? AND destinatario=?) 
        ORDER BY fecha ASC
    ");
        $stmt->execute([$usuario1, $usuario2, $usuario2, $usuario1]);
        $mensajes = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $update = $pdo->prepare("
        UPDATE mensajes SET leido=1 
        WHERE remitente=? AND destinatario=? AND leido=0
    ");
        $update->execute([$usuario1, $usuario2]);
        return ["success" => true, "mensajes" => $mensajes];
    } else {
        return ["success" => false, "mensajes" => []];
    }
}
function obtenerClientes()
{
    global $pdo;
    $usuario_id = $_GET['usuario_id'] ?? 0;

    $sql = "
        SELECT DISTINCT
            CASE
                WHEN remitente = :usuario THEN destinatario
                ELSE remitente
            END as cliente_id
        FROM mensajes
        WHERE remitente = :usuario OR destinatario = :usuario
    ";

    $stmt = $pdo->prepare($sql);
    $stmt->execute(['usuario' => $usuario_id]);
    $clientes_ids = $stmt->fetchAll(PDO::FETCH_COLUMN);

    $clientes = [];
    if (!empty($clientes_ids)) {
        $in  = str_repeat('?,', count($clientes_ids) - 1) . '?';
        $sql2 = "SELECT id, nombres, foto,telefono FROM usuarios WHERE id IN ($in)";
        $stmt2 = $pdo->prepare($sql2);
        $stmt2->execute($clientes_ids);
        $clientes = $stmt2->fetchAll(PDO::FETCH_ASSOC);
    }

    return [
        "success" => true,
        "mensaje" => $clientes
    ];
}

function obtenerClientesNuevosMensajes()
{
    global $pdo;
    $usuario_id = $_GET['usuario_id'] ?? 0;

    $sql = "
        SELECT DISTINCT remitente as cliente_id
        FROM mensajes
        WHERE destinatario = :usuario AND leido = 0
    ";

    $stmt = $pdo->prepare($sql);
    $stmt->execute(['usuario' => $usuario_id]);
    $clientes_ids = $stmt->fetchAll(PDO::FETCH_COLUMN);

    $clientes = [];
    if (!empty($clientes_ids)) {
        $in  = str_repeat('?,', count($clientes_ids) - 1) . '?';
        $sql2 = "SELECT id, nombres, foto, telefono 
                 FROM usuarios 
                 WHERE id IN ($in)";
        $stmt2 = $pdo->prepare($sql2);
        $stmt2->execute($clientes_ids);
        $clientes = $stmt2->fetchAll(PDO::FETCH_ASSOC);
    }

    return [
        "success" => true,
        "mensaje" => $clientes
    ];
}
