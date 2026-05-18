<?php
header('Content-Type: application/json; charset=utf-8');

try {
    include_once("conexion.php");


    $sql = "SELECT * FROM categorias WHERE estado='activo'";
    $stmt = $pdo->prepare($sql);
    $stmt->execute();

    // Traer todos los resultados
    $categorias = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'status' => 'ok',
        'categorias' => $categorias
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    echo json_encode([
        'status' => 'error',
        'mensaje' => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
