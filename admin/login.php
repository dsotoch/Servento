<?php
function iniciarSesion($user, $pass)
{
    global $pdo;

    try {

        $sql = "SELECT * FROM usuarios WHERE email = ?";
        $usuarios = select($pdo, $sql, [$user]);

        $usuario = $usuarios[0] ?? null;

        if (!$usuario) {
            return [
                "success" => false,
                "mensaje" => "Usuario o contraseña incorrectos"
            ];
        }

        // VALIDAR PASSWORD
        if (!password_verify($pass, $usuario["pass"])) {
            return [
                "success" => false,
                "mensaje" => "Usuario o contraseña incorrectos"
            ];
        }

        // ESTADO
        if ($usuario["estado"] == "pendiente") {
            return [
                "success" => true,
                "mensaje" => "Correo no verificado",
                "telefono" => $usuario["telefono"],
                "data" => $usuario["id"]
            ];
        }
        if ($usuario["estado"] == "validado") {
            return [
                "success" => true,
                "mensaje" => "Cuentanoverificada",
                "telefono" => $usuario["telefono"],
                "data" => $usuario["id"]
            ];
        }
        if ($usuario["estado"] == "INACTIVO") {
            return [
                "success" => false,
                "mensaje" => "Cuenta inactiva"
            ];
        }

        return [
            "success" => true,
            "mensaje" => "Inicio de sesión correcto",
            "data" => $usuario
        ];
    } catch (Exception $e) {

        return [
            "success" => false,
            "mensaje" => "Error al iniciar sesión: " . $e->getMessage()
        ];
    }
}
