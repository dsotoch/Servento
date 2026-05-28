-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versión del servidor:         8.4.3 - MySQL Community Server - GPL
-- SO del servidor:              Win64
-- HeidiSQL Versión:             12.8.0.6908
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Volcando estructura para tabla pidelofacillanding.asignaciones_pagos
CREATE TABLE IF NOT EXISTS `asignaciones_pagos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `usuario_id` int NOT NULL,
  `descripcion_plan` varchar(255) NOT NULL,
  `monto` decimal(10,2) NOT NULL,
  `fecha_asignada` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` enum('pendiente','exitoso','fallido') DEFAULT 'pendiente',
  `metodo_pago` varchar(50) DEFAULT NULL,
  `pago_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `codigostripe` varchar(100) DEFAULT NULL,
  `dias` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla pidelofacillanding.categorias
CREATE TABLE IF NOT EXISTS `categorias` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `descripcion` text,
  `estado` enum('activo','inactivo') DEFAULT 'activo',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla pidelofacillanding.codigos_publicacion
CREATE TABLE IF NOT EXISTS `codigos_publicacion` (
  `id` int NOT NULL AUTO_INCREMENT,
  `codigo` varchar(50) NOT NULL,
  `descripcion` text,
  `dias_gratis` int NOT NULL DEFAULT '0',
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla pidelofacillanding.comentarios
CREATE TABLE IF NOT EXISTS `comentarios` (
  `id` int NOT NULL AUTO_INCREMENT,
  `comentario` text COLLATE utf8mb4_general_ci,
  `id_servicio` int NOT NULL,
  `estrellas` int DEFAULT NULL,
  `fecha_creacion` datetime DEFAULT CURRENT_TIMESTAMP,
  `usuario_id` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla pidelofacillanding.configuraciones
CREATE TABLE IF NOT EXISTS `configuraciones` (
  `id` int NOT NULL,
  `nombre_sistema` varchar(255) NOT NULL,
  `moneda` varchar(10) NOT NULL DEFAULT 'usd',
  `logo` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `wsp` varchar(50) DEFAULT NULL,
  `telefono` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla pidelofacillanding.cupones
CREATE TABLE IF NOT EXISTS `cupones` (
  `id` int NOT NULL AUTO_INCREMENT,
  `codigo` varchar(50) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `monto_descuento` decimal(10,2) DEFAULT NULL,
  `tipo` enum('porcentaje','monto') DEFAULT 'porcentaje',
  `vigencia_inicio` datetime NOT NULL,
  `vigencia_fin` datetime NOT NULL,
  `activo` tinyint(1) DEFAULT '1',
  `id_cupon_stripe` varchar(100) DEFAULT NULL,
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `id_promocion` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla pidelofacillanding.favoritos
CREATE TABLE IF NOT EXISTS `favoritos` (
  `id` int NOT NULL,
  `usuario_id` int NOT NULL,
  `servicio_id` int NOT NULL,
  `fecha_creacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla pidelofacillanding.interrupciones
CREATE TABLE IF NOT EXISTS `interrupciones` (
  `id` int NOT NULL AUTO_INCREMENT,
  `usuario_id` varchar(50) DEFAULT NULL,
  `fecha` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `usuario_id` (`usuario_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla pidelofacillanding.mensajes
CREATE TABLE IF NOT EXISTS `mensajes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `remitente` varchar(50) NOT NULL,
  `destinatario` varchar(50) NOT NULL,
  `mensaje` text NOT NULL,
  `fecha` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `leido` tinyint(1) DEFAULT '0',
  `usuario` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla pidelofacillanding.pagos
CREATE TABLE IF NOT EXISTS `pagos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `usuario_id` int NOT NULL,
  `stripe_payment_intent_id` varchar(100) NOT NULL,
  `stripe_charge_id` varchar(100) DEFAULT NULL,
  `monto` decimal(10,2) NOT NULL,
  `moneda` varchar(10) DEFAULT 'usd',
  `descripcion` varchar(255) DEFAULT NULL,
  `estado` enum('pendiente','exitoso','fallido') DEFAULT 'pendiente',
  `metodo_pago` varchar(50) DEFAULT NULL,
  `fecha_pago` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla pidelofacillanding.promociones
CREATE TABLE IF NOT EXISTS `promociones` (
  `id` int NOT NULL AUTO_INCREMENT,
  `titulo` varchar(100) DEFAULT NULL,
  `descripcion` text,
  `costo` int DEFAULT NULL,
  `tipo` enum('general','nuevo_usuario','categoria','publicacion','dias','golden') DEFAULT 'general',
  `categoria` varchar(100) DEFAULT NULL,
  `estado` varchar(50) DEFAULT 'activo',
  `fecha` datetime DEFAULT CURRENT_TIMESTAMP,
  `dias_vigencia` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla pidelofacillanding.recordatorios
CREATE TABLE IF NOT EXISTS `recordatorios` (
  `id` int NOT NULL,
  `cliente_id` varchar(20) DEFAULT NULL,
  `fecha_pago` varchar(30) DEFAULT NULL,
  `fecha_recordatorio` varchar(30) DEFAULT NULL,
  `estado` varchar(30) DEFAULT 'activo'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla pidelofacillanding.servicios
CREATE TABLE IF NOT EXISTS `servicios` (
  `id` int NOT NULL AUTO_INCREMENT,
  `titulo` varchar(150) COLLATE utf8mb4_general_ci NOT NULL,
  `descripcion` text COLLATE utf8mb4_general_ci NOT NULL,
  `precio` decimal(10,2) NOT NULL DEFAULT '0.00',
  `ubicacion` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `categoria` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `imagen1` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `imagen2` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `imagen3` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `estado` enum('activo','inactivo','pendiente') COLLATE utf8mb4_general_ci DEFAULT 'activo',
  `usuario_id` int NOT NULL,
  `fecha_creacion` datetime DEFAULT CURRENT_TIMESTAMP,
  `lat` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `long` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `subcategoria` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla pidelofacillanding.servicios_mensajes
CREATE TABLE IF NOT EXISTS `servicios_mensajes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `mensaje` text,
  `usuario_id` int NOT NULL,
  `fecha` datetime DEFAULT CURRENT_TIMESTAMP,
  `servicio` text,
  `imagen` varchar(100) DEFAULT NULL,
  `vigencia` date DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla pidelofacillanding.subcategorias
CREATE TABLE IF NOT EXISTS `subcategorias` (
  `id` int NOT NULL AUTO_INCREMENT,
  `categoria_id` int NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `descripcion` text,
  `estado` enum('activo','inactivo') DEFAULT 'activo',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla pidelofacillanding.usuarios
CREATE TABLE IF NOT EXISTS `usuarios` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(200) DEFAULT NULL,
  `pass` varchar(100) DEFAULT NULL,
  `nombres` varchar(250) NOT NULL,
  `estado` varchar(25) DEFAULT 'ACTIVO',
  `foto` varchar(100) DEFAULT NULL,
  `direccion` varchar(150) DEFAULT NULL,
  `telefono` varchar(150) DEFAULT NULL,
  `fecha_creacion` datetime DEFAULT CURRENT_TIMESTAMP,
  `wsp` varchar(50) DEFAULT NULL,
  `admin` varchar(10) DEFAULT NULL,
  `img1` varchar(100) DEFAULT NULL,
  `img2` varchar(100) DEFAULT NULL,
  `img3` varchar(100) DEFAULT NULL,
  `token` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla pidelofacillanding.usuario_cupon
CREATE TABLE IF NOT EXISTS `usuario_cupon` (
  `id` int NOT NULL AUTO_INCREMENT,
  `usuario_id` varchar(50) DEFAULT NULL,
  `cupon_id` varchar(50) DEFAULT NULL,
  `fecha` date DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para vista pidelofacillanding.vis_comentarios
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `vis_comentarios` (
	`id_comentario` INT NOT NULL,
	`id_servicio` INT NOT NULL,
	`usuario_id` INT NOT NULL,
	`nombre_calificador` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_0900_ai_ci',
	`comentario` TEXT NULL COLLATE 'utf8mb4_general_ci',
	`estrellas` INT NULL,
	`fecha_creacion` DATETIME NULL
) ENGINE=MyISAM;

-- Volcando estructura para vista pidelofacillanding.vis_servicios
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `vis_servicios` (
	`id` INT NOT NULL,
	`subcategoria` VARCHAR(1) NULL COLLATE 'utf8mb4_general_ci',
	`imagen1` VARCHAR(1) NULL COLLATE 'utf8mb4_general_ci',
	`imagen2` VARCHAR(1) NULL COLLATE 'utf8mb4_general_ci',
	`imagen3` VARCHAR(1) NULL COLLATE 'utf8mb4_general_ci',
	`titulo` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_general_ci',
	`descripcion` TEXT NOT NULL COLLATE 'utf8mb4_general_ci',
	`precio` DECIMAL(10,2) NOT NULL,
	`ubicacion` VARCHAR(1) NULL COLLATE 'utf8mb4_general_ci',
	`categoria` VARCHAR(1) NULL COLLATE 'utf8mb4_general_ci',
	`estado` ENUM('activo','inactivo','pendiente') NULL COLLATE 'utf8mb4_general_ci',
	`usuario_id` INT NOT NULL,
	`contacto` VARCHAR(1) NULL COLLATE 'utf8mb4_0900_ai_ci',
	`wsp` VARCHAR(1) NULL COLLATE 'utf8mb4_0900_ai_ci',
	`long` VARCHAR(1) NULL COLLATE 'utf8mb4_general_ci',
	`lat` VARCHAR(1) NULL COLLATE 'utf8mb4_general_ci',
	`fecha_creacion` DATETIME NULL,
	`nombre_publicador` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_0900_ai_ci',
	`foto` VARCHAR(1) NULL COLLATE 'utf8mb4_0900_ai_ci',
	`direccion` VARCHAR(1) NULL COLLATE 'utf8mb4_0900_ai_ci',
	`promedio_usuario` DECIMAL(12,1) NULL,
	`total_comentarios` BIGINT NOT NULL,
	`promedio_estrellas` DECIMAL(12,1) NULL
) ENGINE=MyISAM;

-- Volcando estructura para vista pidelofacillanding.vis_serviciosadmin
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `vis_serviciosadmin` (
	`id` INT NOT NULL,
	`titulo` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_general_ci',
	`descripcion` TEXT NOT NULL COLLATE 'utf8mb4_general_ci',
	`precio` DECIMAL(10,2) NOT NULL,
	`ubicacion` VARCHAR(1) NULL COLLATE 'utf8mb4_general_ci',
	`categoria` VARCHAR(1) NULL COLLATE 'utf8mb4_general_ci',
	`imagen1` VARCHAR(1) NULL COLLATE 'utf8mb4_general_ci',
	`imagen2` VARCHAR(1) NULL COLLATE 'utf8mb4_general_ci',
	`imagen3` VARCHAR(1) NULL COLLATE 'utf8mb4_general_ci',
	`estado` ENUM('activo','inactivo','pendiente') NULL COLLATE 'utf8mb4_general_ci',
	`usuario_id` INT NOT NULL,
	`fecha_creacion` DATETIME NULL,
	`lat` VARCHAR(1) NULL COLLATE 'utf8mb4_general_ci',
	`long` VARCHAR(1) NULL COLLATE 'utf8mb4_general_ci',
	`contacto` VARCHAR(1) NULL COLLATE 'utf8mb4_0900_ai_ci',
	`wsp` VARCHAR(1) NULL COLLATE 'utf8mb4_0900_ai_ci',
	`nombre_publicador` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_0900_ai_ci',
	`foto` VARCHAR(1) NULL COLLATE 'utf8mb4_0900_ai_ci',
	`direccion` VARCHAR(1) NULL COLLATE 'utf8mb4_0900_ai_ci',
	`promedio_usuario` DECIMAL(12,1) NULL,
	`total_comentarios` BIGINT NOT NULL,
	`promedio_estrellas` DECIMAL(12,1) NULL
) ENGINE=MyISAM;

-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `vis_comentarios`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vis_comentarios` AS select `c`.`id` AS `id_comentario`,`c`.`id_servicio` AS `id_servicio`,`c`.`usuario_id` AS `usuario_id`,`u`.`nombres` AS `nombre_calificador`,`c`.`comentario` AS `comentario`,`c`.`estrellas` AS `estrellas`,`c`.`fecha_creacion` AS `fecha_creacion` from (`comentarios` `c` join `usuarios` `u` on((`c`.`usuario_id` = `u`.`id`)));

-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `vis_servicios`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vis_servicios` AS select `s`.`id` AS `id`,`s`.`subcategoria` AS `subcategoria`,`s`.`imagen1` AS `imagen1`,`s`.`imagen2` AS `imagen2`,`s`.`imagen3` AS `imagen3`,`s`.`titulo` AS `titulo`,`s`.`descripcion` AS `descripcion`,`s`.`precio` AS `precio`,`s`.`ubicacion` AS `ubicacion`,`s`.`categoria` AS `categoria`,`s`.`estado` AS `estado`,`s`.`usuario_id` AS `usuario_id`,`u`.`telefono` AS `contacto`,`u`.`wsp` AS `wsp`,`s`.`long` AS `long`,`s`.`lat` AS `lat`,`s`.`fecha_creacion` AS `fecha_creacion`,`u`.`nombres` AS `nombre_publicador`,`u`.`foto` AS `foto`,`u`.`direccion` AS `direccion`,(select round(avg(`c2`.`estrellas`),1) from (`comentarios` `c2` join `servicios` `s2` on((`s2`.`id` = `c2`.`id_servicio`))) where (`s2`.`usuario_id` = `s`.`usuario_id`)) AS `promedio_usuario`,count(`c`.`id`) AS `total_comentarios`,round(avg(`c`.`estrellas`),1) AS `promedio_estrellas` from ((`servicios` `s` join `usuarios` `u` on((`s`.`usuario_id` = `u`.`id`))) left join `comentarios` `c` on((`s`.`id` = `c`.`id_servicio`))) where (`s`.`estado` = 'activo') group by `s`.`id`,`s`.`imagen1`,`s`.`imagen2`,`s`.`imagen3`,`s`.`titulo`,`s`.`descripcion`,`s`.`precio`,`s`.`ubicacion`,`s`.`categoria`,`s`.`estado`,`s`.`usuario_id`,`u`.`telefono`,`u`.`wsp`,`s`.`fecha_creacion`,`u`.`nombres`,`u`.`foto`,`u`.`direccion`,`s`.`lat`,`s`.`long`;

-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `vis_serviciosadmin`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vis_serviciosadmin` AS select `s`.`id` AS `id`,`s`.`titulo` AS `titulo`,`s`.`descripcion` AS `descripcion`,`s`.`precio` AS `precio`,`s`.`ubicacion` AS `ubicacion`,`s`.`categoria` AS `categoria`,`s`.`imagen1` AS `imagen1`,`s`.`imagen2` AS `imagen2`,`s`.`imagen3` AS `imagen3`,`s`.`estado` AS `estado`,`s`.`usuario_id` AS `usuario_id`,`s`.`fecha_creacion` AS `fecha_creacion`,`s`.`lat` AS `lat`,`s`.`long` AS `long`,`u`.`telefono` AS `contacto`,`u`.`wsp` AS `wsp`,`u`.`nombres` AS `nombre_publicador`,`u`.`foto` AS `foto`,`u`.`direccion` AS `direccion`,round(avg(`c2`.`estrellas`),1) AS `promedio_usuario`,count(`c`.`id`) AS `total_comentarios`,round(avg(`c`.`estrellas`),1) AS `promedio_estrellas` from (((`servicios` `s` join `usuarios` `u` on((`s`.`usuario_id` = `u`.`id`))) left join `comentarios` `c` on((`s`.`id` = `c`.`id_servicio`))) left join `comentarios` `c2` on((`s`.`id` = `c2`.`id_servicio`))) group by `s`.`id`;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
