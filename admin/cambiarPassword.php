
<?php

require_once "conexion.php";

$token = $_GET["token"] ?? '';

$valido = false;

if ($token != '') {

    $stmt = $pdo->prepare("
        SELECT id 
        FROM usuarios 
        WHERE token = ?
        LIMIT 1
    ");

    $stmt->execute([$token]);

    $usuario = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($usuario) {

        $valido = true;
    }
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    $token = $_POST["token"];
    $password = $_POST["password"];

    $stmt = $pdo->prepare("
        SELECT id 
        FROM usuarios 
        WHERE token = ?
        LIMIT 1
    ");

    $stmt->execute([$token]);

    $usuario = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($usuario) {

        $hash = password_hash($password, PASSWORD_DEFAULT);

        $stmt = $pdo->prepare("
            UPDATE usuarios 
            SET pass = ?, token = NULL
            WHERE id = ?
        ");

        $stmt->execute([
            $hash,
            $usuario["id"]
        ]);

        $success = true;
    }
}
?>

<!DOCTYPE html>
<html lang="es">

<head>

    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0">

    <title>Cambiar contraseña</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {

            margin: 0;

            font-family: Arial, sans-serif;

            background:
                linear-gradient(
                    135deg,
                    #c2e7bd,
                    #86ff8c
                );

            height: 100vh;

            display: flex;

            justify-content: center;

            align-items: center;
        }

        .card {

            background: white;

            width: 400px;

            padding: 35px;

            border-radius: 20px;

            box-shadow:
                0 10px 30px rgba(0,0,0,.15);
        }

        h1 {

            margin-top: 0;

            text-align: center;

            color: #333;
        }

        p {

            color: #666;

            text-align: center;
        }

        input {

            width: 100%;

            padding: 14px;

            border-radius: 12px;

            border: 1px solid #ddd;

            margin-top: 15px;

            font-size: 15px;
        }

        button {

            width: 100%;

            border: none;

            background: #4f46e5;

            color: white;

            padding: 14px;

            border-radius: 12px;

            margin-top: 20px;

            font-size: 15px;

            cursor: pointer;

            transition: .2s;
        }

        button:hover {

            opacity: .9;
        }

        .success {

            text-align: center;

            color: #16a34a;

            font-size: 18px;
        }

        .error {

            text-align: center;

            color: #dc2626;

            font-size: 15px;
        }
    </style>

</head>

<body>

    <div class="card">

        <?php if (isset($success)): ?>

            <div class="success">

                ✅ Contraseña actualizada correctamente

            </div>

        <?php else: ?>

            <?php if ($valido): ?>

                <h1>
                    Nueva contraseña
                </h1>

                <p>
                    Ingresa tu nueva contraseña
                </p>

                <form method="POST">

                    <input
                        type="hidden"
                        name="token"
                        value="<?= htmlspecialchars($token) ?>">

                    <input
                        type="password"
                        name="password"
                        placeholder="Nueva contraseña"
                        required>

                    <button type="submit">

                        Cambiar contraseña

                    </button>

                </form>

            <?php else: ?>

                <div class="error">

                    ❌ Token inválido o expirado

                </div>

            <?php endif; ?>

        <?php endif; ?>

    </div>

</body>

</html>
