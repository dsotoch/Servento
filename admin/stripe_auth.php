<?php
require 'vendor/autoload.php';
$dotenv = Dotenv\Dotenv::createImmutable(__DIR__);
$dotenv->load();
$apikey = $_ENV["TEST"] == "SI" ? $_ENV['STRIPE_SECRET_KEY_TEST'] : $_ENV['STRIPE_SECRET_KEY'];
\Stripe\Stripe::setApiKey($apikey);
