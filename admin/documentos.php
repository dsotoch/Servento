<?php
include_once("conexion.php");

// Obtener el id, por defecto 0
$id = isset($_GET['usuario_id']) ? intval($_GET['usuario_id']) : 0;

try {
    // Preparar la consulta usando placeholder para evitar inyección SQL
    $stmt = $pdo->prepare("SELECT * FROM usuarios WHERE id = :id");
    $stmt->bindParam(':id', $id, PDO::PARAM_INT);
    $stmt->execute();

    // Obtener el resultado
    $data = $stmt->fetch(PDO::FETCH_ASSOC);

    // Enviar como JSON
    header('Content-Type: application/json');
    if ($data) {
        echo json_encode([
            'success' => true,
            'data' => $data
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Usuario no encontrado'
        ]);
    }
} catch (PDOException $e) {
    // Manejo de error
    header('Content-Type: application/json');
    echo json_encode([
        'success' => false,
        'message' => 'Error en la consulta: ' . $e->getMessage()
    ]);
}
