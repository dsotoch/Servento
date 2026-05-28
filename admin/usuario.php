<?php

use PHPMailer\PHPMailer\PHPMailer;

require_once "env.php";
require_once "vendor/autoload.php";
function validarTelefonoAndEmail($telefono, $email)
{
    global $pdo;

    $telefono = trim($telefono);
    $email = trim($email);

    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        return [
            "success" => false,
            "mensaje" => "Correo inválido"
        ];
    }

    if (!ctype_digit($telefono)) {
        return [
            "success" => false,
            "mensaje" => "El teléfono solo debe contener números."
        ];
    }

    if (strlen($telefono) != 9) {
        return [
            "success" => false,
            "mensaje" => "El número de teléfono debe contener 9 dígitos."
        ];
    }

    $stmt = $pdo->prepare("SELECT 1 FROM usuarios WHERE email = ?");
    $stmt->execute([$email]);

    if ($stmt->fetch(PDO::FETCH_ASSOC)) {
        return [
            "success" => false,
            "mensaje" => "El correo ya se encuentra registrado."
        ];
    }

    $stmt = $pdo->prepare("SELECT 1 FROM usuarios WHERE telefono = ?");
    $stmt->execute([$telefono]);

    if ($stmt->fetch(PDO::FETCH_ASSOC)) {
        return [
            "success" => false,
            "mensaje" => "El teléfono ya está registrado."
        ];
    }

    return [
        "success" => true,
        "mensaje" => "Correo y teléfono válidos."
    ];
}

function registrarUsuario($user, $pass, $email, $telefono)
{
    global $pdo;

    if (!$user || !$pass || !$email) {
        return ["success" => false, "mensaje" => "Faltan datos"];
    }
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        return ["success" => false, "mensaje" => "Correo inválido"];
    }
    try {
        $stmt = $pdo->prepare("SELECT id FROM usuarios WHERE email = ?");
        $stmt->execute([$email]);
        if ($stmt->fetch()) {
            return ["success" => false, "mensaje" => "El correo ya está registrado"];
        }
        if (!empty($telefono)) {
            $stmt = $pdo->prepare("SELECT id FROM usuarios WHERE telefono = ?");
            $stmt->execute([$telefono]);
            if ($stmt->fetch()) {
                return ["success" => false, "mensaje" => "El telefono ya está registrado"];
            }
        }
        $hash = password_hash($pass, PASSWORD_BCRYPT);
        $stmt = $pdo->prepare("INSERT INTO usuarios (email, pass, nombres ,estado,telefono) VALUES (?, ?, ?,?,?)");
        $stmt->execute([$email, $hash, strtoupper($user), 'pendiente', $telefono]);
        return [
            "success" => true,
            "mensaje" => "Registro exitoso."
        ];
    } catch (Exception $e) {
        return ["success" => false, "mensaje" => "Error en la base de datos: " . $e->getMessage()];
    }
}


function actualizarUsuario($id, $user, $pass = null, $email = null, $fotoBase64 = null, $direccion = null, $telefono = null, $wsp = null, $img1 = '', $img2 = '', $img3 = '')
{
    global $pdo;
    $ident = 0;
    $usuario = null;
    try {
        if ($id == 0) {
            $stmt = $pdo->prepare("SELECT * FROM usuarios WHERE email = ? AND telefono = ? AND wsp = ? LIMIT 1");
            $stmt->execute([trim($email), $telefono, $wsp]);
            $usuario = $stmt->fetch(PDO::FETCH_ASSOC);
            $ident = $usuario["id"] ?? 0;
        } else {
            $stmt = $pdo->prepare("SELECT * FROM usuarios WHERE id = ?");
            $stmt->execute([$id]);
            $usuario = $stmt->fetch(PDO::FETCH_ASSOC);
            $ident = $id;
        }



        if (!$usuario) {
            return ["success" => false, "mensaje" => "Usuario no encontrado"];
        }
        if (!empty($email)) {
            $stmt = $pdo->prepare("SELECT id FROM usuarios WHERE email = ? AND id <> ?");
            $stmt->execute([$email, $ident]);
            if ($stmt->fetch()) {
                return ["success" => false, "mensaje" => "El correo ya está registrado por otro usuario"];
            }
        }

        if (!empty($telefono)) {
            $stmt = $pdo->prepare("SELECT id FROM usuarios WHERE telefono = ? AND id <> ?");
            $stmt->execute([$telefono, $ident]);
            if ($stmt->fetch()) {
                return ["success" => false, "mensaje" => "El teléfono ya está registrado por otro usuario"];
            }
        }

        if (!empty($wsp)) {
            $stmt = $pdo->prepare("SELECT id FROM usuarios WHERE wsp = ? AND id <> ?");
            $stmt->execute([$wsp, $ident]);
            if ($stmt->fetch()) {
                return ["success" => false, "mensaje" => "El numero de Whatsapp ya está registrado por otro usuario"];
            }
        }
        $hash = $pass ? password_hash($pass, PASSWORD_BCRYPT) : $usuario['pass'];
        $rutaCarpeta = __DIR__ . "/uploads/usuarios/";
        if (!is_dir($rutaCarpeta)) {
            mkdir($rutaCarpeta, 0777, true);
        }

        // ---------------- Avatar principal ----------------
        $avatarGuardado = null;
        if (!empty($fotoBase64)) {
            $fotoLimpia = preg_replace('#^data:image/\w+;base64,#i', '', $fotoBase64);
            $data = base64_decode($fotoLimpia);
            if ($data === false) {
                return ["success" => false, "mensaje" => "Error al decodificar la imagen de avatar"];
            }

            $nombreArchivo = uniqid("avatar_") . ".png";
            $rutaCompleta = $rutaCarpeta . $nombreArchivo;
            file_put_contents($rutaCompleta, $data);
            $avatarGuardado = "uploads/usuarios/" . $nombreArchivo;
        }

        // ---------------- Imágenes adicionales ----------------
        $imagenes = [$img1, $img2, $img3];
        $archivosGuardados = [];

        foreach ($imagenes as $index => $img) {
            if (!empty($img)) {
                $fotoLimpia = preg_replace('#^data:image/\w+;base64,#i', '', $img);
                $data = base64_decode($fotoLimpia);
                if ($data === false) {
                    return [
                        "success" => false,
                        "mensaje" => "Error al decodificar la imagen " . ($index + 1)
                    ];
                }

                $nombreArchivo = uniqid("user_{$index}_") . ".png";
                $rutaCompleta = $rutaCarpeta . $nombreArchivo;
                file_put_contents($rutaCompleta, $data);

                $archivosGuardados[] = "uploads/usuarios/" . $nombreArchivo;
            } else {
                $archivosGuardados[] = null;
            }
        }


        if ($id == 0 || $id == "") {
            $stmt = $pdo->prepare("
            UPDATE usuarios
            SET  pass = ?
            WHERE email = ? AND telefono = ? AND wsp = ?
        ");
            $stmt->execute([
                $hash,
                $email ?? $usuario['email'],
                $telefono ?? $usuario['telefono'],
                $wsp
            ]);
            return [
                "success" => true,
                "mensaje" => "Contraseña actualizada correctamente",
            ];
        } else {
            $stmt = $pdo->prepare("
            UPDATE usuarios
            SET nombres = ?, pass = ?, email = ?, foto = ?, direccion = ?, telefono = ? , wsp = ?,img1=?,img2=?,img3=?,estado=?
            WHERE id = ?
        ");
            $stmt->execute([
                (!empty($user) ? strtoupper($user) : $usuario["nombres"]),
                $hash,
                $email ?? $usuario['email'],
                $avatarGuardado ?? $usuario['foto'],
                $direccion ?? $usuario['direccion'],
                $telefono ?? $usuario['telefono'],
                $wsp,
                $archivosGuardados[0] ?? $usuario['img1'],
                $archivosGuardados[1] ?? $usuario['img2'],
                $archivosGuardados[2] ?? $usuario['img3'],
                $archivosGuardados[0] != null ? 'ACTIVO' : $usuario['estado'],
                $ident
            ]);
            $stmt = $pdo->prepare("SELECT * FROM usuarios WHERE id = ?");
            $stmt->execute([$ident]);
            $usuario = $stmt->fetch(PDO::FETCH_ASSOC);
            return [
                "success" => true,
                "mensaje" => "Usuario actualizado correctamente",
                "data" => $usuario['foto'],
                "datos" => $usuario
            ];
        }
    } catch (Exception $e) {
        // Obtener mensaje, archivo y línea
        $mensaje = $e->getMessage();
        $archivo = $e->getFile();
        $linea = $e->getLine();

        throw new Exception("Error en $archivo en la línea $linea: $mensaje");
    }
}

function enviarActivacion($correo)
{
    global $pdo;
    $token = bin2hex(random_bytes(32));

    $enlace = $_ENV["DOMINIO"] . "/apirest.php/activarCuenta?token=$token";

    $mail = new PHPMailer(true);

    try {

        $mail->isSMTP();

        $mail->Host = $_ENV["MAIL_HOST"];

        $mail->SMTPAuth = true;

        $mail->Username = $_ENV["MAIL_USER"];

        $mail->Password = $_ENV["MAIL_PASS"];

        $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;

        $mail->Port = $_ENV["MAIL_PORT"];

        // Remitente
        $mail->setFrom(
            $_ENV["MAIL_FROM"],
            $_ENV["NOMBRE_APP"]
        );

        $mail->addAddress($correo);

        $mail->isHTML(true);

        $mail->Subject = 'Activar cuenta';

        $mail->Body = "
        <h2>Bienvenido</h2>

        <p>Haz clic para activar tu cuenta en Servento:</p>

        <a href='$enlace'
           style='
                background:#28a745;
                color:white;
                padding:12px 20px;
                text-decoration:none;
                border-radius:5px;
           '>

           Activar cuenta

        </a>
        <br>
        ";

        $mail->send();
        $stmt = $pdo->prepare("UPDATE usuarios SET estado='pendiente', token=? WHERE email=?");
        $stmt->execute([$token, $correo]);
        return [
            "success" => true,
            "token" => $token
        ];
    } catch (Exception $e) {

        return [
            "success" => false,
            "error" =>  $e->getMessage()
        ];
    }
}

function activarCuenta($token)
{
    global $pdo;
    $stmt = $pdo->prepare("UPDATE usuarios SET estado=?,token=null WHERE token=?");
    $stmt->execute(['validado', $token]);
    return [
        "Respuesta" => "Correo Verificado Correctamente"
    ];
}

function enviarReset($correo)
{
    global $pdo;
    $token = bin2hex(random_bytes(32));

    $enlace = $_ENV["DOMINIO"] . "/cambiarPassword.php?token=$token";

    $mail = new PHPMailer(true);

    try {

        $mail->isSMTP();

        $mail->Host = $_ENV["MAIL_HOST"];

        $mail->SMTPAuth = true;

        $mail->Username = $_ENV["MAIL_USER"];

        $mail->Password = $_ENV["MAIL_PASS"];

        $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;

        $mail->Port = $_ENV["MAIL_PORT"];

        // Remitente
        $mail->setFrom(
            $_ENV["MAIL_FROM"],
            $_ENV["NOMBRE_APP"]
        );

        $mail->addAddress($correo);

        $mail->isHTML(true);

        $mail->Subject = 'Recuperar cuenta';

        $mail->Body = "
        <h2>Bienvenido</h2>

        <p>Haz clic para cambiar tu contraseña en Servento:</p>

        <a href='$enlace'
           style='
                background:#28a745;
                color:white;
                padding:12px 20px;
                text-decoration:none;
                border-radius:5px;
           '>

           Cambiar Contraseña

        </a>
        <br>
        ";

        $mail->send();
        $stmt = $pdo->prepare("UPDATE usuarios SET token=? WHERE email=?");
        $stmt->execute([$token, $correo]);
        return [
            "success" => true,
            "token" => $token
        ];
    } catch (Exception $e) {

        return [
            "success" => false,
            "error" => $e->getMessage()
        ];
    }
}
