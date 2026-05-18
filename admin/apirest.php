<?php
include_once('conexion.php');

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *'); // ajustar en producción
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}
require_once('funciones.php');

// Routing (simple) --------------------------------------
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

$scriptName = $_SERVER['SCRIPT_NAME'];
$base = rtrim(dirname($scriptName), '/\\');
$path = substr($uri, strlen($base));
$segments = array_values(array_filter(explode('/', $path), fn($v) => $v !== ''));

$resourceIndex = 0;
if ($segments[0] === basename($scriptName)) {
    $resourceIndex = 1;
}

$resource = $segments[$resourceIndex] ?? null;
$id = isset($segments[$resourceIndex + 1]) ? (int)$segments[$resourceIndex + 1] : null;
$method = $_SERVER['REQUEST_METHOD'];

if ($resource == "categorias") {
    if ($method === 'GET') {
        require_once("categoriasApi.php");
        $loguearse = listarCategorias();
        respond($loguearse);
    }
}
if ($resource == "chat") {
    if ($method === 'GET') {
        require_once("chats.php");
        $destinatario = $_GET["destinatario"] ?? "";
        $tipo = $_GET["tipo"] ?? "";
        if ($tipo == "nuevos") {
            $loguearse = obtenerClientesNuevosMensajes();
        } else {
            if ($destinatario != "") {
                $loguearse = obtenerMensajes();
            } else {
                $loguearse = obtenerClientes();
            }
        }

        respond($loguearse);
    }

    if ($method === 'POST') {
        require_once("chats.php");
        $loguearse = guardarMensaje();
        respond($loguearse);
    }
}
if ($resource == "config") {
    if ($method === 'GET') {
        require_once("categoriasApi.php");
        $loguearse = listarConf();
        respond($loguearse);
    }
}
if ($resource == "iniciarsesion") {
    if ($method === 'POST') {
        $in = getJsonInput();
        $pass = trim($in['pass'] ?? '');
        $user = trim($in['user'] ?? '');
        require_once("login.php");
        $loguearse = iniciarSesion($user, $pass);
        respond($loguearse);
    }
}

if ($resource == "usuario") {
    set_error_handler(function ($severity, $message, $file, $line) {
        throw new ErrorException($message, 0, $severity, $file, $line);
    });

    register_shutdown_function(function () {
        $error = error_get_last();
        if ($error) {
            respond([
                "success" => false,
                "mensaje" => "Fatal error: " . $error['message']
            ]);
        }
    });
    if ($method === 'POST') {
        $in = getJsonInput();
        $user = trim($in['usuario'] ?? '');
        $pass = trim($in['pass'] ?? '');
        $email = trim($in['email'] ?? '');
        $telefono = trim($in['telefono'] ?? '');

        require_once("usuario.php");
        $registrar = registrarUsuario($user, $pass, $email,$telefono);
        respond($registrar);
    }
    if ($method == "GET") {
        respond(["data" => "probadnao"]);
    }
    if ($method === 'PUT') {
        try {
            $in = getJsonInput();
            $user = trim($in['nombres'] ?? '');
            $pass = trim($in['pass'] ?? '');
            $email = $in['email'] ?? null;
            $id = trim($in['id'] ?? '');
            $telefono = trim($in['telefono'] ?? '');
            $wsp = trim($in['wsp'] ?? '');
            $img1 = isset($in['img1']) && strtolower(trim($in['img1'])) !== 'null' ? trim($in['img1']) : '';
            $img2 = isset($in['img2']) && strtolower(trim($in['img2'])) !== 'null' ? trim($in['img2']) : '';
            $img3 = isset($in['img3']) && strtolower(trim($in['img3'])) !== 'null' ? trim($in['img3']) : '';
            $fotoBase64 = isset($in['foto']) && strtolower(trim($in['foto'])) !== 'null' ? trim($in['foto']) : '';

            $direccion = trim($in['direccion'] ?? '');
            require_once("usuario.php");
            $actualisar = actualizarUsuario($id, $user, $pass, $email, $fotoBase64, $direccion, $telefono, $wsp, $img1, $img2, $img3);
            respond($actualisar);
        } catch (\Throwable $th) {
            respond(["success" => false, "mensaje" => $th->getMessage()]);
        }
    }
}
if ($resource == "servicios") {
    if ($method == "POST") {
        $in = getJsonInput();
        $titulo = trim($in['titulo'] ?? '');
        $descripcion = trim($in['descripcion'] ?? '');
        $precio = floatval($in['precio'] ?? 0);
        $ubicacion = trim($in['ubicacion'] ?? '');
        $categoria = trim($in['categoria'] ?? '');
        $sub = trim($in['subcategoria'] ?? '');

        $usuario_id = intval($in['usuario_id'] ?? 0);
        $estado = 'pendiente';
        $lat = trim($in['lat'] ?? '');
        $long = trim($in['long'] ?? '');

        include_once('servicios.php');
        $imagen1 = guardarImagen($in['imagen1'] ?? '', 'img1');
        $imagen2 = guardarImagen($in['imagen2'] ?? '', 'img2');
        $imagen3 = guardarImagen($in['imagen3'] ?? '', 'img3');
        $crear = guardarServicio($titulo, $descripcion, $precio, $ubicacion, $categoria, $usuario_id, $estado, $imagen1, $imagen2, $imagen3, $lat, $long, $sub);
        respond($crear);
    }
    if ($method == "PUT") {
        $in = getJsonInput();

        $titulo = trim($in['titulo'] ?? '');
        $descripcion = trim($in['descripcion'] ?? '');
        $precio = floatval($in['precio'] ?? 0);
        $ubicacion = trim($in['ubicacion'] ?? '');
        $categoria = trim($in['categoria'] ?? '');
        $usuario_id = intval($in['usuario_id'] ?? 0);
        $id = intval($in['id'] ?? 0);
        $estado = $in['estado'] ?? 'activo';
        $lat = trim($in['lat'] ?? '');
        $long = trim($in['long'] ?? '');
        include_once('servicios.php');

        $nuevasImagenes = [];
        foreach (['imagen1', 'imagen2', 'imagen3'] as $key) {
            if (isset($in[$key]) && $in[$key] !== null && trim($in[$key]) !== '' && $in[$key] !== 'null') {
                $nuevasImagenes[] = guardarImagen($in[$key], $key);
            }
        }


        $resultado = modificarServicioConVariasImagenes(
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
            $nuevasImagenes
        );

        respond($resultado);
    }
    if ($method == "DELETE") {

        $id = intval($_GET['id'] ?? 0);
        $tipo = $_GET["tipo"] ?? "";

        include_once('servicios.php');
        $resultado = [];
        if ($tipo == "estado") {
            $resultado = cambiarEstado($id);
        } else {
            $resultado = eliminarServicio($id);
        }

        respond($resultado);
    }


    if ($method == "GET") {
        $id = $_GET["id"] ?? 0;
        $tipo = $_GET["tipo"] ?? "";
        $offset = $_GET['offset'] ?? 0;
        $limit = $_GET['limit'] ?? 100;
        $lat = $_GET["lat"] ?? null;
        $lon = $_GET["long"] ?? null;
        $radio = $_GET["radio"] ?? null;
        include_once('servicios.php');

        $resultado = [];
        switch ($tipo) {
            case 'todos':
                $resultado = listarServiciosTodos($offset, $limit, $lat, $lon, $radio);
                break;
            case 'comentarios':
                $resultado = listarComentarios($id);
                break;

            default:
                $resultado = listarServicios($id);
                break;
        }

        respond($resultado);
    }
}
if ($resource == "comentario") {
    if ($method == "POST") {
        $in = getJsonInput();
        $comentario = $in["comentario"] ?? "";
        $estrellas = $in["estrellas"] ?? '';
        $usuario_id = $in["usuario_id"] ?? 0;
        $servicio_id = $in["servicio_id"] ?? 0;
        require_once("servicios.php");
        $inser = guardarComentarios($comentario, $estrellas, $usuario_id, $servicio_id);
        respond($inser);
    }
}

if ($resource == "favoritos") {
    if ($method == "POST") {
        $in = getJsonInput();
        $usuario_id = $in["usuario_id"] ?? 0;
        $servicio_id = $in["servicio_id"] ?? 0;
        require_once("servicios.php");
        $inser = guardarFavorito($usuario_id, $servicio_id);
        respond($inser);
    }
    if ($method == "DELETE") {
        $usuario_id = $_GET["usuario_id"] ?? 0;
        $servicio_id = $_GET["servicio_id"] ?? 0;
        require_once("servicios.php");
        $inser = eliminarFavorito($usuario_id, $servicio_id);
        respond($inser);
    }
    if ($method == "GET") {
        $usuario_id = $_GET["usuario_id"] ?? 0;
        require_once("servicios.php");
        $inser = listarFavorito($usuario_id);
        respond($inser);
    }
}
if ($resource == "cupones") {
    if ($method == "POST") {
        $in = getJsonInput();
        $tipo = $in["tipo"] ?? "";
        $cupon = $in["cupon"] ?? 0;
        $paymentid = $in["paymentid"] ?? 0;
        require_once("cuponeslogica.php");
        $inser = "";

        switch ($tipo) {
            case 'validar':
                $inser = validarCupon($cupon, $paymentid);
                break;
        }

        respond($inser);
    }
    if ($method == "GET") {
        $cupon = $_GET["codigo"] ?? 0;
        require_once("cuponeslogica.php");

        $inser = validarCodigo($cupon);

        respond($inser);
    }
}
if ($resource == "promociones") {
    if ($method == "POST") {
        $in = getJsonInput();
        $usuario_id = $in["usuario_id"] ?? 0;
        $servicio_id = $in["servicio_id"] ?? 0;
        $tipo = $in["tipo"] ?? "";
        $promocion = $in["id_promocion"] ?? 0;

        require_once("servicios.php");
        if ($tipo == "asignar") {
            $inser = AsignarPromocion($promocion, $usuario_id);
        } else {
            $inser = guardarFavorito($usuario_id, $servicio_id);
        }
        respond($inser);
    }

    if ($method == "DELETE") {
        $usuario_id = $_GET["usuario_id"] ?? 0;
        $servicio_id = $_GET["servicio_id"] ?? 0;
        require_once("servicios.php");
        $inser = eliminarFavorito($usuario_id, $servicio_id);
        respond($inser);
    }
    if ($method == "GET") {
        $tipo = $_GET["tipo"] ?? "";
        $id = $_GET["id"] ?? 0;
        $cantidad = $_GET["cantidad"] ?? 0;
        $viene = $_GET["viene"] ?? "";

        require_once("comentarios.php");
        $inser = "";

        switch ($tipo) {
            case 'msj':
                $inser = listarMensajes($id);
                break;
            case 'msjnuevos':
                $inser = listarMensajesNuevos($id, $viene);
                break;
            case "pagos":
                $inser = listaPlan($id);
                break;
            case "pagosge":
                $inser = listaPlanTodos($id);
                break;
            case "secret":
                $inser = paymentSecret($id);
                break;
            default:
                $inser = listarComentarios();
                break;
        }


        respond($inser);
    }
}

// Si no coincide resource
respond(['error' => 'Recurso no encontrado'], 404);
