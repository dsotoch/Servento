<?php

include_once("conexion.php");

// Obtener datos del formulario
$usuario_id = intval($_POST['usuario_id'] ?? 0);
$email = trim($_POST['email_admin'] ?? '');
$new_pass = $_POST['new_pass'] ?? '';

try {
    $stmt = $pdo->prepare("UPDATE usuarios SET email = :email WHERE id = :id ");
    $stmt->execute([
        ':email' => $email,
        ':id' => $usuario_id
    ]);

    if (!empty($new_pass)) {
        $hash = password_hash($new_pass, PASSWORD_DEFAULT);
        $stmt2 = $pdo->prepare("UPDATE usuarios SET pass = :pass WHERE id = :id ");
        $stmt2->execute([
            ':pass' => $hash,
            ':id' => $usuario_id
        ]);
    }
    header("Location: panelAdmin.php?success=Datos actualizados correctamente");
    exit();
} catch (PDOException $e) {
    // Manejo de errores
    $msg = urlencode("Error al actualizar datos: " . $e->getMessage());
    header("Location: panelAdmin.php?error=$msg");
    exit();
}
