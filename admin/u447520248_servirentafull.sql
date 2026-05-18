-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3306
-- Tiempo de generación: 22-04-2026 a las 04:05:28
-- Versión del servidor: 11.8.6-MariaDB-log
-- Versión de PHP: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `u447520248_servirentafull`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asignaciones_pagos`
--

CREATE TABLE `asignaciones_pagos` (
  `id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `descripcion_plan` varchar(255) NOT NULL,
  `monto` decimal(10,2) NOT NULL,
  `fecha_asignada` datetime NOT NULL DEFAULT current_timestamp(),
  `estado` enum('pendiente','exitoso','fallido') DEFAULT 'pendiente',
  `metodo_pago` varchar(50) DEFAULT NULL,
  `pago_id` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `codigostripe` varchar(100) DEFAULT NULL,
  `dias` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias`
--

CREATE TABLE `categorias` (
  `id` int(11) NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `estado` enum('activo','inactivo') DEFAULT 'activo',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `categorias`
--

INSERT INTO `categorias` (`id`, `nombre`, `descripcion`, `estado`, `created_at`, `updated_at`) VALUES
(7, 'VESTIDOS', 'Vestidos para todo tipo de eventos', 'activo', '2025-11-21 23:57:53', '2025-11-21 23:57:53'),
(8, 'SALONES DE EVENTOS', 'Los más funcionales', 'activo', '2025-11-21 23:59:35', '2025-11-21 23:59:35'),
(10, 'BELLEZA PARA TI', 'Todo para tu belleza', 'activo', '2025-11-22 00:05:28', '2025-11-22 00:05:28'),
(11, 'FOTOGRAFIA Y VIDEO', 'Los mejores recuerdos', 'activo', '2025-11-22 12:21:22', '2025-11-22 12:21:22'),
(13, 'ORGANIZADORES DE EVENTOS', 'Profesionalismo para organizar tu evento', 'activo', '2025-11-23 13:30:53', '2025-11-23 13:30:53'),
(14, 'EQUIPO Y MOBILIARIO PARA EVENTOS', 'Todo tipo de mobiliario y equipo para eventos', 'activo', '2025-11-23 13:31:57', '2025-11-23 13:31:57'),
(17, 'FLORERIAS', 'hermosas flores', 'activo', '2025-11-26 00:57:09', '2025-11-26 00:57:09');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `codigos_publicacion`
--

CREATE TABLE `codigos_publicacion` (
  `id` int(11) NOT NULL,
  `codigo` varchar(50) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `dias_gratis` int(11) NOT NULL DEFAULT 0,
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `codigos_publicacion`
--

INSERT INTO `codigos_publicacion` (`id`, `codigo`, `descripcion`, `dias_gratis`, `fecha_inicio`, `fecha_fin`, `activo`, `creado_en`) VALUES
(7, 'alta', 'publicacion gratis', 15, '2025-12-07', '2025-12-22', 1, '2025-12-08 01:32:36'),
(8, 'nuevo', 'una publicacion gratis', 30, '2026-05-30', '2026-06-29', 1, '2026-04-16 23:57:55');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comentarios`
--

CREATE TABLE `comentarios` (
  `id` int(11) NOT NULL,
  `comentario` text DEFAULT NULL,
  `id_servicio` int(11) NOT NULL,
  `estrellas` int(11) DEFAULT NULL,
  `fecha_creacion` datetime DEFAULT current_timestamp(),
  `usuario_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `configuraciones`
--

CREATE TABLE `configuraciones` (
  `id` int(11) NOT NULL,
  `nombre_sistema` varchar(255) NOT NULL,
  `moneda` varchar(10) NOT NULL DEFAULT 'usd',
  `logo` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `wsp` varchar(50) DEFAULT NULL,
  `telefono` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `configuraciones`
--

INSERT INTO `configuraciones` (`id`, `nombre_sistema`, `moneda`, `logo`, `created_at`, `updated_at`, `wsp`, `telefono`) VALUES
(1, 'cuca la curra', 'mxn', 'uploads/logo_1764121693.png', '2025-11-05 05:45:15', '2026-04-17 03:39:19', '4631064067', '4631064067');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cupones`
--

CREATE TABLE `cupones` (
  `id` int(11) NOT NULL,
  `codigo` varchar(50) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `monto_descuento` decimal(10,2) DEFAULT NULL,
  `tipo` enum('porcentaje','monto') DEFAULT 'porcentaje',
  `vigencia_inicio` datetime NOT NULL,
  `vigencia_fin` datetime NOT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `id_cupon_stripe` varchar(100) DEFAULT NULL,
  `creado_en` timestamp NULL DEFAULT current_timestamp(),
  `id_promocion` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `cupones`
--

INSERT INTO `cupones` (`id`, `codigo`, `descripcion`, `monto_descuento`, `tipo`, `vigencia_inicio`, `vigencia_fin`, `activo`, `id_cupon_stripe`, `creado_en`, `id_promocion`) VALUES
(12, 'registroprueba', 'condonacion', 5.00, 'porcentaje', '2025-11-26 00:00:00', '2025-12-02 00:00:00', 1, 'PqH6Twfy', '2025-11-26 15:55:13', 'promo_1SXl3i2LsYRcAOwZbJDZAyqv'),
(15, 'Alta', 'Servicio', 5.00, 'porcentaje', '2025-12-02 00:00:00', '2025-12-05 00:00:00', 1, 'khcOYWCt', '2025-12-03 00:55:20', 'promo_1Sa4LgRxluGmmUIzNmw8Ti0W'),
(16, 'nuevo', 'una publicacion gratis', 100.00, 'porcentaje', '2026-04-16 00:00:00', '2026-05-30 00:00:00', 1, '9yOuosXc', '2026-04-16 23:57:02', 'promo_1TMzmM2LsYRcAOwZdqrEQDpK');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `favoritos`
--

CREATE TABLE `favoritos` (
  `id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `servicio_id` int(11) NOT NULL,
  `fecha_creacion` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `favoritos`
--

INSERT INTO `favoritos` (`id`, `usuario_id`, `servicio_id`, `fecha_creacion`) VALUES
(9, 30, 34, '2026-04-12 04:37:58');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mensajes`
--

CREATE TABLE `mensajes` (
  `id` int(11) NOT NULL,
  `remitente` varchar(50) NOT NULL,
  `destinatario` varchar(50) NOT NULL,
  `mensaje` text NOT NULL,
  `fecha` timestamp NULL DEFAULT current_timestamp(),
  `leido` tinyint(1) DEFAULT 0,
  `usuario` varchar(250) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `mensajes`
--

INSERT INTO `mensajes` (`id`, `remitente`, `destinatario`, `mensaje`, `fecha`, `leido`, `usuario`) VALUES
(16, '26', '18', 'Buenos días me interesa tu anuncio', '2025-11-27 07:01:53', 1, 'LUIS PRECIADO'),
(17, '18', '26', 'sí claro con gusto te podemos cotizar', '2025-11-27 07:04:48', 1, 'JOSé GONZALEZ'),
(18, '31', '32', 'hola me interesas 😘😘', '2025-11-29 08:44:17', 1, 'JOSE GONZALEZ'),
(19, '32', '31', 'Hola buen día, en qué le puedo servir', '2025-11-29 08:45:56', 1, 'MARíA DE LOS ÁNGELES VALENZUELA GáLVEZ'),
(20, '33', '31', 'buenas tardes', '2025-12-02 19:56:53', 1, 'JOSE GONZALEZ'),
(21, '33', '31', 'necesito info', '2025-12-02 19:56:59', 1, 'JOSE GONZALEZ'),
(22, '31', '32', 'me puede enviar condiciones de la renta', '2025-12-04 18:33:48', 1, 'JOSE GONZALEZ'),
(23, '33', '32', 'buenas tardes', '2025-12-07 18:57:39', 1, 'JOSE GONZALEZ');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pagos`
--

CREATE TABLE `pagos` (
  `id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `stripe_payment_intent_id` varchar(100) NOT NULL,
  `stripe_charge_id` varchar(100) DEFAULT NULL,
  `monto` decimal(10,2) NOT NULL,
  `moneda` varchar(10) DEFAULT 'usd',
  `descripcion` varchar(255) DEFAULT NULL,
  `estado` enum('pendiente','exitoso','fallido') DEFAULT 'pendiente',
  `metodo_pago` varchar(50) DEFAULT NULL,
  `fecha_pago` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `promociones`
--

CREATE TABLE `promociones` (
  `id` int(11) NOT NULL,
  `titulo` varchar(100) DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `costo` int(11) DEFAULT NULL,
  `tipo` enum('general','nuevo_usuario','categoria','publicacion','dias','golden') DEFAULT 'general',
  `categoria` varchar(100) DEFAULT NULL,
  `estado` varchar(50) DEFAULT 'activo',
  `fecha` datetime DEFAULT current_timestamp(),
  `dias_vigencia` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `recordatorios`
--

CREATE TABLE `recordatorios` (
  `id` int(11) NOT NULL,
  `cliente_id` varchar(20) DEFAULT NULL,
  `fecha_pago` varchar(30) DEFAULT NULL,
  `fecha_recordatorio` varchar(30) DEFAULT NULL,
  `estado` varchar(30) DEFAULT 'activo'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `recordatorios`
--

INSERT INTO `recordatorios` (`id`, `cliente_id`, `fecha_pago`, `fecha_recordatorio`, `estado`) VALUES
(3, '32', '2025-12-04', '2025-12-10', 'inactivo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `servicios`
--

CREATE TABLE `servicios` (
  `id` int(11) NOT NULL,
  `titulo` varchar(150) NOT NULL,
  `descripcion` text NOT NULL,
  `precio` decimal(10,2) NOT NULL DEFAULT 0.00,
  `ubicacion` varchar(255) DEFAULT NULL,
  `categoria` varchar(100) DEFAULT NULL,
  `imagen1` varchar(255) DEFAULT NULL,
  `imagen2` varchar(255) DEFAULT NULL,
  `imagen3` varchar(255) DEFAULT NULL,
  `estado` enum('activo','inactivo','pendiente') DEFAULT 'activo',
  `usuario_id` int(11) NOT NULL,
  `fecha_creacion` datetime DEFAULT current_timestamp(),
  `lat` varchar(50) DEFAULT NULL,
  `long` varchar(50) DEFAULT NULL,
  `subcategoria` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `servicios`
--

INSERT INTO `servicios` (`id`, `titulo`, `descripcion`, `precio`, `ubicacion`, `categoria`, `imagen1`, `imagen2`, `imagen3`, `estado`, `usuario_id`, `fecha_creacion`, `lat`, `long`, `subcategoria`) VALUES
(37, 'terraza', 'salón de eventos', 2500.00, 'Centro Sur, Calle Independencia, Tlaquepaque, San Pedro Tlaquepaque, Región Centro, Jalisco, 45601, México', 'SALONES DE EVENTOS', 'uploads/servicios/img1_69e177d5f2fb6.png', 'uploads/servicios/img2_69e177d5f326a.png', 'uploads/servicios/img3_69e177d5f336d.png', 'activo', 34, '2026-04-16 23:59:18', '20.6032825', '-103.4016237', 'Sin subcategoría');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `servicios_mensajes`
--

CREATE TABLE `servicios_mensajes` (
  `id` int(11) NOT NULL,
  `mensaje` text DEFAULT NULL,
  `usuario_id` int(11) NOT NULL,
  `fecha` datetime DEFAULT current_timestamp(),
  `servicio` text DEFAULT NULL,
  `imagen` varchar(100) DEFAULT NULL,
  `vigencia` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `subcategorias`
--

CREATE TABLE `subcategorias` (
  `id` int(11) NOT NULL,
  `categoria_id` int(11) NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `estado` enum('activo','inactivo') DEFAULT 'activo',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `subcategorias`
--

INSERT INTO `subcategorias` (`id`, `categoria_id`, `nombre`, `descripcion`, `estado`, `created_at`, `updated_at`) VALUES
(5, 7, 'VESTIDOS DE NOVIA', 'Los más hermosos vestidos de novia', 'activo', '2025-11-21 23:58:33', '2025-11-21 23:58:33'),
(9, 7, 'VESTIDOS DE XV AñOS', 'Muy hermosos', 'activo', '2025-11-22 00:02:10', '2025-11-22 00:02:10'),
(10, 10, 'SALONES DE BELLEZA', 'Todo', 'activo', '2025-11-22 00:05:49', '2025-11-22 00:05:49'),
(11, 10, 'SPA', 'Reconfortante', 'activo', '2025-11-22 00:06:20', '2025-11-22 00:06:20'),
(12, 7, 'VESTIDOS DE GALA', 'Galas', 'activo', '2025-11-25 22:55:43', '2025-11-25 22:55:43'),
(13, 7, 'VESTIDOS DE PRIMERA COMUNIóN Y CONFIRMACIóN', 'Iglesia', 'activo', '2025-11-25 23:15:56', '2025-11-25 23:15:56'),
(14, 7, 'VESTIDOS DE PRIMERA COMUNIóN Y CONFIRMACIóN', 'Iglesia', 'inactivo', '2025-11-25 23:15:56', '2025-11-27 04:44:28'),
(15, 10, 'MAQUILLISTAS', 'el mejor maquillaje', 'activo', '2025-11-26 00:58:04', '2025-11-26 00:58:04'),
(16, 11, 'FOTOGRAFIA', 'servicio de fotografia', 'inactivo', '2025-11-26 15:44:54', '2025-11-27 04:56:35'),
(17, 11, 'FOTOGRAFIA', 'servicio de fotografia', 'activo', '2025-11-26 15:44:54', '2025-11-26 15:44:54'),
(18, 11, 'VIDEO', 'servicios de video profesional', 'activo', '2025-11-26 15:45:35', '2025-11-27 04:56:18'),
(20, 13, 'WEDDING PLANNER', 'me encargo de todo', 'activo', '2025-12-09 12:18:06', '2025-12-09 12:18:06');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id` int(11) NOT NULL,
  `email` varchar(200) DEFAULT NULL,
  `pass` varchar(100) DEFAULT NULL,
  `nombres` varchar(250) NOT NULL,
  `estado` varchar(25) DEFAULT 'ACTIVO',
  `foto` varchar(100) DEFAULT NULL,
  `direccion` varchar(150) DEFAULT NULL,
  `telefono` varchar(150) DEFAULT NULL,
  `fecha_creacion` datetime DEFAULT current_timestamp(),
  `wsp` varchar(50) DEFAULT NULL,
  `admin` varchar(10) DEFAULT NULL,
  `img1` varchar(100) DEFAULT NULL,
  `img2` varchar(100) DEFAULT NULL,
  `img3` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id`, `email`, `pass`, `nombres`, `estado`, `foto`, `direccion`, `telefono`, `fecha_creacion`, `wsp`, `admin`, `img1`, `img2`, `img3`) VALUES
(34, 'ztegrisjl@gmail.com', '$2y$10$ypAIqh1JFzQ2ZlzJ/3SZl.LMRkWotWwRS9KdOUX5DSERIq7X2hk8S', 'JOSE GONZALEZ', 'ACTIVO', NULL, '', '4631096535', '2026-04-15 18:21:10', '4631096535', NULL, 'uploads/usuarios/user_0_69e036f44fed9.png', 'uploads/usuarios/user_1_69e036f450666.png', 'uploads/usuarios/user_2_69e036f450b4a.png'),
(35, 'dsoto6155@gmail.com', '$2y$10$U6cqDa6AIRCU6mI1WX5.luT.QxkAM9/6HuzKzYEEzsF1SdhYcLWma', 'DIEGO SOTO CHAVARRIA', 'ACTIVO', NULL, '', '9167159911', '2026-04-16 14:10:42', '5191671599', NULL, 'uploads/usuarios/user_0_69e0ef4bb789e.png', 'uploads/usuarios/user_1_69e0ef4bba7f2.png', 'uploads/usuarios/user_2_69e0ef4bbd809.png');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vis_comentarios`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vis_comentarios` (
`id_comentario` int(11)
,`id_servicio` int(11)
,`usuario_id` int(11)
,`nombre_calificador` varchar(250)
,`comentario` text
,`estrellas` int(11)
,`fecha_creacion` datetime
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vis_servicios`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vis_servicios` (
`id` int(11)
,`subcategoria` varchar(100)
,`imagen1` varchar(255)
,`imagen2` varchar(255)
,`imagen3` varchar(255)
,`titulo` varchar(150)
,`descripcion` text
,`precio` decimal(10,2)
,`ubicacion` varchar(255)
,`categoria` varchar(100)
,`estado` enum('activo','inactivo','pendiente')
,`usuario_id` int(11)
,`contacto` varchar(150)
,`wsp` varchar(50)
,`long` varchar(50)
,`lat` varchar(50)
,`fecha_creacion` datetime
,`nombre_publicador` varchar(250)
,`foto` varchar(100)
,`direccion` varchar(150)
,`promedio_usuario` decimal(12,1)
,`total_comentarios` bigint(21)
,`promedio_estrellas` decimal(12,1)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vis_serviciosAdmin`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vis_serviciosAdmin` (
`id` int(11)
,`titulo` varchar(150)
,`descripcion` text
,`precio` decimal(10,2)
,`ubicacion` varchar(255)
,`categoria` varchar(100)
,`imagen1` varchar(255)
,`imagen2` varchar(255)
,`imagen3` varchar(255)
,`estado` enum('activo','inactivo','pendiente')
,`usuario_id` int(11)
,`fecha_creacion` datetime
,`lat` varchar(50)
,`long` varchar(50)
,`contacto` varchar(150)
,`wsp` varchar(50)
,`nombre_publicador` varchar(250)
,`foto` varchar(100)
,`direccion` varchar(150)
,`promedio_usuario` decimal(12,1)
,`total_comentarios` bigint(21)
,`promedio_estrellas` decimal(12,1)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vis_serviciosadmin`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vis_serviciosadmin` (
`id` int(11)
,`imagen1` varchar(255)
,`imagen2` varchar(255)
,`imagen3` varchar(255)
,`titulo` varchar(150)
,`descripcion` text
,`precio` decimal(10,2)
,`ubicacion` varchar(255)
,`categoria` varchar(100)
,`estado` enum('activo','inactivo','pendiente')
,`usuario_id` int(11)
,`contacto` varchar(150)
,`wsp` varchar(50)
,`long` varchar(50)
,`lat` varchar(50)
,`fecha_creacion` datetime
,`nombre_publicador` varchar(250)
,`foto` varchar(100)
,`direccion` varchar(150)
,`promedio_usuario` decimal(12,1)
,`total_comentarios` bigint(21)
,`promedio_estrellas` decimal(12,1)
);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `asignaciones_pagos`
--
ALTER TABLE `asignaciones_pagos`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `asignaciones_pagos_ibfk_1` (`usuario_id`) USING BTREE,
  ADD KEY `asignaciones_pagos_ibfk_2` (`pago_id`) USING BTREE;

--
-- Indices de la tabla `categorias`
--
ALTER TABLE `categorias`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `codigos_publicacion`
--
ALTER TABLE `codigos_publicacion`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codigo` (`codigo`);

--
-- Indices de la tabla `comentarios`
--
ALTER TABLE `comentarios`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_servicios_comentarios` (`id_servicio`),
  ADD KEY `fk_comentarios_usuarios` (`usuario_id`);

--
-- Indices de la tabla `configuraciones`
--
ALTER TABLE `configuraciones`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `cupones`
--
ALTER TABLE `cupones`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codigo` (`codigo`);

--
-- Indices de la tabla `favoritos`
--
ALTER TABLE `favoritos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `usuario_servicio_unique` (`usuario_id`,`servicio_id`);

--
-- Indices de la tabla `mensajes`
--
ALTER TABLE `mensajes`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `pagos`
--
ALTER TABLE `pagos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `pagos_ibfk_1` (`usuario_id`);

--
-- Indices de la tabla `promociones`
--
ALTER TABLE `promociones`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `recordatorios`
--
ALTER TABLE `recordatorios`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `servicios`
--
ALTER TABLE `servicios`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_servicios_usuario` (`usuario_id`);

--
-- Indices de la tabla `servicios_mensajes`
--
ALTER TABLE `servicios_mensajes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_servicios_usuarios` (`usuario_id`);

--
-- Indices de la tabla `subcategorias`
--
ALTER TABLE `subcategorias`
  ADD PRIMARY KEY (`id`),
  ADD KEY `categoria_id` (`categoria_id`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `asignaciones_pagos`
--
ALTER TABLE `asignaciones_pagos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT de la tabla `categorias`
--
ALTER TABLE `categorias`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT de la tabla `codigos_publicacion`
--
ALTER TABLE `codigos_publicacion`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `comentarios`
--
ALTER TABLE `comentarios`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `configuraciones`
--
ALTER TABLE `configuraciones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `cupones`
--
ALTER TABLE `cupones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT de la tabla `favoritos`
--
ALTER TABLE `favoritos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `mensajes`
--
ALTER TABLE `mensajes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT de la tabla `pagos`
--
ALTER TABLE `pagos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

--
-- AUTO_INCREMENT de la tabla `promociones`
--
ALTER TABLE `promociones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT de la tabla `recordatorios`
--
ALTER TABLE `recordatorios`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `servicios`
--
ALTER TABLE `servicios`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT de la tabla `servicios_mensajes`
--
ALTER TABLE `servicios_mensajes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT de la tabla `subcategorias`
--
ALTER TABLE `subcategorias`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

-- --------------------------------------------------------

--
-- Estructura para la vista `vis_comentarios`
--
DROP TABLE IF EXISTS `vis_comentarios`;

CREATE ALGORITHM=UNDEFINED DEFINER=`u447520248_root2`@`127.0.0.1` SQL SECURITY DEFINER VIEW `vis_comentarios`  AS SELECT `c`.`id` AS `id_comentario`, `c`.`id_servicio` AS `id_servicio`, `c`.`usuario_id` AS `usuario_id`, `u`.`nombres` AS `nombre_calificador`, `c`.`comentario` AS `comentario`, `c`.`estrellas` AS `estrellas`, `c`.`fecha_creacion` AS `fecha_creacion` FROM (`comentarios` `c` join `usuarios` `u` on(`c`.`usuario_id` = `u`.`id`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vis_servicios`
--
DROP TABLE IF EXISTS `vis_servicios`;

CREATE ALGORITHM=UNDEFINED DEFINER=`u447520248_root2`@`127.0.0.1` SQL SECURITY DEFINER VIEW `vis_servicios`  AS SELECT `s`.`id` AS `id`, `s`.`subcategoria` AS `subcategoria`, `s`.`imagen1` AS `imagen1`, `s`.`imagen2` AS `imagen2`, `s`.`imagen3` AS `imagen3`, `s`.`titulo` AS `titulo`, `s`.`descripcion` AS `descripcion`, `s`.`precio` AS `precio`, `s`.`ubicacion` AS `ubicacion`, `s`.`categoria` AS `categoria`, `s`.`estado` AS `estado`, `s`.`usuario_id` AS `usuario_id`, `u`.`telefono` AS `contacto`, `u`.`wsp` AS `wsp`, `s`.`long` AS `long`, `s`.`lat` AS `lat`, `s`.`fecha_creacion` AS `fecha_creacion`, `u`.`nombres` AS `nombre_publicador`, `u`.`foto` AS `foto`, `u`.`direccion` AS `direccion`, (select round(avg(`c2`.`estrellas`),1) from (`comentarios` `c2` join `servicios` `s2` on(`s2`.`id` = `c2`.`id_servicio`)) where `s2`.`usuario_id` = `s`.`usuario_id`) AS `promedio_usuario`, count(`c`.`id`) AS `total_comentarios`, round(avg(`c`.`estrellas`),1) AS `promedio_estrellas` FROM ((`servicios` `s` join `usuarios` `u` on(`s`.`usuario_id` = `u`.`id`)) left join `comentarios` `c` on(`s`.`id` = `c`.`id_servicio`)) WHERE `s`.`estado` = 'activo' GROUP BY `s`.`id`, `s`.`imagen1`, `s`.`imagen2`, `s`.`imagen3`, `s`.`titulo`, `s`.`descripcion`, `s`.`precio`, `s`.`ubicacion`, `s`.`categoria`, `s`.`estado`, `s`.`usuario_id`, `u`.`telefono`, `u`.`wsp`, `s`.`fecha_creacion`, `u`.`nombres`, `u`.`foto`, `u`.`direccion`, `s`.`lat`, `s`.`long` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vis_serviciosAdmin`
--
DROP TABLE IF EXISTS `vis_serviciosAdmin`;

CREATE ALGORITHM=UNDEFINED DEFINER=`u447520248_root2`@`127.0.0.1` SQL SECURITY DEFINER VIEW `vis_serviciosAdmin`  AS SELECT `s`.`id` AS `id`, `s`.`titulo` AS `titulo`, `s`.`descripcion` AS `descripcion`, `s`.`precio` AS `precio`, `s`.`ubicacion` AS `ubicacion`, `s`.`categoria` AS `categoria`, `s`.`imagen1` AS `imagen1`, `s`.`imagen2` AS `imagen2`, `s`.`imagen3` AS `imagen3`, `s`.`estado` AS `estado`, `s`.`usuario_id` AS `usuario_id`, `s`.`fecha_creacion` AS `fecha_creacion`, `s`.`lat` AS `lat`, `s`.`long` AS `long`, `u`.`telefono` AS `contacto`, `u`.`wsp` AS `wsp`, `u`.`nombres` AS `nombre_publicador`, `u`.`foto` AS `foto`, `u`.`direccion` AS `direccion`, round(avg(`c2`.`estrellas`),1) AS `promedio_usuario`, count(`c`.`id`) AS `total_comentarios`, round(avg(`c`.`estrellas`),1) AS `promedio_estrellas` FROM (((`servicios` `s` join `usuarios` `u` on(`s`.`usuario_id` = `u`.`id`)) left join `comentarios` `c` on(`s`.`id` = `c`.`id_servicio`)) left join `comentarios` `c2` on(`s`.`id` = `c2`.`id_servicio`)) GROUP BY `s`.`id` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vis_serviciosadmin`
--
DROP TABLE IF EXISTS `vis_serviciosadmin`;

CREATE ALGORITHM=UNDEFINED DEFINER=`u447520248_root2`@`127.0.0.1` SQL SECURITY DEFINER VIEW `vis_serviciosadmin`  AS SELECT `s`.`id` AS `id`, `s`.`imagen1` AS `imagen1`, `s`.`imagen2` AS `imagen2`, `s`.`imagen3` AS `imagen3`, `s`.`titulo` AS `titulo`, `s`.`descripcion` AS `descripcion`, `s`.`precio` AS `precio`, `s`.`ubicacion` AS `ubicacion`, `s`.`categoria` AS `categoria`, `s`.`estado` AS `estado`, `s`.`usuario_id` AS `usuario_id`, `u`.`telefono` AS `contacto`, `u`.`wsp` AS `wsp`, `s`.`long` AS `long`, `s`.`lat` AS `lat`, `s`.`fecha_creacion` AS `fecha_creacion`, `u`.`nombres` AS `nombre_publicador`, `u`.`foto` AS `foto`, `u`.`direccion` AS `direccion`, (select round(avg(`c2`.`estrellas`),1) from (`comentarios` `c2` join `servicios` `s2` on(`s2`.`id` = `c2`.`id_servicio`)) where `s2`.`usuario_id` = `s`.`usuario_id`) AS `promedio_usuario`, count(`c`.`id`) AS `total_comentarios`, round(avg(`c`.`estrellas`),1) AS `promedio_estrellas` FROM ((`servicios` `s` join `usuarios` `u` on(`s`.`usuario_id` = `u`.`id`)) left join `comentarios` `c` on(`s`.`id` = `c`.`id_servicio`)) GROUP BY `s`.`id`, `s`.`imagen1`, `s`.`imagen2`, `s`.`imagen3`, `s`.`titulo`, `s`.`descripcion`, `s`.`precio`, `s`.`ubicacion`, `s`.`categoria`, `s`.`estado`, `s`.`usuario_id`, `u`.`telefono`, `u`.`wsp`, `s`.`fecha_creacion`, `u`.`nombres`, `u`.`foto`, `u`.`direccion`, `s`.`lat`, `s`.`long` ;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `asignaciones_pagos`
--
ALTER TABLE `asignaciones_pagos`
  ADD CONSTRAINT `asignaciones_pagos_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `asignaciones_pagos_ibfk_2` FOREIGN KEY (`pago_id`) REFERENCES `pagos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `comentarios`
--
ALTER TABLE `comentarios`
  ADD CONSTRAINT `fk_comentarios_usuarios` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_servicios_comentarios` FOREIGN KEY (`id_servicio`) REFERENCES `servicios` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `pagos`
--
ALTER TABLE `pagos`
  ADD CONSTRAINT `pagos_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `servicios`
--
ALTER TABLE `servicios`
  ADD CONSTRAINT `fk_servicios_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `servicios_mensajes`
--
ALTER TABLE `servicios_mensajes`
  ADD CONSTRAINT `fk_servicios_usuarios` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `subcategorias`
--
ALTER TABLE `subcategorias`
  ADD CONSTRAINT `subcategorias_ibfk_1` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
