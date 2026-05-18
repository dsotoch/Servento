<?php
function iniciarSesion($user, $pass)
{
    global $pdo;

    try {
        $sql = "SELECT * FROM usuarios WHERE email = ? AND estado IN('ACTIVO','pendiente','INACTIVO')";
        $parametros = [$user];

        $usuarios = select($pdo, $sql, $parametros);
        $usuario = $usuarios[0] ?? null;


        if ($usuario) {
            if ($usuario["estado"] == "pendiente") {
                return [
                    "success" => true,
                    "mensaje" => "CuentanoVerificada",
                    "telefono"=>$usuario["telefono"],
                     "data" =>
                    $usuario['id']
                ];
            } else {
                return [
                    "success" => true,
                    "mensaje" => "Inicio de sesión correcto",
                    "data" =>
                    $usuario

                ];
            }
        } else {
            return [
                "success" => false,
                "mensaje" => "Usuario o contraseña incorrectos"
            ];
        }
    } catch (Exception $e) {
        return [
            "success" => false,
            "mensaje" => "Error al iniciar sesión: " . $e->getMessage()
        ];
    }
}
