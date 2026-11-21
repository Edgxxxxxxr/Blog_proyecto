-- Crea el esquema base vacío que necesita la API de World of Movies.
-- No inserta cuentas, correos, contraseñas ni contenido de usuarios.

CREATE DATABASE IF NOT EXISTS `blog_db`
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE `blog_db`;

CREATE TABLE IF NOT EXISTS `usuario` (
    `id_usr` INT NOT NULL AUTO_INCREMENT,
    `nom_usr` VARCHAR(100) NOT NULL,
    `mail` VARCHAR(150) NOT NULL,
    `pass` VARCHAR(255) NOT NULL,
    `dir_usr` VARCHAR(255) DEFAULT NULL,
    `tip_usu` INT NOT NULL DEFAULT 2,
    PRIMARY KEY (`id_usr`),
    UNIQUE KEY `uq_usuario_mail` (`mail`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `blog` (
    `id_blog` INT NOT NULL AUTO_INCREMENT,
    `titulo` VARCHAR(200) NOT NULL,
    `desc` VARCHAR(500) DEFAULT NULL,
    `img` VARCHAR(255) DEFAULT NULL,
    `tags` VARCHAR(255) DEFAULT NULL,
    `fecha_publicacion` DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id_blog`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `comentarios` (
    `id_com` INT NOT NULL AUTO_INCREMENT,
    `comentario` VARCHAR(500) NOT NULL,
    `fecha` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `estatus` INT NOT NULL DEFAULT 1,
    `usr_id` INT NOT NULL,
    `blog_id` INT NOT NULL,
    `calificacion` INT DEFAULT NULL,
    PRIMARY KEY (`id_com`),
    KEY `ix_comentarios_usuario` (`usr_id`),
    KEY `ix_comentarios_blog` (`blog_id`),
    CONSTRAINT `fk_comentarios_usuario`
        FOREIGN KEY (`usr_id`) REFERENCES `usuario` (`id_usr`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_comentarios_blog`
        FOREIGN KEY (`blog_id`) REFERENCES `blog` (`id_blog`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `ck_comentarios_calificacion`
        CHECK (`calificacion` IS NULL OR `calificacion` BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
