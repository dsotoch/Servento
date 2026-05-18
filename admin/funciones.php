<?php
function respond($data, $code = 200)
{
    http_response_code($code);
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit;
}

function getJsonInput()
{
    $raw = file_get_contents('php://input');
    $data = json_decode($raw, true);
    return is_array($data) ? $data : [];
}


function select($pdo, $consulta, $parametros = [])
{
    try {
        $stmt = $pdo->prepare($consulta);
        $stmt->execute($parametros);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        throw new Exception("Error en la consulta SQL: " . $e->getMessage());
    }
}


function insertInto($pdo, string $consulta, array $parametros = []): array
{
    try {
        $stmt = $pdo->prepare($consulta);
        $stmt->execute($parametros);
        $filasAfectadas = $stmt->rowCount();

        if ($filasAfectadas > 0) {
            return [
                "success" => true,
                "mensaje" => "Registro insertado correctamente",
                "insert_id" => $pdo->lastInsertId(),
            ];
        } else {
            return [
                "success" => false,
                "mensaje" => "No se insertó ningún registro",
            ];
        }
    } catch (PDOException $e) {
        return [
            "success" => false,
            "mensaje" => "Error en la consulta SQL: " . $e->getMessage(),
        ];
    }
}

function eliminarRegistro($pdo, string $consulta, array $parametros = []): array
{
    try {
        $stmt = $pdo->prepare($consulta);
        $stmt->execute($parametros);

        $filasAfectadas = $stmt->rowCount();

        if ($filasAfectadas > 0) {
            return [
                "success" => true,
                "mensaje" => "Registro eliminado correctamente",
            ];
        } else {
            return [
                "success" => false,
                "mensaje" => "No se encontró el registro a eliminar",
            ];
        }
    } catch (PDOException $e) {
        throw new Exception($e->getMessage());
    }
}

function editarRegistro($pdo, string $consulta, array $parametros = []): array
{
    try {
        $stmt = $pdo->prepare($consulta);
        $stmt->execute($parametros);

        $filasAfectadas = $stmt->rowCount();

        if ($filasAfectadas > 0) {
            return [
                "success" => true,
                "mensaje" => "Registro modificado correctamente",
            ];
        } else {
            return [
                "success" => false,
                "mensaje" => "No se encontró el registro a modificar",
            ];
        }
    } catch (PDOException $e) {
        throw new Exception($e->getMessage());
    }
}
