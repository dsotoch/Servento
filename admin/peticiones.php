<?php
if ($action) {
    try {

        //pagos

        if ($action === 'list_pagos') {
            $limit = max(1, intval($_GET['limit'] ?? 50));
            $offset = max(0, intval($_GET['offset'] ?? 0));
            $q = trim($_GET['q'] ?? '');
            $estado = $_GET['estado'] ?? '';

            // 🔹 Consulta base
            $sql = "SELECT SQL_CALC_FOUND_ROWS p.*, u.nombres AS nombre_usuario, u.email 
            FROM pagos p
            LEFT JOIN usuarios u ON p.usuario_id = u.id
            WHERE 1=1 ";
            $params = [];

            // 🔹 Filtro por búsqueda
            if ($q !== '') {
                if (is_numeric($q)) {
                    $sql .= " AND (p.id = :id 
             OR p.monto = :monto 
             OR LOWER(u.nombres) LIKE :q 
             OR LOWER(u.email) LIKE :q 
             OR LOWER(p.descripcion) LIKE :q) ";
                    $params[':id'] = (int)$q;
                    $params[':monto'] = (float)$q;
                    $params[':q'] = '%' . mb_strtolower($q) . '%';
                } elseif (preg_match('/^\d{4}-\d{2}-\d{2}$/', $q)) {
                    $sql .= " AND (DATE(p.fecha_pago) = :fecha OR DATE(p.created_at) = :fecha) ";
                    $params[':fecha'] = $q;
                } elseif (preg_match('/^\d{2}\/\d{2}\/\d{4}$/', $q)) {
                    $fecha = DateTime::createFromFormat('d/m/Y', $q);
                    if ($fecha) {
                        $sql .= " AND (DATE(p.fecha_pago) = :fecha OR DATE(p.created_at) = :fecha) ";
                        $params[':fecha'] = $fecha->format('Y-m-d');
                    }
                } else {
                    $sql .= " AND (LOWER(u.nombres) LIKE :q 
             OR LOWER(u.email) LIKE :q 
             OR LOWER(p.descripcion) LIKE :q
             OR LOWER(p.metodo_pago) LIKE :q) ";
                    $params[':q'] = '%' . mb_strtolower($q) . '%';
                }
            }

            // 🔹 Filtro por estado
            if (in_array($estado, ['pendiente', 'exitoso', 'fallido'])) {
                $sql .= " AND p.estado = :estado ";
                $params[':estado'] = $estado;
            }

            // 🔹 Orden y paginación
            $sql .= " ORDER BY p.created_at DESC LIMIT :limit OFFSET :offset";

            // 🔹 Preparar y ejecutar
            $stmt = $pdo->prepare($sql);
            foreach ($params as $k => $v) $stmt->bindValue($k, $v);
            $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
            $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
            $stmt->execute();

            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $total = intval($pdo->query("SELECT FOUND_ROWS()")->fetchColumn());

            jsonOk([
                'items' => $rows,
                'total' => $total,
                'limit' => $limit,
                'offset' => $offset
            ]);
        }


        // --- Toggle estado servicio ---
        if ($action === 'toggle_estado_pago') {
            $id = intval($_POST['id'] ?? 0);
            if ($id <= 0) jsonError('ID inválido');
            $row = $pdo->query("SELECT estado FROM servicios WHERE id=$id")->fetch(PDO::FETCH_ASSOC);
            if (!$row) jsonError('Servicio no encontrado');
            $new = "";
            switch ($row['estado']) {
                case 'activo':
                    $new = 'inactivo';
                    break;
                case 'pendiente':
                    $new = 'activo';
                    break;
                case 'inactivo':
                    $new = 'activo';
                    break;
            }
            $pdo->prepare("UPDATE servicios SET estado=? WHERE id=?")->execute([$new, $id]);
            jsonOk('OK');
        }
        if ($action == "eliminarpago") {
            $id = intval($_POST['id'] ?? 0);
            if ($id <= 0) jsonError('ID inválido');
            $row = $pdo->query("SELECT estado FROM pagos WHERE id=$id")->fetch(PDO::FETCH_ASSOC);
            if (!$row) jsonError('Pago no encontrado');

            $pdo->prepare("DELETE FROM pagos WHERE id=?")->execute([$id]);
            jsonOk('Pago Eliminado Correctamente');
        }

        if ($action == "asignar_pago") {

            include_once("intentopago.php");
        }

        //Cupones

        if ($action == "crearcupon") {
            $codigo = trim($_POST["codigo"] ?? "");
            $descripcion = trim($_POST["descripcion"] ?? "");
            $porcentaje_descuento = floatval($_POST["porcentaje_descuento"] ?? 0);
            $vigencia = $_POST["vigencia"] ?? "";

            if (empty($codigo)) {
                jsonError("El código del cupón es obligatorio.");
                exit;
            }

            try {
                $check = $pdo->prepare("SELECT id FROM cupones WHERE codigo = ?");
                $check->execute([$codigo]);
                if ($check->fetch()) {
                    jsonError("Ya existe un cupón con ese código.");
                    exit;
                }
                include_once("stripe_crear_cupon.php");
                // Insertar cupón nuevo
                $stmt = $pdo->prepare("
            INSERT INTO cupones (codigo, descripcion, monto_descuento,vigencia_inicio, vigencia_fin, activo,id_cupon_stripe,id_promocion)
            VALUES (?, ?, ?, ?,?, 1,?,?)
        ");
                $stmt->execute([$codigo, $descripcion, $porcentaje_descuento, date("Y-m-d"), $vigencia, $cupon->id, $promo_id]);

                jsonOk("Cupón creado correctamente.");
            } catch (Exception $e) {
                jsonError("Error al crear el cupón: " . $e->getMessage());
            }
        }




        //---CLIENTES ---

        if ($action == "send_sms") {
            $mensaje = $_POST["mensaje"] ?? "";
            $id = $_POST["id"] ?? "";
            $servicio = $_POST["servicio"] ?? "";
            $imagen = $_FILES["imagen"] ?? "";
            $vigencia = $_POST["vigencia"] ?? "";
            $nombreArchivo = "";
            if ($imagen && $imagen["error"] === UPLOAD_ERR_OK) {
                $nombreTmp = $imagen["tmp_name"];
                $nombreArchivo = time() . "_" . basename($imagen["name"]);
                $rutaDestino = __DIR__ . "/uploads/promo/" . $nombreArchivo;

                move_uploaded_file($nombreTmp, $rutaDestino);
            }
            if($id == "todos"){
                $stmtUsuarios = $pdo->query("SELECT id FROM usuarios")->fetchAll(PDO::FETCH_ASSOC);
                foreach($stmtUsuarios as $usuario){
                    $stmtPago = $pdo->prepare(
                        "INSERT INTO servicios_mensajes (mensaje, usuario_id, servicio,imagen,vigencia) VALUES (?, ?, ?,?,?)"
                    );
    
                    $stmtPago->execute([$mensaje, $usuario['id'], $servicio, $nombreArchivo, $vigencia]);
                }
                jsonOk("Mensaje enviado a todos los usuarios correctamente");
            }else{
  $stmtPago = $pdo->prepare(
                "INSERT INTO servicios_mensajes (mensaje, usuario_id, servicio,imagen,vigencia) VALUES (?, ?, ?,?,?)"
            );

            $stmtPago->execute([$mensaje, $id, $servicio, $nombreArchivo, $vigencia]);

            jsonOk("Mensaje enviado correctamente");
            }

          
        }


        if ($action == "detalle_usuario") {
            $id = intval($_GET['id'] ?? 0);

            // 1️⃣ Traer la asignación de pagos del usuario
            $stmtPago = $pdo->prepare("SELECT * FROM asignaciones_pagos WHERE usuario_id  = :id ORDER BY id DESC LIMIT 1");
            $stmtPago->bindValue(':id', $id, PDO::PARAM_INT);
            $stmtPago->execute();
            $asignacion = $stmtPago->fetch(PDO::FETCH_ASSOC);

            // 2️⃣ Traer servicios activos del usuario
            $stmtServicios = $pdo->prepare("SELECT id, categoria, titulo FROM servicios WHERE usuario_id = :id AND estado='activo'");
            $stmtServicios->bindValue(':id', $id, PDO::PARAM_INT);
            $stmtServicios->execute();
            $servicios = $stmtServicios->fetchAll(PDO::FETCH_ASSOC);


            $stmtPromo = $pdo->prepare("SELECT * FROM promociones WHERE  estado='activo'");
            $stmtPromo->execute();
            $promos = $stmtPromo->fetchAll(PDO::FETCH_ASSOC);


            $stmtUsuario = $pdo->prepare("SELECT * FROM usuarios WHERE  id=$id");
            $stmtUsuario->execute();
            $usuario = $stmtUsuario->fetch(PDO::FETCH_ASSOC);

            // 3️⃣ Construir la respuesta uniendo ambos
            $respuesta = [
                'asignacion_pago' => $asignacion,
                'cantidad_servicios' => count($servicios),
                'servicios' => $servicios,
                'promociones' => $promos,
                'usuario' => $usuario
            ];

            jsonOk($respuesta);
        }

        if ($action == "reasignarplan") {
            require __DIR__ . '/vendor/autoload.php';

            $dotenv = Dotenv\Dotenv::createImmutable(__DIR__);
            $dotenv->load();

            $id = $_POST["id"] ?? 0;
            $stmtUsuario = $pdo->prepare("SELECT * FROM asignaciones_pagos WHERE  usuario_id=$id ORDER BY id desc LIMIT 1");
            $stmtUsuario->execute();
            $usuario = $stmtUsuario->fetch(PDO::FETCH_ASSOC);
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
                jsonError("Error al enviar datos: $error_msg");
            } else {
                jsonOk($response);
            }
            curl_close($ch);
        }



        if ($action === 'list_clientes') {
            $limit = max(1, intval($_GET['limit'] ?? 50));
            $offset = max(0, intval($_GET['offset'] ?? 0));
            $q = trim($_GET['q'] ?? '');
            $estado = $_GET['estado'] ?? '';

            $sql = "
SELECT u.*,
ap.dias AS dias,
       ap.id AS asignacion_id,
       ap.descripcion_plan,
       ap.monto AS pago_monto,
       ap.fecha_asignada AS pago_fecha,
       ap.estado AS pago_estado
FROM usuarios AS u
LEFT JOIN asignaciones_pagos AS ap
  ON ap.id = (
      SELECT ap2.id
      FROM asignaciones_pagos AS ap2
      WHERE ap2.usuario_id = u.id
      ORDER BY  ap2.id DESC
      LIMIT 1
  )
WHERE 1=1
    ";

            $params = [];

            if ($q !== '') {
                $sql .= " AND (LOWER(u.nombres) LIKE :q OR LOWER(u.email) LIKE :q) ";
                $params[':q'] = '%' . mb_strtolower($q) . '%';
            }

            if ($estado === 'activo') $sql .= " AND u.estado='ACTIVO' ";
            else if ($estado === 'inactivo') $sql .= " AND u.estado='INACTIVO' ";

            $sql .= " ORDER BY u.id DESC, ap.fecha_asignada DESC LIMIT :limit OFFSET :offset";

            $stmt = $pdo->prepare($sql);
            foreach ($params as $k => $v) $stmt->bindValue($k, $v);
            $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
            $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
            $stmt->execute();
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            $total = intval($pdo->query("SELECT FOUND_ROWS()")->fetchColumn());

            jsonOk([
                'items'  => $rows,
                'total'  => $total,
                'limit'  => $limit,
                'offset' => $offset
            ]);
        }

        if ($action === 'toggle_estadoCliente') {
            $id = intval($_POST['id'] ?? 0);
            if ($id <= 0) jsonError('ID inválido');
            $row = $pdo->query("SELECT estado FROM usuarios WHERE id=$id")->fetch(PDO::FETCH_ASSOC);
            if (!$row) jsonError('Cliente no encontrado');
            $new = "";
            switch ($row['estado']) {
                case 'ACTIVO':
                    $new = 'inactivo';
                    break;
                case 'PENDIENTE':
                    $new = 'activo';
                    break;
                case 'INACTIVO':
                    $new = 'activo';
                    break;
            }
            $pdo->prepare("UPDATE usuarios SET estado=? WHERE id=?")->execute([strtoupper($new), $id]);
            jsonOk('OK');
        }
        if ($action === 'deleteCliente') {
            $id = intval($_POST['id'] ?? 0);
            if ($id <= 0) jsonError('ID inválido');
            $row = $pdo->query("SELECT id FROM usuarios WHERE id=$id")->fetch(PDO::FETCH_ASSOC);

            if (!$row) jsonError('Usuario no encontrad');
            $pdo->prepare("DELETE FROM usuarios WHERE id=?")->execute([$id]);

            jsonOk('Usuario Eliminado Correctamente');
        }
        //CUPONES
        if ($action === 'list_cupones') {
            $limit = max(1, intval($_GET['limit'] ?? 50));
            $offset = max(0, intval($_GET['offset'] ?? 0));
            $q = trim($_GET['q'] ?? '');
            $estado = $_GET['estado'] ?? '';

            $sql = "
        SELECT SQL_CALC_FOUND_ROWS * 
        FROM cupones AS u
        WHERE 1=1
    ";

            $params = [];

            if ($q !== '') {
                $sql .= " AND (LOWER(u.codigo) LIKE :q OR LOWER(u.descripcion) LIKE :q) ";
                $params[':q'] = '%' . mb_strtolower($q) . '%';
            }

            if ($estado === 'activo') {
                $sql .= " AND u.activo='1' ";
            } else if ($estado === 'inactivo') {
                $sql .= " AND u.activo='0' ";
            }

            $sql .= " ORDER BY u.id DESC LIMIT :limit OFFSET :offset";

            $stmt = $pdo->prepare($sql);

            foreach ($params as $k => $v) {
                $stmt->bindValue($k, $v);
            }

            $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
            $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
            $stmt->execute();

            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $total = intval($pdo->query("SELECT FOUND_ROWS()")->fetchColumn());

            jsonOk([
                'items'  => $rows,
                'total'  => $total,
                'limit'  => $limit,
                'offset' => $offset
            ]);
        }


        if ($action === 'toggle_estado_cupon') {
            try {
                $id = intval($_POST['id'] ?? 0);
                if ($id <= 0) jsonError('ID inválido');
                $row = $pdo->query("SELECT * FROM cupones WHERE id=$id")->fetch(PDO::FETCH_ASSOC);
                if (!$row) jsonError('Cupon no encontrada');
                $new = 1;
                if ($row["activo"] == 1) {
                    $new = 0;
                }
                $operacion = "modificar";
                $promo_id = $row["id_promocion"];
                $cupon_id = $row["id_cupon_stripe"];
                include_once('stripe_modificar_cupon.php');
                $pdo->prepare("UPDATE cupones SET activo=? WHERE id=?")->execute([$new, $id]);
                jsonOk('Cupón Modificado correctamente.');
            } catch (\Throwable $th) {
                jsonError($th->getMessage());
            }
        }

        if ($action === 'eliminarcupon') {
            try {
                $id = intval($_POST['id'] ?? 0);
                if ($id <= 0) jsonError('ID inválido');
                $row = $pdo->query("SELECT * FROM cupones WHERE id=$id")->fetch(PDO::FETCH_ASSOC);
                if (!$row) jsonError('Cupon no encontrada');
                $operacion = "eliminar";
                $promo_id = $row["id_promocion"];
                $cupon_id = $row["id_cupon_stripe"];
                include_once('stripe_modificar_cupon.php');
                $pdo->prepare("DELETE FROM cupones  WHERE id=?")->execute([$id]);
                jsonOk('Cupón Eliminado Correctamente');
            } catch (\Throwable $th) {
                jsonError($th->getMessage());
            }
        }



        // --categorias.--
        if ($action === 'toggle_estadocate') {
            $id = intval($_POST['id'] ?? 0);
            if ($id <= 0) jsonError('ID inválido');
            $row = $pdo->query("SELECT estado FROM categorias WHERE id=$id")->fetch(PDO::FETCH_ASSOC);
            if (!$row) jsonError('Categoria no encontrada');
            $new = "activo";
            if ($row["estado"] == "activo") {
                $new = "inactivo";
            }
            $pdo->prepare("UPDATE categorias SET estado=? WHERE id=?")->execute([$new, $id]);
            jsonOk('OK');
        }
        if ($action === 'listarcate') {
            $id = intval($_GET['id'] ?? 0);
            if ($id <= 0) jsonError('ID inválido');

            $stmt = $pdo->query("SELECT * FROM categorias WHERE id = $id")->fetch(PDO::FETCH_ASSOC);
            if (!$stmt) jsonError('Categoría no encontrada');
            jsonOk($stmt);
        }

        if ($action === 'eliminarcategoria') {
            $id = intval($_POST['id'] ?? 0);
            if ($id <= 0) jsonError('ID inválido');
            $row = $pdo->query("SELECT estado FROM categorias WHERE id=$id")->fetch(PDO::FETCH_ASSOC);
            if (!$row) jsonError('Categoria no encontrada');

            $pdo->prepare("DELETE FROM categorias  WHERE id=?")->execute([$id]);
            jsonOk('Categoria Eliminada Correctamente');
        }


        if ($action === 'list_categorias') {
            $limit = max(1, intval($_GET['limit'] ?? 50));
            $offset = max(0, intval($_GET['offset'] ?? 0));
            $q = trim($_GET['q'] ?? '');
            $estado = $_GET['estado'] ?? '';

            $sql = "SELECT SQL_CALC_FOUND_ROWS 
                c.id AS categoria_id, 
                c.nombre AS categoria_nombre, 
                c.descripcion AS categoria_descripcion, 
                c.estado AS categoria_estado, 
                c.created_at AS categoria_fecha,
                s.id AS sub_id, 
                s.nombre AS sub_nombre, 
                s.descripcion AS sub_descripcion
            FROM categorias AS c
            LEFT JOIN subcategorias AS s ON c.id = s.categoria_id
            WHERE 1=1 ";

            $params = [];

            // Filtro de búsqueda
            if ($q !== '') {
                if (is_numeric($q)) {
                    $sql .= " AND (c.id = :id OR LOWER(c.nombre) LIKE :q OR LOWER(c.descripcion) LIKE :q) ";
                    $params[':id'] = (int)$q;
                    $params[':q'] = '%' . mb_strtolower($q) . '%';
                } else {
                    $sql .= " AND (LOWER(c.nombre) LIKE :q OR LOWER(c.descripcion) LIKE :q) ";
                    $params[':q'] = '%' . mb_strtolower($q) . '%';
                }
            }

            // Filtro por estado
            if ($estado === 'activo') {
                $sql .= " AND c.estado='activo' ";
            } elseif ($estado === 'inactivo') {
                $sql .= " AND c.estado='inactivo' ";
            }

            // Orden + límite
            $sql .= " ORDER BY c.id DESC LIMIT :limit OFFSET :offset";

            $stmt = $pdo->prepare($sql);
            foreach ($params as $k => $v) {
                $stmt->bindValue($k, $v);
            }
            $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
            $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
            $stmt->execute();

            // Agrupar categorías con sus subcategorías
            $categorias = [];
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                $cat_id = $row['categoria_id'];
                if (!isset($categorias[$cat_id])) {
                    $categorias[$cat_id] = [
                        'id' => $cat_id,
                        'nombre' => $row['categoria_nombre'],
                        'descripcion' => $row['categoria_descripcion'],
                        'estado' => $row['categoria_estado'],
                        'fecha_creacion' => $row['categoria_fecha'],
                        'subcategorias' => []
                    ];
                }

                if (!empty($row['sub_id'])) {
                    $categorias[$cat_id]['subcategorias'][] = [
                        'id' => $row['sub_id'],
                        'nombre' => $row['sub_nombre'],
                        'descripcion' => $row['sub_descripcion']
                    ];
                }
            }

            $total = intval($pdo->query("SELECT FOUND_ROWS()")->fetchColumn());
            jsonOk([
                'items' => array_values($categorias),
                'total' => $total,
                'limit' => $limit,
                'offset' => $offset
            ]);
        }

        //usuarios---

        if ($action === 'list_usuarios') {
            $q = trim($_GET['q'] ?? '');
            $estado = $_GET['estado'] ?? '';
            $sql = "SELECT SQL_CALC_FOUND_ROWS * FROM usuarios  WHERE admin='si' AND  1=1 ";
            $params = [];
            if (is_numeric($q)) {
                // Buscar por ID si es un número
                $sql .= " AND (id = :id OR LOWER(email) LIKE :q OR LOWER(nombres) LIKE :q) ";
                $params[':id'] = (int)$q;
                $params[':q'] = '%' . mb_strtolower($q) . '%';
            } else {
                // Solo búsqueda por texto
                $sql .= " AND (LOWER(email) LIKE :q OR LOWER(nombres) LIKE :q) ";
                $params[':q'] = '%' . mb_strtolower($q) . '%';
            }
            if ($estado === 'activo') $sql .= " AND estado='activo' ";
            else if ($estado === 'inactivo') $sql .= " AND estado='inactivo' ";
            $stmt = $pdo->prepare($sql);
            foreach ($params as $k => $v) $stmt->bindValue($k, $v);
            $stmt->execute();
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $total = intval($pdo->query("SELECT FOUND_ROWS()")->fetchColumn());
            jsonOk(['items' => $rows, 'total' => $total]);
        }
        if ($action === 'eliminarusuario') {
            $id = intval($_POST['id'] ?? 0);
            if ($id <= 0) jsonError('ID inválido');
            $row = $pdo->query("SELECT estado FROM usuarios WHERE id=$id")->fetch(PDO::FETCH_ASSOC);
            if (!$row) jsonError('Usuario no encontrado');

            $pdo->prepare("DELETE FROM usuarios  WHERE id=?")->execute([$id]);
            jsonOk('Usuario Eliminado Correctamente');
        }
        if ($action === 'toggle_estadousuario') {
            $id = intval($_POST['id'] ?? 0);
            if ($id <= 0) jsonError('ID inválido');
            $row = $pdo->query("SELECT estado FROM usuarios WHERE id=$id")->fetch(PDO::FETCH_ASSOC);
            if (!$row) jsonError('Usuario no encontrado');
            $new = "ACTIVO";
            if ($row["estado"] == "ACTIVO") {
                $new = "INACTIVO";
            }
            $pdo->prepare("UPDATE usuarios SET estado=? WHERE id=?")->execute([$new, $id]);
            jsonOk('OK');
        }

        // --- Listar servicios ---
        if ($action === 'list_servicios') {
            $limit = max(1, intval($_GET['limit'] ?? 50));
            $offset = max(0, intval($_GET['offset'] ?? 0));
            $q = trim($_GET['q'] ?? '');
            $estado = $_GET['estado'] ?? '';
            $sql = "SELECT SQL_CALC_FOUND_ROWS * FROM vis_serviciosAdmin WHERE 1=1 ";
            $params = [];
            if (is_numeric($q)) {
                // Buscar por ID si es un número
                $sql .= " AND (id = :id OR LOWER(titulo) LIKE :q OR LOWER(descripcion) LIKE :q OR LOWER(nombre_publicador) LIKE :q) ";
                $params[':id'] = (int)$q;
                $params[':q'] = '%' . mb_strtolower($q) . '%';
            } else {
                // Solo búsqueda por texto
                $sql .= " AND (LOWER(titulo) LIKE :q OR LOWER(descripcion) LIKE :q OR LOWER(nombre_publicador) LIKE :q) ";
                $params[':q'] = '%' . mb_strtolower($q) . '%';
            }
            if ($estado === 'activo') $sql .= " AND estado='activo' ";
            else if ($estado === 'pendiente') $sql .= " AND estado='pendiente' ";
            else if ($estado === 'inactivo') $sql .= " AND estado='inactivo' ";

            $sql .= " ORDER BY (estado='pendiente') DESC, fecha_creacion DESC LIMIT :limit OFFSET :offset";
            $stmt = $pdo->prepare($sql);
            foreach ($params as $k => $v) $stmt->bindValue($k, $v);
            $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
            $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
            $stmt->execute();
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $total = intval($pdo->query("SELECT FOUND_ROWS()")->fetchColumn());
            jsonOk(['items' => $rows, 'total' => $total, 'limit' => $limit, 'offset' => $offset]);
        }

        // --- Toggle estado servicio ---
        if ($action === 'toggle_estado') {
            $id = intval($_POST['id'] ?? 0);
            if ($id <= 0) jsonError('ID inválido');
            $row = $pdo->query("SELECT estado FROM servicios WHERE id=$id")->fetch(PDO::FETCH_ASSOC);
            if (!$row) jsonError('Servicio no encontrado');
            $new = "";
            switch ($row['estado']) {
                case 'activo':
                    $new = 'inactivo';
                    break;
                case 'pendiente':
                    $new = 'activo';
                    break;
                case 'inactivo':
                    $new = 'activo';
                    break;
            }
            $pdo->prepare("UPDATE servicios SET estado=? WHERE id=?")->execute([$new, $id]);
            jsonOk('OK');
        }
        // --- Eliminar Servicios ---

        if ($action === 'delete') {
            $id = intval($_POST['id'] ?? 0);
            $mensaje = $_POST["mensaje"] ?? '';
            if ($id <= 0) jsonError('ID inválido');
            $row = $pdo->query("SELECT usuario_id,titulo FROM servicios WHERE id=$id LIMIT 1")->fetch(PDO::FETCH_ASSOC);

            if (!$row) jsonError('Servicio no encontrado');
            $tit = $row["titulo"] ?? "";
            $pdo->prepare("DELETE FROM servicios WHERE id=?")->execute([$id]);
            if (!empty($mensaje) && $mensaje != "null") {
                $pdo->prepare("INSERT INTO servicios_mensajes(mensaje,usuario_id,servicio)  VALUES(?,?,?)")->execute([$mensaje, $row['usuario_id'], strtoupper($tit)]);
            }
            jsonOk('Servicio Eliminado Correctamente');
        }

        //codigos

        if ($action === 'list_codigos_publicacion') {

            $limit  = max(1, intval($_GET['limit'] ?? 25));
            $offset = max(0, intval($_GET['offset'] ?? 0));
            $q      = trim($_GET['q'] ?? '');
            $estado = $_GET['estado'] ?? '';

            // Consulta base
            $sql = "SELECT SQL_CALC_FOUND_ROWS c.*
            FROM codigos_publicacion c
            WHERE 1=1 ";
            $params = [];

            // Filtro búsqueda por código o descripción
            if ($q !== '') {
                $sql .= " AND (LOWER(c.codigo) LIKE :q OR LOWER(c.descripcion) LIKE :q) ";
                $params[':q'] = '%' . mb_strtolower($q) . '%';
            }

            // Filtro estado
            if ($estado === 'activo') {
                $sql .= " AND c.activo = 1 ";
            } elseif ($estado === 'inactivo') {
                $sql .= " AND c.activo = 0 ";
            }

            // Orden + paginación
            $sql .= " ORDER BY c.creado_en DESC LIMIT :limit OFFSET :offset";

            $stmt = $pdo->prepare($sql);

            // Bind parámetros
            foreach ($params as $k => $v) {
                $stmt->bindValue($k, $v);
            }

            $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
            $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);

            $stmt->execute();

            $rows  = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $total = intval($pdo->query("SELECT FOUND_ROWS()")->fetchColumn());

            jsonOk([
                'items'  => $rows,
                'total'  => $total,
                'limit'  => $limit,
                'offset' => $offset
            ]);
        }
        if ($action === "save_codigo_publicacion") {

            $codigo       = trim($_POST['codigo'] ?? '');
            $descripcion  = trim($_POST['descripcion'] ?? '');
            $dias         = intval($_POST['dias'] ?? 0);
            $fecha_inicio = trim($_POST['fecha_inicio'] ?? '');

            if ($codigo === '' || $dias <= 0 || $fecha_inicio === '') {
                jsonError("Completa todos los campos requeridos.");
            }

            $fechaInicioDT = new DateTime($fecha_inicio);
            $fechaFinDT    = clone $fechaInicioDT;
            $fechaFinDT->modify("+{$dias} days");

            $fecha_fin = $fechaFinDT->format("Y-m-d");

            // Verificar si ya existe un código igual
            $sqlCheck = "SELECT COUNT(*) FROM codigos_publicacion WHERE codigo = ?";
            $count = $pdo->prepare($sqlCheck);
            $count->execute([$codigo]);

            if ($count->fetchColumn() > 0) {
                jsonError("El código ya existe.");
            }

            // Insertar nuevo código
            $sql = "INSERT INTO codigos_publicacion 
            (codigo, descripcion, dias_gratis, fecha_inicio, fecha_fin, activo, creado_en)
            VALUES (?, ?, ?, ?, ?, 1, NOW())";

            $stmt = $pdo->prepare($sql);
            $stmt->execute([
                $codigo,
                $descripcion,
                $dias,
                $fecha_inicio,
                $fecha_fin
            ]);

            jsonOk("Código registrado correctamente.");
        }

        if ($action === 'eliminar_codigo') {
            $id = intval($_POST['id'] ?? 0);
            if ($id <= 0) jsonError('ID inválido');
            $row = $pdo->query("SELECT * FROM codigos_publicacion WHERE id=$id LIMIT 1")->fetch(PDO::FETCH_ASSOC);
            if (!$row) jsonError('Codigo no encontrado');
            $pdo->prepare("DELETE FROM codigos_publicacion WHERE id=?")->execute([$id]);
            jsonOk('Codigo Eliminado Correctamente');
        }
        if ($action === 'toggle_estado_codigo') {
            $id = intval($_POST['id'] ?? 0);
            if ($id <= 0) jsonError('ID inválido');
            $row = $pdo->query("SELECT activo FROM codigos_publicacion WHERE id=$id LIMIT 1")->fetch(PDO::FETCH_ASSOC);
            if (!$row) jsonError('Codigo no encontrado');
            $newesta = $row["activo"] == 1 ? 0 : 1;
            $pdo->prepare("UPDATE codigos_publicacion SET activo=? WHERE id=?")->execute([$newesta, $id]);
            jsonOk('Codigo Modificado Correctamente');
        }

        // --- Listar promociones por cliente ---
        if ($action === 'list_promos') {
            $limit = max(1, intval($_GET['limit'] ?? 25));
            $offset = max(0, intval($_GET['offset'] ?? 0));
            $q = trim($_GET['q'] ?? '');
            $estado = $_GET['estado'] ?? '';
            $sql = "SELECT SQL_CALC_FOUND_ROWS p.*
                    FROM promociones p 
                    WHERE 1=1 ";
            $params = [];
            if ($q !== '') {
                $sql .= " AND (LOWER(p.titulo) LIKE :q ) ";
                $params[':q'] = '%' . mb_strtolower($q) . '%';
            }
            if ($estado === 'activo') $sql .= " AND p.estado='activo' ";
            else if ($estado === 'inactivo') $sql .= " AND p.estado='inactivo' ";
            $sql .= " ORDER BY p.fecha DESC LIMIT :limit OFFSET :offset";
            $stmt = $pdo->prepare($sql);
            foreach ($params as $k => $v) $stmt->bindValue($k, $v);
            $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
            $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
            $stmt->execute();
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $total = intval($pdo->query("SELECT FOUND_ROWS()")->fetchColumn());
            jsonOk(['items' => $rows, 'total' => $total, 'limit' => $limit, 'offset' => $offset]);
        }
        if ($action == "loadconfig") {
            $sql = "SELECT * FROM configuraciones LIMIT 1";
            $stmt = $pdo->prepare($sql);
            $stmt->execute();
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            jsonOk($row);
        }

        if ($action == "save_config") {
            // Recibir valores del POST
            try {
                $nombre = $_POST['nombre_sistema'] ?? '';
                $moneda = $_POST['moneda_sistema'] ?? '';
                $wsp = $_POST['wsp'] ?? '';
                $contacto = $_POST['contacto'] ?? '';

                // Manejar la subida del logo si hay archivo
                $logoPath = null;
                if (isset($_FILES['logo_sistema']) && $_FILES['logo_sistema']['error'] == 0) {
                    $ext = pathinfo($_FILES['logo_sistema']['name'], PATHINFO_EXTENSION);
                    $filename = 'logo_' . time() . '.' . $ext;
                    $target = __DIR__ . '/uploads/' . $filename; // carpeta uploads
                    if (move_uploaded_file($_FILES['logo_sistema']['tmp_name'], $target)) {
                        $logoPath = 'uploads/' . $filename;
                    }
                }

                // Guardar o actualizar la configuración
                // Asumiendo que solo hay una fila en la tabla configuraciones
                $row = $pdo->query("SELECT COUNT(*) FROM configuraciones")->fetchColumn();

                if ($row > 0) {
                    // Actualizar
                    $sql = "UPDATE configuraciones SET nombre_sistema = ?, moneda = ?,wsp=?,telefono=?";
                    $params = [$nombre, $moneda, $wsp, $contacto];
                    if ($logoPath) {
                        $sql .= ", logo = ?";
                        $params[] = $logoPath;
                    }
                    $pdo->prepare($sql)->execute($params);
                } else {
                    // Insertar
                    $sql = "INSERT INTO configuraciones (nombre_sistema, moneda, logo,wsp,telefono) VALUES (?, ?, ?,?,?)";
                    $pdo->prepare($sql)->execute([$nombre, $moneda, $logoPath, $wsp, $contacto]);
                }

                jsonOk('Configuración guardada correctamente');
            } catch (\Throwable $th) {
                jsonError($th->getMessage());
            }
        }

        // --- Agregar / Editar promo ---
        if ($action === 'add_promo' || $action === 'edit_promo') {
            $id = intval($_POST['id'] ?? 0);
            $titulo = $_POST['titulo'] ?? '';
            $desc = $_POST['descripcion'] ?? '';
            $costo = intval($_POST['costo'] ?? 0);
            $tipo = $_POST['tipo'] ?? "";
            $categoria = $_POST['categoria'] ?? null;
            $vigencia = $_POST['vigencia'] ?? null;
            $estado = $_POST['estado'] ?? 'activo';
            if ($action === 'add_promo') {
                $stmt = $pdo->prepare("INSERT INTO promociones(titulo,descripcion,costo,tipo,categoria,estado,dias_vigencia) VALUES(?,?,?,?,?,?,?)");
                $stmt->execute([strtoupper($titulo), $desc, $costo, $tipo, $categoria, $estado, $vigencia]);
                jsonOk(['id' => $pdo->lastInsertId()]);
            } else {
                if ($id <= 0) jsonError('ID inválido');
                $stmt = $pdo->prepare("UPDATE promociones SET titulo=?,descripcion=?,descuento=?,fecha_inicio=?,fecha_fin=?,estado=?,dias_vigencia=? WHERE id=?");
                $stmt->execute([$cliente, $titulo, $desc, $descuento, $fi, $ff, $estado, $id, $vigencia]);
                jsonOk('OK');
            }
        }
        if ($action === 'delete_promo') {
            $id = intval($_POST['id'] ?? 0);
            if ($id <= 0) jsonError('ID inválido');
            $row = $pdo->query("SELECT id FROM promociones WHERE id=$id")->fetch(PDO::FETCH_ASSOC);

            if (!$row) jsonError('Promocion no encontrada');
            $pdo->prepare("DELETE FROM promociones WHERE id=?")->execute([$id]);

            jsonOk('Promocion Eliminada Correctamente');
        }

        if ($action === 'toggle_estado_promo') {
            $id = intval($_POST['id'] ?? 0);
            if ($id <= 0) jsonError('ID inválido');
            $row = $pdo->query("SELECT estado FROM promociones WHERE id=$id")->fetch(PDO::FETCH_ASSOC);
            if (!$row) jsonError('Servicio no encontrado');
            $new = "";
            switch ($row['estado']) {
                case 'activo':
                    $new = 'inactivo';
                    break;
                case 'inactivo':
                    $new = 'activo';
                    break;
            }
            $pdo->prepare("UPDATE promociones SET estado=? WHERE id=?")->execute([$new, $id]);
            jsonOk('OK');
        }

        jsonError("Acción desconocida: $action");
    } catch (Exception $e) {
        jsonError($e->getMessage());
    }
}
