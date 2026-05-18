<?php
require_once "conexion.php";
date_default_timezone_set("America/Lima");
$hoy = date("Y-m-d");
$sql = "SELECT * FROM recordatorios WHERE estado = 'activo'";
$stmt = $pdo->prepare($sql);
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

foreach ($rows as $row) {

    $mensaje = "Si no efectúas el pago dentro de 2 días, las publicaciones asociadas serán suspendidas automáticamente hasta que la renovación sea completada. Una vez regularizado el pago, las publicaciones volverán a estar activas de inmediato.";

    $idCliente = $row["cliente_id"];
    $servicio  = "Recordatorio de Pago";
    $vigencia = "";
    $nombreArchivo = "";
    $fechaRecordatorio = $row["fecha_recordatorio"];

    if ($hoy == $fechaRecordatorio) {

        $stmtPago = $pdo->prepare(
            "INSERT INTO servicios_mensajes (mensaje, usuario_id, servicio, imagen, vigencia) 
             VALUES (?, ?, ?, ?, ?)"
        );

        $stmtPago->execute([
            $mensaje,
            $idCliente,
            $servicio,
            $nombreArchivo,
            $vigencia
        ]);

        actualizarRecordatorio($row["id"]);
    }
}


function actualizarRecordatorio($id)
{
    global $pdo;

    // Obtener estado actual
    $sql = "SELECT estado FROM recordatorios WHERE id = ? LIMIT 1";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$id]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$row) return;

    $nuevoEstado = ($row['estado'] == "activo") ? "inactivo" : "activo";

    // Actualizar estado
    $sql = "UPDATE recordatorios SET estado = ? WHERE id = ?";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$nuevoEstado, $id]);
}

verificarTodosLosPagos();
function verificarTodosLosPagos()
{
    global $pdo;
    $sql = "SELECT id FROM asignaciones_pagos 
            WHERE estado='pendiente'";
    $stmt = $pdo->prepare($sql);
    $stmt->execute();
    $asignaciones = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (!$asignaciones) return;

    foreach ($asignaciones as $asignacion) {
        verificarPagoIndividual($asignacion["id"]);
    }
}
function verificarPagoIndividual($id)
{
    global $pdo;

    $sql = "SELECT usuario_id, fecha_asignada FROM asignaciones_pagos WHERE id = ? LIMIT 1";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$id]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$row) return;

    $cliente_id      = $row['usuario_id'];
    $fecha_asignada  = $row['fecha_asignada'];

    $fechaAsignadaDT = DateTime::createFromFormat("Y-m-d", $fecha_asignada);

    $hoy = new DateTime();

    if ($fechaAsignadaDT < $hoy) {

        $sql = "UPDATE usuarios SET estado = 'INACTIVO' WHERE id = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$cliente_id]);
    }
}
