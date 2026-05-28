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

    $sql = "SELECT 
        u.id,
        ap.descripcion_plan,
        ap.estado,
        ap.fecha_asignada,
        ap.dias,
        uc.fecha,
        c.fecha_fin

    FROM usuarios u

    LEFT JOIN (
        SELECT *
        FROM asignaciones_pagos ap1
        WHERE ap1.id = (
            SELECT MAX(ap2.id)
            FROM asignaciones_pagos ap2
            WHERE ap2.usuario_id = ap1.usuario_id
        )
    ) ap 
        ON u.id = ap.usuario_id

    LEFT JOIN (
        SELECT *
        FROM usuario_cupon uc1
        WHERE uc1.id = (
            SELECT MAX(uc2.id)
            FROM usuario_cupon uc2
            WHERE uc2.usuario_id = uc1.usuario_id
        )
    ) uc 
        ON u.id = uc.usuario_id

    LEFT JOIN codigos_publicacion c 
        ON uc.cupon_id = c.id";

    $stmt = $pdo->prepare($sql);
    $stmt->execute();

    $asignaciones = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (!$asignaciones) {
        return;
    }

    foreach ($asignaciones as $asignacion) {

        if (
            empty($asignacion['dias']) &&
            empty($asignacion['fecha'])
        ) {
            continue;
        }

        verificarPagoIndividual($asignacion);
    }
}

function verificarPagoIndividual(array $data)
{
    global $pdo;

    $HOY = strtotime(date("Y-m-d"));

    $fechas_vigencia = [];

    // ===== PLAN =====
    if (
        !empty($data["fecha_asignada"]) &&
        !empty($data["dias"]) &&
        (strtolower(trim($data['estado'])) !== 'fallido' && strtolower(trim($data['estado'])) !== 'pendiente')
    ) {

        $fechaPlan = new DateTime(
            $data["fecha_asignada"]
        );

        $fechaPlan->add(
            new DateInterval(
                "P" . intval($data["dias"]) . "D"
            )
        );

        $fechas_vigencia[] = strtotime(
            $fechaPlan->format("Y-m-d")
        );
    }

    // ===== CUPÓN =====
    if (!empty($data["fecha_fin"])) {

        $fechas_vigencia[] = strtotime(
            $data["fecha_fin"]
        );
    }

    // NO TIENE NADA
    if (empty($fechas_vigencia)) {
        $sql = "
            INSERT IGNORE INTO interrupciones(usuario_id,fecha)
            VALUES(?,?)
        ";

        $stmt = $pdo->prepare($sql);

        $stmt->execute([
            $data['id'],
            date("Y-m-d")
        ]);
        return;
    }

    // TOMAR LA MAYOR FECHA
    $ultimaVigencia = max($fechas_vigencia);

    $excluir = $HOY > $ultimaVigencia;

    if ($excluir) {

        $sql = "
            INSERT IGNORE INTO interrupciones(usuario_id,fecha)
            VALUES(?,?)
        ";

        $stmt = $pdo->prepare($sql);

        $stmt->execute([
            $data['id'],
            date("Y-m-d")
        ]);
    } else {

        $sql = "
            DELETE FROM interrupciones
            WHERE usuario_id=?
        ";

        $stmt = $pdo->prepare($sql);

        $stmt->execute([
            $data['id']
        ]);
    }
}
