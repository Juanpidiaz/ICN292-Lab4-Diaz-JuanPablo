-- =====================================================================
-- ICN-292 Sistemas de Información para la Gestión · 2026/02
-- Laboratorio 4 — Entregable SQL (1/2): Austral Editores
-- Alumno: Juan Pablo Díaz
-- Motor: MySQL 8 (MySQL Workbench)
-- Orden del archivo: (1) creación de la base, (2) carga oficial, (3) diez consultas.
-- Ejecutar de principio a fin sobre una base vacía (el script parte con DROP DATABASE).
-- =====================================================================


-- =====================================================================
-- ENTREGABLE 1 · CREACIÓN DE LA BASE
-- =====================================================================
DROP DATABASE IF EXISTS austral;
CREATE DATABASE austral;
USE austral;

-- Orden de creación: primero las tablas que no dependen de otra
-- (autores, colecciones) y después las que las referencian (libros, pagos).

CREATE TABLE autores (
    id_autor INT AUTO_INCREMENT,
    nombre   VARCHAR(80) NOT NULL,
    pais     VARCHAR(60),                      -- sin NOT NULL: puede quedar vacío (NULL)
    genero   ENUM('Cómic','Ensayo','Infantil','Novela','Poesía') NOT NULL,
    PRIMARY KEY (id_autor)
);

-- Tabla reconstruida: la FK libros.id_coleccion de la Figura 1 apunta aquí.
CREATE TABLE colecciones (
    id_coleccion      INT AUTO_INCREMENT,
    titulo            VARCHAR(120) NOT NULL,
    fecha_publicacion DATE NOT NULL,
    PRIMARY KEY (id_coleccion)
);

CREATE TABLE libros (
    id_libro            INT AUTO_INCREMENT,
    id_autor            INT NOT NULL,          -- un libro siempre pertenece a un autor
    id_coleccion        INT,                   -- sin NOT NULL: la carga oficial no trae colecciones
    titulo              VARCHAR(120) NOT NULL,
    paginas             INT,
    ejemplares_vendidos INT,
    anio                INT,
    PRIMARY KEY (id_libro),
    FOREIGN KEY (id_autor)     REFERENCES autores(id_autor),
    FOREIGN KEY (id_coleccion) REFERENCES colecciones(id_coleccion)
);

-- Tabla reconstruida: pagos hechos a los autores.
CREATE TABLE pagos (
    id_pago    INT AUTO_INCREMENT,
    id_autor   INT NOT NULL,
    fecha_pago DATE NOT NULL,
    monto      DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_pago),
    FOREIGN KEY (id_autor) REFERENCES autores(id_autor)
);


-- =====================================================================
-- CARGA OFICIAL (6 autores y 12 libros; sin colecciones ni pagos)
-- El id lo asigna AUTO_INCREMENT en el orden de la carga.
-- =====================================================================
INSERT INTO autores (nombre, pais, genero) VALUES
    ('Elena Pizarro',     'Chile',          'Novela'),    -- id_autor 1
    ('Harold Finch',      'Inglaterra',     'Ensayo'),    -- id_autor 2
    ('Rodrigo Bahamonde', 'Chile',          'Poesía'),    -- id_autor 3
    ('Valentina Correa',  'Argentina',      'Infantil'),  -- id_autor 4
    ('Nora Keller',       'Estados Unidos', 'Novela'),    -- id_autor 5
    ('Kenji Arakawa',     NULL,             'Cómic');     -- id_autor 6 (sin país y sin libros)

INSERT INTO libros (id_autor, titulo, paginas, ejemplares_vendidos, anio) VALUES
    (1, 'Cielo de Enero',     210, 1500, 2024),   -- id_libro 1
    (1, 'Marea Baja',         185,  800, 2023),   -- id_libro 2
    (1, 'El Norte',           200, 2200, 2024),   -- id_libro 3
    (2, 'Estrellas que Caen', 240, 3000, 2022),   -- id_libro 4
    (2, 'Máquinas',           215,  450, 2024),   -- id_libro 5
    (3, 'Luz Artificial',     300, 1200, 2024),   -- id_libro 6
    (3, 'Ruido Blanco',       280,  600, 2023),   -- id_libro 7
    (4, 'El Barrio de Lila',  190, 5000, 2024),   -- id_libro 8
    (4, 'Antes del Amanecer', 205, 2700, 2024),   -- id_libro 9
    (4, 'La Calle 8',         175,  900, 2023),   -- id_libro 10
    (5, 'Flor de Hierro',     195, 4100, 2024),   -- id_libro 11
    (5, 'Hora Dorada',        220, 1800, 2022);   -- id_libro 12

-- Verificación de la carga: 6 autores, 12 libros, 24.250 ejemplares en total.
SELECT COUNT(*) AS autores FROM autores;
SELECT COUNT(*) AS libros, SUM(ejemplares_vendidos) AS total_ejemplares FROM libros;


-- =====================================================================
-- ENTREGABLE 2 · CONSULTAS
-- Las consultas 1 a 6 corren sobre la carga oficial, ANTES de las
-- modificaciones 7 y 8.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Consulta 1. Autores cuyo país no es Chile, incluyendo a quien no tiene
-- país registrado, ordenados por nombre.
-- pais <> 'Chile' descarta a Kenji (NULL), así que se declara el caso
-- vacío con OR pais IS NULL.
-- Resultado esperado: 4 filas.
-- ---------------------------------------------------------------------
SELECT nombre, genero
FROM   autores
WHERE  pais <> 'Chile' OR pais IS NULL
ORDER BY nombre;

-- ---------------------------------------------------------------------
-- Consulta 2. Título y páginas de los libros con 190 a 220 páginas
-- (extremos incluidos), de menor a mayor número de páginas.
-- Resultado esperado: 7 filas.
-- ---------------------------------------------------------------------
SELECT titulo, paginas
FROM   libros
WHERE  paginas BETWEEN 190 AND 220
ORDER BY paginas;

-- ---------------------------------------------------------------------
-- Consulta 3. Una sola fila: número de libros, suma de ejemplares,
-- promedio de páginas, año más antiguo y mayor cantidad de ejemplares
-- vendidos de un libro. Cada columna con alias.
-- Resultado esperado: 12 | 24250 | 217.9167 | 2022 | 5000.
-- ---------------------------------------------------------------------
SELECT COUNT(*)                 AS total_libros,
       SUM(ejemplares_vendidos) AS total_ejemplares,
       AVG(paginas)             AS promedio_paginas,
       MIN(anio)                AS anio_mas_antiguo,
       MAX(ejemplares_vendidos) AS max_ejemplares_libro
FROM   libros;

-- ---------------------------------------------------------------------
-- Consulta 4. Géneros distintos de los autores, una vez cada uno, en
-- orden alfabético. (ENUM ordena por su posición declarada, y el orden
-- declarado ya es alfabético.)
-- Resultado esperado: 5 filas (hay dos autores de Novela).
-- ---------------------------------------------------------------------
SELECT DISTINCT genero
FROM   autores
ORDER BY genero;

-- ---------------------------------------------------------------------
-- Consulta 5. Autores con más de un libro publicado en 2024 y cuántos
-- son. El año filtra filas (WHERE); el conteo filtra grupos (HAVING).
-- Resultado esperado: 2 filas.
-- ---------------------------------------------------------------------
SELECT   a.nombre,
         COUNT(*) AS libros_2024
FROM     autores a
JOIN     libros l ON a.id_autor = l.id_autor
WHERE    l.anio = 2024
GROUP BY a.id_autor, a.nombre
HAVING   COUNT(*) > 1
ORDER BY a.nombre;

-- ---------------------------------------------------------------------
-- Consulta 6. Libros de 2024 con más de 2.000 ejemplares, de mayor a
-- menor, solo los tres primeros.
-- Resultado esperado: 3 filas.
-- ---------------------------------------------------------------------
SELECT   titulo, ejemplares_vendidos
FROM     libros
WHERE    anio = 2024
  AND    ejemplares_vendidos > 2000
ORDER BY ejemplares_vendidos DESC
LIMIT 3;

-- ---------------------------------------------------------------------
-- Consulta 7. Insertar 'Papel Mojado' (Rodrigo Bahamonde, id_autor 3),
-- ver la fila, eliminarla filtrando por título y comprobar que ya no está.
-- Nota: MySQL Workbench trae activado el modo de actualizaciones seguras
-- (error 1175: exige una clave en el WHERE de UPDATE y DELETE). Como aquí
-- se filtra por título, se desactiva para esta sesión y se restablece
-- al final de la consulta 8.
-- ---------------------------------------------------------------------
SET SQL_SAFE_UPDATES = 0;

INSERT INTO libros (id_autor, titulo, paginas, ejemplares_vendidos, anio)
VALUES (3, 'Papel Mojado', 260, 50, 2024);

-- SELECT previo: la fila que se va a borrar (1 fila).
SELECT *
FROM   libros
WHERE  titulo = 'Papel Mojado';

DELETE FROM libros
WHERE  titulo = 'Papel Mojado';

-- SELECT posterior, mismo criterio: debe devolver 0 filas.
SELECT *
FROM   libros
WHERE  titulo = 'Papel Mojado';

-- ---------------------------------------------------------------------
-- Consulta 8. Sumar 100 ejemplares a 'Cielo de Enero' calculando el valor
-- nuevo a partir del actual. Tres pasos: SELECT previo, UPDATE, SELECT
-- posterior, los tres con el mismo WHERE. Debe pasar de 1500 a 1600.
-- ---------------------------------------------------------------------
SELECT id_libro, titulo, ejemplares_vendidos
FROM   libros
WHERE  titulo = 'Cielo de Enero';

UPDATE libros
SET    ejemplares_vendidos = ejemplares_vendidos + 100
WHERE  titulo = 'Cielo de Enero';

SELECT id_libro, titulo, ejemplares_vendidos
FROM   libros
WHERE  titulo = 'Cielo de Enero';

SET SQL_SAFE_UPDATES = 1;

-- ---------------------------------------------------------------------
-- Consulta 9. Título de cada libro, título de su colección y fecha de
-- publicación de la colección.
-- Preparación: tres colecciones y asignación de los doce libros
-- (cada libro a una sola colección; cada colección con varios libros).
-- Resultado esperado: 12 filas.
-- ---------------------------------------------------------------------
INSERT INTO colecciones (titulo, fecha_publicacion) VALUES
    ('Narrativa Austral',   '2024-04-15'),   -- id_coleccion 1
    ('Ensayo y Poesía',     '2023-09-01'),   -- id_coleccion 2
    ('Biblioteca Infantil', '2024-10-20');   -- id_coleccion 3

-- Asignación de los doce libros: 5 + 4 + 3 = 12.
UPDATE libros SET id_coleccion = 1 WHERE id_libro IN (1, 2, 3, 11, 12);
UPDATE libros SET id_coleccion = 2 WHERE id_libro IN (4, 5, 6, 7);
UPDATE libros SET id_coleccion = 3 WHERE id_libro IN (8, 9, 10);

SELECT   l.titulo AS libro,
         c.titulo AS coleccion,
         c.fecha_publicacion
FROM     libros l
JOIN     colecciones c ON l.id_coleccion = c.id_coleccion
ORDER BY c.fecha_publicacion, l.titulo;

-- ---------------------------------------------------------------------
-- Consulta 10. Dos sentencias.
-- Preparación: cinco pagos de prueba (dos a Elena Pizarro, id_autor 1).
-- ---------------------------------------------------------------------
INSERT INTO pagos (id_autor, fecha_pago, monto) VALUES
    (1, '2026-01-15',  850000.00),
    (1, '2026-04-15',  920000.50),
    (2, '2026-02-10',  400000.00),
    (3, '2026-03-20',  275000.75),
    (4, '2026-03-05', 1500000.00);

-- 10a. Pagos hechos a los autores: nombre, fecha del pago y monto.
-- Resultado esperado: 5 filas.
SELECT   a.nombre, p.fecha_pago, p.monto
FROM     pagos p
JOIN     autores a ON p.id_autor = a.id_autor
ORDER BY p.fecha_pago;

-- 10b. Total pagado a cada autor.
-- Resultado esperado: 4 filas (suman 3945001.25, igual que 10a).
SELECT   a.nombre, SUM(p.monto) AS total_pagado
FROM     autores a
JOIN     pagos p ON a.id_autor = p.id_autor
GROUP BY a.id_autor, a.nombre
ORDER BY total_pagado DESC;
