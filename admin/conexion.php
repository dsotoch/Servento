<?php
$dbHost = '127.0.0.1';
$dbName = 'u447520248_servirentafull';
$dbUser = 'u447520248_root2';
$dbPass = 'Servirentamx@1813';
$dsn = "mysql:host=$dbHost;dbname=$dbName;charset=utf8mb4";
try {
    $pdo = new PDO($dsn, $dbUser, $dbPass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    ]);
} catch (PDOException $e) {
    error_log("ERROR EN CONEXION" .$e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'DB connection failed', 'detail' => $e->getMessage()]);
    exit;
}