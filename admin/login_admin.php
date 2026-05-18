<?php
declare(strict_types=1);
session_start();

require_once 'conexion.php';

$email = trim($_POST['usuario'] ?? '');
$clave = $_POST['clave'] ?? '';

if ($email === '' || $clave === '') {
    header("Location: index.php?error=" . urlencode("Debe ingresar usuario y contraseña."));
    exit;
}

try {
    $sql = "SELECT id, email, pass, admin, nombres FROM usuarios WHERE email = :email LIMIT 1";
    $stmt = $pdo->prepare($sql);
    $stmt->bindValue(':email', $email, PDO::PARAM_STR);
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$row) {
        header("Location: index.php?error=" . urlencode("Usuario no encontrado."));
        exit;
    }

    if (strtolower($row['admin']) !== 'si' && $row['admin'] !== '1') {
        header("Location: index.php?error=" . urlencode("No tienes permisos de administrador."));
        exit;
    }

    $storedHash = $row['pass'];

    if (password_verify($clave, $storedHash) || $storedHash === $clave) {
        // Si la contraseña estaba en texto plano, la actualizamos a hash
        if ($storedHash === $clave) {
            $newHash = password_hash($clave, PASSWORD_DEFAULT);
            $upd = $pdo->prepare("UPDATE usuarios SET pass = :pass WHERE id = :id");
            $upd->execute([':pass' => $newHash, ':id' => $row['id']]);
        }

        // Iniciar sesión
        session_regenerate_id(true);
        $_SESSION['admin_logged'] = true;
        $_SESSION['admin_id'] = $row['id'];
        $_SESSION['admin_email'] = $row['email'];
        $_SESSION['admin_name'] = $row['nombres'] ?? '';

        header("Location: panelAdmin.php");
        exit;
    } else {
        header("Location: index.php?error=" . urlencode("Contraseña incorrecta."));
        exit;
    }

} catch (PDOException $e) {
    header("Location: index.php?error=" . urlencode("Error en la base de datos."));
    exit;
}
