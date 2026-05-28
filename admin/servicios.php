<?php
date_default_timezone_set("America/Lima");

function guardarImagen($base64, $campo)
{
    if (empty($base64)) return null;

    $base64 = preg_replace('#^data:image/\w+;base64,#i', '', $base64);
    $data = base64_decode($base64);

    if ($data === false) return null;

    $nombreArchivo = uniqid($campo . "_") . ".png";
    $rutaCarpeta = __DIR__ . "/uploads/servicios/";
    if (!is_dir($rutaCarpeta)) mkdir($rutaCarpeta, 0777, true);

    file_put_contents($rutaCarpeta . $nombreArchivo, $data);
    return "uploads/servicios/" . $nombreArchivo;
}

function listarComentarios($id)
{
    try {
        global $pdo;
        $sql = "SELECT * FROM vis_comentarios WHERE id_servicio=? ORDER BY fecha_creacion DESC";
        $data = select($pdo, $sql, [$id]);
        return ["success" => true, "mensaje" => $data];
    } catch (Exception $e) {
        return ["success" => false, "mensaje" => $e->getMessage()];
    }
}

function guardarFavorito($usuario, $servicio)
{
    try {
        global $pdo;

        $sql = "INSERT INTO favoritos(usuario_id, servicio_id)
                VALUES (?, ?)
                ON DUPLICATE KEY UPDATE servicio_id = VALUES(servicio_id)";

        $data = insertInto($pdo, $sql, [$usuario, $servicio]);

        return $data; // ya contiene success y mensaje
    } catch (Exception $e) {
        return ["success" => false, "mensaje" => $e->getMessage()];
    }
}

function AsignarPromocion($idpromo, $us)
{
    try {
        $promocion = $idpromo;
        $usuario_id = $us;
        require_once("intento_pagojson.php");
        return ["success" => true, "mensaje" => 'Pago y asignación creados correctamente'];
    } catch (Exception $e) {
        return ["success" => false, "mensaje" => $e->getMessage()];
    }
}



function listarFavorito($usuario)
{
    try {
        global $pdo;
        $sql = "SELECT s.id FROM servicios s
JOIN favoritos f ON f.servicio_id = s.id
WHERE f.usuario_id = ?
";
        $data = select($pdo, $sql, [$usuario]);
        return ["success" => true, "mensaje" => $data];
    } catch (Exception $e) {
        return ["success" => false, "mensaje" => $e->getMessage()];
    }
}
function eliminarFavorito($usuario, $servicio)
{
    try {
        global $pdo;
        $sql = "DELETE FROM favoritos WHERE usuario_id=? AND servicio_id=?
";
        $data = eliminarRegistro($pdo, $sql, [$usuario, $servicio]);
        return ["success" => true, "mensaje" => $data];
    } catch (Exception $e) {
        return ["success" => false, "mensaje" => $e->getMessage()];
    }
}
function listarServiciosTodos($offset, $limit, $lat, $lon, $radio)
{
    try {
        global $pdo;

        // Validaciones y valores por defecto
        $lat = $lat !== null ? (float)$lat : 0;
        $lon = $lon !== null ? (float)$lon : 0;
        $radio = $radio !== null ? (float)$radio : 100; // por defecto 100 km
        $limit = (int)$limit;
        $offset = (int)$offset;
        $sql = "
    SELECT s.*,
           (6371 * acos(
               cos(radians(:lat)) * cos(radians(s.lat)) *
               cos(radians(s.`long`) - radians(:lon)) +
               sin(radians(:lat)) * sin(radians(s.lat))
           )) AS distancia

    FROM vis_servicios s

    INNER JOIN usuarios us 
        ON s.usuario_id = us.id

    WHERE us.estado='ACTIVO'

    AND NOT EXISTS (
        SELECT 1
        FROM interrupciones i
        WHERE i.usuario_id = s.usuario_id
    )

    HAVING distancia <= :radio

    ORDER BY distancia ASC

    LIMIT $limit OFFSET $offset
";

        $stmt = $pdo->prepare($sql);

        $stmt->bindValue(':lat', $lat);
        $stmt->bindValue(':lon', $lon);
        $stmt->bindValue(':radio', $radio);

        $stmt->execute();

        $datos = $stmt->fetchAll(PDO::FETCH_ASSOC);


        return [
            "success" => true,
            "mensaje" => $datos
        ];
    } catch (Exception $e) {
        return [
            "success" => false,
            "mensaje" => $e->getMessage()
        ];
    }
}


function listarServiciosFiltro($filtro)
{
    try {
        global $pdo;
        $sql = "SELECT * FROM vis_servicios WHERE titulo LIKE%?%";
        $data = select($pdo, $sql, [$filtro]);
        return ["success" => true, "mensaje" => $data];
    } catch (Exception $e) {
        return ["success" => false, "mensaje" => $e->getMessage()];
    }
}
function guardarServicio(
    $titulo,
    $descripcion,
    $precio,
    $ubicacion,
    $categoria,
    $usuario_id,
    $estado,
    $imagen1,
    $imagen2,
    $imagen3,
    $lat,
    $long,
    $sub
) {
    try {
        global $pdo;
        $st = $pdo->prepare("SELECT estado FROM usuarios WHERE id = :id");
        $st->bindValue(':id', $usuario_id, PDO::PARAM_INT);
        $st->execute();
        $estadous = $st->fetchColumn();
        if ($estadous == "ACTIVO") {
            $stmtUsuario = $pdo->prepare("SELECT * FROM asignaciones_pagos a INNER JOIN promociones p ON a.descripcion_plan=p.titulo  WHERE  a.usuario_id=$usuario_id ORDER BY a.id desc LIMIT 1");
            $stmtUsuario->execute();
            $usuario = $stmtUsuario->fetch(PDO::FETCH_ASSOC);
            if ($usuario) {
                if ($usuario["descripcion_plan"] == "PLAN PUBLICACION") {
                    require __DIR__ . '/vendor/autoload.php';
                    $dotenv = Dotenv\Dotenv::createImmutable(__DIR__);
                    $dotenv->load();
                    $postData = [
                        'usuario_id' => $usuario['usuario_id'],
                        'promocion' => $usuario['descripcion_plan'],
                        'dias' => $usuario['dias'],
                        'monto' => $usuario['monto'],
                    ];
                    $url = $_ENV["DOMINIO"];
                    $ch = curl_init($url . "/reasignar.php");
                    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                    curl_setopt($ch, CURLOPT_POST, true);
                    curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);
                    $response = curl_exec($ch);
                    if (curl_errno($ch)) {
                        $error_msg = curl_error($ch);
                    }
                    curl_close($ch);

                    if (isset($error_msg)) {
                        return [
                            "success" => false,
                            "mensaje" => "Error al enviar datos:" . $error_msg
                        ];
                    } else {
                        $data = json_decode($response, true);

                        if ($data === null) {
                            return [
                                "success" => false,
                                "mensaje" => "Respuesta inválida del servidor: $response"
                            ];
                        }

                        if (!isset($data["success"]) && !$data["success"] === true) {
                            return [
                                "success" => false,
                                "mensaje" => $data["error"] ?? "Error desconocido"
                            ];
                        }
                    }
                }
                $dias = $usuario["dias"] ?? 1;

                $hoy = new DateTime('now');

                $vigencia = new DateTime($usuario["fecha_asignada"]);
                $vigencia->add(new DateInterval("P{$dias}D"));
                if ($hoy->getTimestamp() > $vigencia->getTimestamp()) {
                    return ["success" => false, "mensaje" => "No puedes publicar porque ya venció la Vigencia de tu plan, selecciona uno nuevo."];
                }
                if (
                    trim(
                        preg_replace('/[\x{1F000}-\x{1FFFF}]/u', '', $categoria)
                    ) == "SERVICIOS EMPRESARIALES"
                ) {
                    if ($usuario["descripcion_plan"] != "PLAN GOLDEN" && $usuario["tipo"] != 'categoria') {
                        return ["success" => false, "mensaje" => "La Categoria " . $categoria . " no esta permitido en tu Plan."];
                    }
                }
            }
            $stmt = $pdo->prepare("INSERT INTO servicios 
                (titulo, descripcion, precio, ubicacion, categoria, imagen1, imagen2, imagen3, estado, usuario_id, `lat`, `long`,subcategoria)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?,?)");
            $stmt->execute([$titulo, $descripcion, $precio, $ubicacion, $categoria, $imagen1, $imagen2, $imagen3, $estado, $usuario_id, $lat, $long, $sub]);
            return ["success" => true, "mensaje" => "Servicio creado correctamente"];
        } else {
            return ["success" => false, "mensaje" => "Tu Cuenta esta Inabilitada por falta de pago"];
        }
    } catch (Exception $e) {
        return ["success" => false, "mensaje" => $e->getMessage()];
    }
}
function listarServicios($id)
{
    global $pdo;
    try {
        $sql = "SELECT * FROM servicios WHERE usuario_id=?";
        $data = select($pdo, $sql, [$id]);
        return ["success" => true, "mensaje" => $data];
    } catch (\Throwable $e) {
        return ["success" => false, "mensaje" => $e->getMessage()];
    }
}

function modificarServicioConVariasImagenes(
    $id,
    $titulo,
    $descripcion,
    $precio,
    $ubicacion,
    $categoria,
    $usuario_id,
    $estado,
    $lat,
    $long,
    array $nuevasImagenes,
    $sub
) {
    try {
        global $pdo;

        // 1️⃣ Obtener las imágenes actuales
        $stmt = $pdo->prepare("SELECT imagen1, imagen2, imagen3 FROM servicios WHERE id = ?");
        $stmt->execute([$id]);
        $imagenes = $stmt->fetch(PDO::FETCH_ASSOC);

        $camposImagenes = ['imagen1', 'imagen2', 'imagen3'];

        // 2️⃣ Rellenar los huecos vacíos con las nuevas imágenes
        $indexNueva = 0;
        foreach ($camposImagenes as $campo) {
            if (empty($imagenes[$campo]) && isset($nuevasImagenes[$indexNueva])) {
                $imagenes[$campo] = $nuevasImagenes[$indexNueva];
                $indexNueva++;
            }
        }

        // Opcional: si sobran nuevas imágenes, sobrescribe desde imagen1
        while (isset($nuevasImagenes[$indexNueva])) {
            $imagenes[$camposImagenes[$indexNueva % 3]] = $nuevasImagenes[$indexNueva];
            $indexNueva++;
        }

        // 3️⃣ Actualizar el servicio
        $stmt = $pdo->prepare("
            UPDATE servicios SET
                titulo = ?,
                descripcion = ?,
                precio = ?,
                ubicacion = ?,
                categoria = ?,
                estado = ?,
                usuario_id = ?,
                imagen1 = ?,
                imagen2 = ?,
                imagen3 = ?,
                subcategoria=?,
                 `lat`=?, `long`=?
            WHERE id = ?
        ");

        $stmt->execute([
            $titulo,
            $descripcion,
            $precio,
            $ubicacion,
            $categoria,
            $estado,
            $usuario_id,
            $imagenes['imagen1'],
            $imagenes['imagen2'],
            $imagenes['imagen3'],
            $sub,
            $lat,
            $long,
            $id
        ]);

        return ["success" => true, "mensaje" => "Servicio modificado correctamente"];
    } catch (Exception $e) {
        return ["success" => false, "mensaje" => $e->getMessage()];
    }
}
function eliminarServicio($id)
{
    global $pdo;
    try {
        $id = intval($id);

        if ($id <= 0) {
            return ["success" => false, "mensaje" => "ID inválido"];
        }
        $sql = "DELETE  FROM servicios WHERE id=?";
        $data = eliminarRegistro($pdo, $sql, [$id]);
        return $data;
    } catch (\Throwable $e) {
        return ["success" => false, "mensaje" => $e->getMessage()];
    }
}
function cambiarEstado($id)
{
    global $pdo;
    try {
        $id = intval($id);

        if ($id <= 0) {
            return ["success" => false, "mensaje" => "ID inválido"];
        }
        $s = "SELECT estado FROM servicios WHERE id=?";
        $serv = select($pdo, $s, [$id]);
        if (count($serv) > 0) {
            $estado = $serv[0]["estado"] ?? "";
            $newestado = '';
            if ($estado == "activo") {
                $newestado = "inactivo";
            } else {
                $newestado = "activo";
            }
            $sql = "UPDATE servicios SET estado=? WHERE id=?";
            $data = editarRegistro($pdo, $sql, [$newestado, $id]);
            return $data;
        } else {
            throw new Exception("No se Encontro el Servicio");
        }
    } catch (\Throwable $e) {
        return ["success" => false, "mensaje" => $e->getMessage()];
    }
}

function guardarComentarios($comentario, $estrellas, $usuario_id, $id_servicio)
{
    global $pdo;
    try {
        $id = intval($usuario_id);

        if ($id <= 0) {
            return ["success" => false, "mensaje" => "ID inválido"];
        }
        $sql = "INSERT INTO  comentarios(comentario,estrellas,usuario_id,id_servicio) VALUES(?,?,?,?)";
        $data = insertInto($pdo, $sql, [$comentario, $estrellas, $id, $id_servicio]);
        return $data;
    } catch (\Throwable $e) {
        return ["success" => false, "mensaje" => $e->getMessage()];
    }
}
