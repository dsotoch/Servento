<?php
header('Content-Type: application/json');
try {
    include_once("conexion.php");

    // Capturamos los datos del formulario
    $tipo = $_POST['tipo'] ?? 'categoria';
    $nombre = trim($_POST['nombre'] ?? '');
    $descripcion = trim($_POST['descripcion'] ?? '');
    $estado = $_POST['estado'] ?? 'activo';
    $categoria_padre_id = $_POST['categoria_padre_id'] ?? null;

    // Validaciones
    if ($nombre === '') {
        echo json_encode(['status' => 'error', 'mensaje' => 'El nombre es obligatorio']);
        exit;
    }

    if (!in_array($estado, ['activo', 'inactivo'])) {
        echo json_encode(['status' => 'error', 'mensaje' => 'Estado no válido']);
        exit;
    }

    if ($tipo === 'subcategoria' && empty($categoria_padre_id)) {
        echo json_encode(['status' => 'error', 'mensaje' => 'Debe seleccionar una categoría padre para la subcategoría']);
        exit;
    }

    // Inserción según tipo
    if ($tipo === 'categoria') {
        $sql = "INSERT INTO categorias (nombre, descripcion, estado) 
                VALUES (:nombre, :descripcion, :estado)";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            ':nombre' => strtoupper($nombre),
            ':descripcion' => $descripcion,
            ':estado' => $estado
        ]);
        $mensaje = 'Categoría guardada correctamente.';
    } else {
        $sql = "INSERT INTO subcategorias (categoria_id, nombre, descripcion, estado) 
                VALUES (:categoria_id, :nombre, :descripcion, :estado)";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            ':categoria_id' => $categoria_padre_id,
            ':nombre' => strtoupper($nombre),
            ':descripcion' => $descripcion,
            ':estado' => $estado
        ]);

        // Obtener el nombre de la categoría padre
        $padre = $pdo->prepare("SELECT nombre FROM categorias WHERE id = ?");
        $padre->execute([$categoria_padre_id]);
        $nombrePadre = $padre->fetchColumn();

        $mensaje = "Subcategoría guardada correctamente bajo la categoría '$nombrePadre'.";
    }

    echo json_encode(['status' => 'ok', 'mensaje' => $mensaje]);
} catch (PDOException $e) {
    echo json_encode([
        'status' => 'error',
        'mensaje' => 'Error en base de datos: ' . $e->getMessage()
    ]);
}
