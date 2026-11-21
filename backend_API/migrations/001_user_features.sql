-- Migración aditiva para las funciones del usuario de World of Movies.
-- Usa las tablas existentes usuario, blog y comentarios para mantener
-- compatibilidad con la API y el panel de administración.

USE `blog_db`;

-- Marca el contenido que es película, separándolo de las publicaciones
-- antiguas del blog. Es idempotente: no agrega la columna si ya existe.
SET @existe_es_pelicula = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'blog'
      AND COLUMN_NAME = 'es_pelicula'
);
SET @sql_migracion = IF(
    @existe_es_pelicula = 0,
    'ALTER TABLE `blog` ADD COLUMN `es_pelicula` TINYINT(1) NOT NULL DEFAULT 0',
    'SELECT 1'
);
PREPARE migracion FROM @sql_migracion;
EXECUTE migracion;
DEALLOCATE PREPARE migracion;

-- En el respaldo las películas existentes identifican el año y duración
-- al inicio de tags; las publicaciones normales conservan es_pelicula=0.
UPDATE `blog`
SET `es_pelicula` = 1
WHERE `tags` REGEXP '^[[:space:]]*(Año:[[:space:]]*)?[0-9]{4}';

-- Un favorito relaciona al usuario con el registro de película existente.
CREATE TABLE IF NOT EXISTS `favoritos` (
    `id_fav` INT NOT NULL AUTO_INCREMENT,
    `usr_id` INT NOT NULL,
    `blog_id` INT NOT NULL,
    `fecha` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id_fav`),
    UNIQUE KEY `uq_favorito_usuario_pelicula` (`usr_id`, `blog_id`),
    KEY `ix_favoritos_blog` (`blog_id`),
    CONSTRAINT `fk_favoritos_usuario`
        FOREIGN KEY (`usr_id`) REFERENCES `usuario` (`id_usr`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_favoritos_blog`
        FOREIGN KEY (`blog_id`) REFERENCES `blog` (`id_blog`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Guarda reportes de reseñas; un usuario no puede reportar dos veces
-- la misma reseña, pero distintos usuarios sí pueden reportarla.
CREATE TABLE IF NOT EXISTS `reportes_resena` (
    `id_reporte` INT NOT NULL AUTO_INCREMENT,
    `usr_id` INT NOT NULL,
    `id_com` INT NOT NULL,
    `fecha` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `estatus` VARCHAR(20) NOT NULL DEFAULT 'pendiente',
    PRIMARY KEY (`id_reporte`),
    UNIQUE KEY `uq_reporte_usuario_resena` (`usr_id`, `id_com`),
    KEY `ix_reportes_resena` (`id_com`),
    CONSTRAINT `fk_reportes_usuario`
        FOREIGN KEY (`usr_id`) REFERENCES `usuario` (`id_usr`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_reportes_comentario`
        FOREIGN KEY (`id_com`) REFERENCES `comentarios` (`id_com`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
