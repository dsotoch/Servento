<?php
header('Content-Type: application/json');

try {
    // Conexión a la base de datos
       include_once("conexion.php");


    // Capturamos los datos del formulario
    $id = intval($_POST['id'] ?? 0);
    $email = trim($_POST['email'] ?? '');
    $nombres = trim($_POST['nombres'] ?? '');
    $password = trim($_POST['password'] ?? '');
    $estado = $_POST['estado'] ?? 'activo';

    // Validaciones
    if ($id <= 0) {
        echo json_encode(['status' => 'error', 'mensaje' => 'ID de usuario inválido.']);
        exit;
    }

    if ($email === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        echo json_encode(['status' => 'error', 'mensaje' => 'Debe ingresar un correo electrónico válido.']);
        exit;
    }

    if ($nombres === '') {
        echo json_encode(['status' => 'error', 'mensaje' => 'El nombre es obligatorio.']);
        exit;
    }

    if (!in_array($estado, ['activo', 'inactivo'])) {
        echo json_encode(['status' => 'error', 'mensaje' => 'Estado no válido.']);
        exit;
    }

    // Verificar si el email pertenece a otro usuario
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM usuarios WHERE email = ? AND id != ?");
    $stmt->execute([$email, $id]);
    if ($stmt->fetchColumn() > 0) {
        echo json_encode(['status' => 'error', 'mensaje' => 'El correo ya está registrado en otro usuario.']);
        exit;
    }

    // Construcción dinámica del SQL
    $params = [
        ':email' => strtolower($email),
        ':nombres' => strtoupper($nombres),
        ':estado' => strtoupper($estado),
        ':id' => $id
    ];

    $sql = "UPDATE usuarios 
            SET email = :email, nombres = :nombres, estado = :estado";

    // Solo actualizar la contraseña si se envía una nueva
    if ($password !== '') {
        $hash = password_hash($password, PASSWORD_BCRYPT);
        $sql .= ", pass = :password";
        $params[':password'] = $hash;
    }

    $sql .= " WHERE id = :id";

    // Ejecutar actualización
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);

    echo json_encode(['status' => 'ok', 'mensaje' => 'Usuario actualizado correctamente.']);
} catch (PDOException $e) {
    echo json_encode([
        'status' => 'error',
        'mensaje' => 'Error en base de datos: ' . $e->getMessage()
    ]);
}
