<?php
header('Content-Type: application/json');

try {
    // Conexión a la base de datos
        include_once("conexion.php");


    // Capturamos los datos del formulario
    $email = trim($_POST['email'] ?? '');
    $nombres = trim($_POST['nombres'] ?? '');
    $password = trim($_POST['password'] ?? '');
    $estado = $_POST['estado'] ?? 'activo';

    // Validaciones
    if ($email === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        echo json_encode(['status' => 'error', 'mensaje' => 'Debe ingresar un correo electrónico válido.']);
        exit;
    }

    if ($nombres === '') {
        echo json_encode(['status' => 'error', 'mensaje' => 'El nombre es obligatorio.']);
        exit;
    }

    if ($password === '') {
        echo json_encode(['status' => 'error', 'mensaje' => 'La contraseña es obligatoria.']);
        exit;
    }

    if (!in_array($estado, ['activo', 'inactivo'])) {
        echo json_encode(['status' => 'error', 'mensaje' => 'Estado no válido.']);
        exit;
    }

    // Verificar si el email ya existe
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM usuarios WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetchColumn() > 0) {
        echo json_encode(['status' => 'error', 'mensaje' => 'El correo ya está registrado.']);
        exit;
    }

    // Encriptar contraseña
    $hash = password_hash($password, PASSWORD_BCRYPT);

    // Insertar usuario
    $sql = "INSERT INTO usuarios (email, nombres, pass, estado,admin) 
            VALUES (:email, :nombres, :password, :estado ,'si')";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([
        ':email' => strtolower($email),
        ':nombres' => strtoupper($nombres),
        ':password' => $hash,
        ':estado' => strtoupper($estado)
    ]);

    echo json_encode(['status' => 'ok', 'mensaje' => 'Usuario registrado correctamente.']);
} catch (PDOException $e) {
    echo json_encode([
        'status' => 'error',
        'mensaje' => 'Error en base de datos: ' . $e->getMessage()
    ]);
}
