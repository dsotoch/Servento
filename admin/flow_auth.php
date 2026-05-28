<?php
require_once "env.php";

function firmarParametros(array $params)
{
    $secretKey = $_ENV["TEST"] == "SI"
        ? $_ENV["FLOW_SECRET_KEY_TEST"]
        : $_ENV["FLOW_SECRET_KEY"];;
    $keys = array_keys($params);
    sort($keys);
    $toSign = "";
    foreach ($keys as $key) {
        $toSign .= $key . $params[$key];
    };
    $signature = hash_hmac('sha256', $toSign, $secretKey);
    return $signature;
}

function crearCuponFlow($nombre, $monto, $fecha_expiracion)
{
    $url_dominio = $_ENV["TEST"] == "SI"
        ? $_ENV["URL_FLOW_TEST"]
        : $_ENV["URL_FLOW"];

    $api_key = $_ENV["TEST"] == "SI"
        ? $_ENV["FLOW_API_KEY_TEST"]
        : $_ENV["FLOW_API_KEY"];

    $url = $url_dominio . "/coupon/create";
    $data = array(
        "apiKey" => $api_key,
        "name" => $nombre,
        "currency" => "PEN",
        "amount" => $monto,
        "expires" => $fecha_expiracion
    );
    $data["s"] = firmarParametros($data);

    $ch = curl_init($url);

    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($data));

    $response = curl_exec($ch);

    curl_close($ch);

    return json_decode($response);
}
function eliminarCuponFlow($couponId)
{
    $url_dominio = $_ENV["TEST"] == "SI"
        ? $_ENV["URL_FLOW_TEST"]
        : $_ENV["URL_FLOW"];

    $api_key = $_ENV["TEST"] == "SI"
        ? $_ENV["FLOW_API_KEY_TEST"]
        : $_ENV["FLOW_API_KEY"];

    $url = $url_dominio . "/coupon/delete";
    $data = array(
        "apiKey" => $api_key,
        "couponId" => $couponId,

    );
    $data["s"] = firmarParametros($data);

    $ch = curl_init($url);

    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($data));

    $response = curl_exec($ch);

    curl_close($ch);
    file_put_contents(
        "flow_log.txt",
        $response . PHP_EOL,
        FILE_APPEND
    );
    return json_decode($response);
}

function crearOrdenPago($monto, $email)
{
    $url_dominio = $_ENV["TEST"] == "SI"
        ? $_ENV["URL_FLOW_TEST"]
        : $_ENV["URL_FLOW"];

    $api_key = $_ENV["TEST"] == "SI"
        ? $_ENV["FLOW_API_KEY_TEST"]
        : $_ENV["FLOW_API_KEY"];

    $return = $_ENV["DOMINIO"];

    $url = $url_dominio . "/payment/create";
    $data = [
        "apiKey" => $api_key,
        "commerceOrder" => "ORDEN_" . time(),
        "subject" => "Pago en Servento",
        "currency" => "PEN",
        "amount" => $monto,
        "email" => $email,
        "paymentMethod" => 9,
        "urlConfirmation" =>  $return . "/flow_confirmacion.php",
        "urlReturn" => $return . "/gracias.php",
    ];

    $data["s"] = firmarParametros($data);

    $ch = curl_init($url);

    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($data));

    $response = curl_exec($ch);

    curl_close($ch);
    file_put_contents(
        "flow_log.txt",
        $response . PHP_EOL,
        FILE_APPEND
    );
    return json_decode($response);
}
function getOrdenPago($token)
{
    $url_dominio = $_ENV["TEST"] == "SI"
        ? $_ENV["URL_FLOW_TEST"]
        : $_ENV["URL_FLOW"];

    $api_key = $_ENV["TEST"] == "SI"
        ? $_ENV["FLOW_API_KEY_TEST"]
        : $_ENV["FLOW_API_KEY"];

    $data = [
        "apiKey" => $api_key,
        "token"  => $token
    ];

    // Firmar
    $data["s"] = firmarParametros($data);

    // Construir query string
    $query = http_build_query($data);

    // URL final
    $url = $url_dominio . "/payment/getStatus?" . $query;

    $ch = curl_init($url);

    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

    $response = curl_exec($ch);

    curl_close($ch);

    return json_decode($response);
}
