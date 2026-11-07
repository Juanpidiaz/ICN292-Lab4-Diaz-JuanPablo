# ICN292-Lab4-Diaz-JuanPablo
ICN-292 · Laboratorio 4: base de datos SQL de Austral Editores (MySQL 8)
Este repositorio contiene mi trabajo del Laboratorio 4 de ICN-292 Sistemas de Información para la Gestión (Departamento de Industrias, USM, segundo semestre de 2026). Soy Juan Pablo Díaz y el laboratorio consiste en reconstruir en MySQL 8 la base de datos de Austral Editores, una editorial que registra a sus autores y los libros que cada uno publica, y dejar escritas las diez consultas con las que se revisa el negocio.

Qué hay en el repositorio

El archivo ICN292-Lab4-Diaz-JuanPablo.sql es el corazón del trabajo. Parte con DROP DATABASE IF EXISTS austral;, crea la base y sus cuatro tablas (autores, colecciones, libros y pagos), carga los datos oficiales (seis autores y doce libros) y termina con las diez consultas, en ese mismo orden. Como empieza borrando la base, se puede ejecutar de principio a fin las veces que haga falta sin que queden restos de una ejecución anterior.

El archivo ICN292-Lab4-Diaz-JuanPablo.png es el modelo entidad–relación con las tablas reconstruidas y sus claves foráneas, y el informe se entrega en dos formatos, ICN292-Lab4-Diaz-JuanPablo.pdf y ICN292-Lab4-Diaz-JuanPablo.docx. El informe abre con una portada y pasa directo a las consultas, mostrando para cada una el código SQL tal como se ejecutó y la captura de lo que devolvió MySQL Workbench.

Cómo reproducir el trabajo

Para ejecutar el script hace falta un servidor MySQL 8 y MySQL Workbench. Basta con abrir el archivo .sql desde File > Open SQL Script..., conectarse al servidor y ejecutarlo. Hay que respetar el orden del archivo, ya que las consultas 1 a 6 trabajan sobre la carga oficial y deben correr antes de las modificaciones de las consultas 7 y 8; si se ejecutan después, los totales dejan de ser los del catálogo inicial y los resultados cambian.

Para que Workbench acepte los DELETE y UPDATE que filtran por título, el script desactiva el modo de actualizaciones seguras con SET SQL_SAFE_UPDATES = 0; al comienzo de la consulta 7 y lo vuelve a activar al final de la consulta 8. Sin ese ajuste, Workbench rechaza esas sentencias con el error 1175.

Para volver a generar la imagen del modelo, se usa Database > Reverse Engineer... en Workbench, se elige la base austral y se exporta el diagrama con File > Export > Export as PNG....

Sobre los datos de prueba

La carga oficial no trae colecciones ni pagos, así que los inserté yo para que las consultas 9 y 10 tengan sentido. Son tres colecciones a las que se asignan los doce libros, y cinco pagos de los cuales dos van al mismo autor. En la tabla de libros, la columna id_coleccion admite valores vacíos justamente porque la carga oficial no incluye colecciones, y por eso la asignación se hace justo antes de la consulta 9.

Resultados clave

Con la carga oficial hay seis autores y doce libros que suman 24.250 ejemplares vendidos. La consulta 1 devuelve cuatro autores, incluido Kenji Arakawa, que no tiene país registrado, y la consulta 3 resume el catálogo en una sola fila con 12 libros, 24.250 ejemplares, 217,9167 páginas en promedio, el año 2022 como el más antiguo y un máximo de 5.000 ejemplares en un libro. Tras la consulta 8, «Cielo de Enero» pasa de 1.500 a 1.600 ejemplares, y en la consulta 10 los pagos suman 3.945.001,25 repartidos entre cuatro autores.
