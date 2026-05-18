<?php
include_once("conexion.php");
$sql = "SELECT * FROM configuraciones LIMIT 1";
$stmt = $pdo->prepare($sql);
$stmt->execute();
$row = $stmt->fetch(PDO::FETCH_ASSOC);
$logo = $row["logo"] ?? "";
$nombre = $row["nombre_sistema"] ?? "";

?>
<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Login Administrador | <?= $nombre ?></title>
    <link rel="shortcut icon" href="<?=$logo ?>" type="image/x-icon">
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        :root {
            --color-principal: #9f0b8e;
        }

        .btn-principal {
            background-color: var(--color-principal) !important;
        }

        .btn-principal:hover {
            background-color:  #c727b4; !important;
        }

        .texto-principal {
            color: var(--color-principal);
        }

        .borde-principal {
            border-color: var(--color-principal);
        }
    </style>
</head>

<body class="bg-gradient-to-br from-[#9f0b8e] to-black min-h-screen flex items-center justify-center">

    <div class="bg-gradient-to-br from-[#9f0b8e] to-purple-800 shadow-2xl rounded-3xl p-8 w-full max-w-sm text-center border-t-4 border-[#9f0b8e]">
    <!-- Logo -->
    <div class="flex justify-center mb-6">
        <img src="<?= $logo ?>" alt="Logo Empresa" 
             class="w-24 h-24 rounded-full shadow-lg border-4 border-white">
    </div>

    <!-- Título -->
    <h1 class="text-xl font-bold text-white mb-6"><?= $nombre ?> - Administrador</h1>

    <!-- Formulario -->
    <form action="login_admin.php" method="POST" class="space-y-5 text-left">
        <div>
            <label for="usuario" class="block font-semibold text-white mb-1">Usuario</label>
            <input type="text" id="usuario" name="usuario" required
                class="w-full border border-white bg-white/10 text-white placeholder-white rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-[#9f0b8e] placeholder-opacity-70">
        </div>

        <div>
            <label for="clave" class="block font-semibold text-white mb-1">Contraseña</label>
            <input type="password" id="clave" name="clave" required
                class="w-full border border-white bg-white/10 text-white placeholder-white rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-[#9f0b8e] placeholder-opacity-70">
        </div>

        <button type="submit"
            class="w-full bg-white text-black py-2 rounded-lg font-semibold transition-all hover:bg-white/30 hover:shadow-lg">
            Iniciar Sesión
        </button>
    </form>

    <?php if (!empty($_GET['error'])): ?>
        <div class="mt-4 p-3 bg-red-100 border border-red-400 text-red-700 rounded-lg text-center shadow-sm animate-fadeIn">
            <?= htmlspecialchars($_GET['error']) ?>
        </div>
    <?php endif; ?>

    <p class="text-sm text-white/70 mt-5">© 2025 <?= $nombre ?>. Todos los derechos reservados.</p>
</div>

</body>

</html>