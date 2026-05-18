<?php
include_once("conexion.php");

/**
 * Ejecuta una sentencia DELETE de manera segura.
 *
 * @param PDO $pdo Conexión PDO
 * @param string $sql Sentencia SQL DELETE
 * @return int Cantidad de filas eliminadas
 */
function ejecutarDelete(PDO $pdo, string $sql): int
{
    try {
        $stmt = $pdo->prepare($sql);
        $stmt->execute();
        return $stmt->rowCount(); // retorna filas eliminadas
    } catch (PDOException $e) {
        file_put_contents(
            'webhook_log.txt',
            date('Y-m-d H:i:s') . " - " . $e->getMessage() . "\n",
            FILE_APPEND
        );
        return 0;
    }
}

// Eliminar datos
$eliminados3 = ejecutarDelete($pdo, "DELETE FROM pagos");
/*$eliminados1 = ejecutarDelete($pdo, " DELETE FROM usuarios 
                WHERE `admin` != 'si' OR `admin` IS NULL
                ");*/
$eliminados2 = ejecutarDelete($pdo, "DELETE FROM servicios");
$eliminados3 = ejecutarDelete($pdo, "DELETE FROM promociones");
$eliminados4 = ejecutarDelete($pdo, "DELETE FROM servicios_mensajes");
$eliminados5 = ejecutarDelete($pdo, "DELETE FROM mensajes");
$eliminados6 = ejecutarDelete($pdo, "DELETE FROM recordatorios");
$eliminados7 = ejecutarDelete($pdo, "DELETE FROM subcategorias");
$eliminados8 = ejecutarDelete($pdo, "DELETE FROM categorias");
$eliminados9 = ejecutarDelete($pdo, "DELETE FROM favoritos");
$eliminados10 = ejecutarDelete($pdo, "DELETE FROM cupones");
$eliminados11 = ejecutarDelete($pdo, "DELETE FROM codigos_publicacion");

header("Location: panelAdmin.php");
exit();
