<?php 

session_start();

// Destruir toda la sesión
$_SESSION = [];
session_unset();
session_destroy();

// Redirigir al login
header("Location: index.php");
exit;
