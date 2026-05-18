<?php
function listarCategorias()
{
    global $pdo;
    $sql = "
    SELECT 
        c.id AS categoria_id,
        c.nombre AS categoria_nombre,
        c.estado AS categoria_estado,
        sc.id AS subcategoria_id,
        sc.nombre AS subcategoria_nombre,
        sc.estado AS subcategoria_estado
    FROM categorias AS c
    LEFT JOIN subcategorias AS sc ON c.id = sc.categoria_id AND sc.estado = 'activo'
    WHERE c.estado = 'activo'
    ";

    $cate = select($pdo, $sql, []);
    return [
        "success" => true,
        "mensaje" => $cate
    ];
}

function listarConf()
{

    global $pdo;
    $sql = "
    SELECT * FROM configuraciones
    ";

    $cate = select($pdo, $sql, []);
    return [
        "success" => true,
        "mensaje" => $cate
    ];
}
