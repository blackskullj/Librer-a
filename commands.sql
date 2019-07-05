CREATE TABLE IF NOT EXISTS books(
    book_id INTEGER UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    author_id INTEGER UNSIGNED,
    title VARCHAR(100) NOT NULL,
    year INTEGER UNSIGNED NOT NULL DEFAULT 1900,
    language VARCHAR(2) NOT NULL DEFAULT 'es' COMMENT 'ISO 639-1 Language',
    cover_url VARCHAR(500),
    price DOUBLE(6,2) NOT NULL DEFAULT 10.0,
    sellable TINYINT(1) DEFAULT 1,
    copies INTEGER NOT NULL DEFAULT 1,
    description TEXT
);

CREATE TABLE IF NOT EXISTS authors(
    author_id INTEGER UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    nationality VARCHAR(3) COMMENT 'ISO 3166-1 ALPHA-3 COUNTRY CODES'
);

CREATE TABLE clients(
    client_id INTEGER UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    birth_date DATETIME,
    gender ENUM('M', 'F', 'ND') NOT NULL,
    active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS operations(
    operation_id INTEGER UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    book_id INTEGER UNSIGNED NOT NULL,
    client_id INTEGER UNSIGNED NOT NULL,
    operation_type ENUM('B', 'R', 'S') NOT NULL COMMENT 'Borrowed, Returned, Sold',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    finished TINYINT(1) NOT NULL
);

INSERT INTO authors(author_id, name, nationality)
VALUES('', 'Juan Rulfo', 'MEX');

INSERT INTO authors(name, nationality)
VALUES('Gabriel García Márquez', 'COL');

INSERT INTO authors
VALUES('', 'Juan Gabriel Vásquez', 'COL');

INSERT INTO authors(name, nationality)
VALUES('Julio Cortázar', 'ARG'),
    ('Isabel Allende', 'CHL'),
    ('Octavio Paz', 'MEX'),
    ('Juan Carlos Onetti', 'URY');

INSERT INTO `clients`(client_id, name, email, birth_date, gender, active)
VALUES(1,'Maria Dolores Gomez','Maria Dolores.95983222J@random.names','1971-06-06','F',1),
    (2,'Adrian Fernandez','Adrian.55818851J@random.names','1970-04-09','M',1),
    (3,'Maria Luisa Marin','Maria Luisa.83726282A@random.names','1957-07-30','F',1),
    (4,'Pedro Sanchez','Pedro.78522059J@random.names','1992-01-31','M',1);

El Laberinto de la Soledad, Octavio Paz, 1950
Vuelta al Laberinto de la Soledad, Octavio Paz, 1975

INSERT INTO books(title, author_id, `year`)
VALUES('El Laberinto de la Soledad', 6, 1950);

INSERT INTO books(title, author_id, `year`)
VALUES('Vuelta al Laberinto de la Soledad',
(SELECT author_id FROM authors WHERE name = 'Octavio Paz' LIMIT 1),
1975);

--Para cargar archivos a SQL a través del command prompt para crear schemas vacíos
--donde all_schema representa al archivo a cargar
mysql -u root -p < all_schema.sql

--Para llenar tablas dentro de la base anteriormente creada
--donde all_data.sql representa al archivo con los datos a cargar
-- -D indica el nombre de la base donde se encuentran las tablas a llenar
mysql -u root -p -D cursoplatzi < all_data.sql

SELECT name, email, gender FROM clients WHERE gender = 'F';

SELECT name, YEAR(NOW()) - YEAR(BIRTHDATE) FROM clients LIMIT 10;

SELECT name, email, YEAR(NOW()) - YEAR(BIRTHDATE) AS age, gender
FROM clients
WHERE gender = 'F'
AND name LIKE '%Lop%';

SELECT COUNT(*) FROM authors;

SELECT * FROM authors WHERE author_id > 0 AND author_id <= 5;

SELECT book_id, author_id, title FROM books WHERE author_id BETWEEN 1 AND 5;

SELECT b.book_id, a.name, b.title
FROM books AS b
JOIN authors AS a ON a.author_id = b.author_id
WHERE a.author_id BETWEEN 1 AND 5;

SELECT b.book_id, a.name, a.author_id, b.title
FROM books AS b
JOIN authors AS a ON a.author_id = b.author_id
WHERE a.author_id BETWEEN 1 AND 5;

SELECT c.name, b.title, t.type
FROM transactions AS t
JOIN books AS b ON t.book_id = b.book_id
JOIN clients AS c ON t.client_id = c.client_id;

SELECT c.name AS client, b.title, a.name AS author, t.type
FROM transactions AS t
JOIN books AS b ON t.book_id = b.book_id
JOIN clients AS c ON t.client_id = c.client_id
JOIN authors AS a ON b.author_id = a.author_id
WHERE gender = 'F'
AND t.type = 'sell';

SELECT c.name AS client, b.title, a.name AS author, t.type
FROM transactions AS t
JOIN books AS b ON t.book_id = b.book_id
JOIN clients AS c ON t.client_id = c.client_id
JOIN authors AS a ON b.author_id = a.author_id
WHERE gender = 'M'
AND t.type IN ('sell', 'lend');

SELECT a.author_id, a.name, a.nationality, b.title
FROM authors AS a
JOIN books AS b ON b.author_id = a.author_id
WHERE a.author_id BETWEEN 1 AND 5
ORDER BY a.author_id;

SELECT a.author_id, a.name, a.nationality, b.title
FROM authors AS a
LEFT JOIN books AS b ON b.author_id = a.author_id
WHERE a.author_id BETWEEN 1 AND 5
ORDER BY a.author_id;

SELECT a.author_id, a.name, a.nationality, COUNT(b.book_id)
FROM authors AS a
LEFT JOIN books AS b ON b.author_id = a.author_id
WHERE a.author_id BETWEEN 1 AND 5
GROUP BY a.author_id
ORDER BY a.author_id;

--Preguntas en casos de Negocio
1. ¿Qué nacionalidades hay?
SELECT DISTINCT nationality
FROM authors
ORDER BY nationality;
2. ¿Cuántos escritores hay de cada nacionalidad?
SELECT nationality, COUNT(author_id) AS c_autors
FROM authors
WHERE nationality IS NOT NULL
GROUP BY nationality 
RDER BY c_autors DESC, nationality ASC;
3. ¿Cuántos libros hay de cada nacionalidad?
SELECT nationality, COUNT(b.book_id) AS c_books
FROM authors AS a
JOIN books AS b ON b.author_id = a.author_id
GROUP BY nationality
ORDER BY c_authors DESC, nationality ASC; 
4. ¿Cuál es el promedio/desviación estándar del precio de los libros?
SELECT nationality, COUNT(book_id) AS libros, AVG(price) AS prom, STDDEV(price) AS std
FROM books AS b
JOIN authors as a ON a.author_id = b.author_id
GROUP BY nationality
ORDER BY libros DESC;
5. idem por nacionalidad
6. ¿Cuál es el precio mínimo/máximo de un libro?
SELECT nationality, MAX(price), MIN(price)
FROM books AS b
JOIN authors AS a ON a.author_id = b.author_id
GROUP BY nationality;
7. ¿Cómo quedaría el reporte de préstamos?
SELECT t.type, b.title, CONCAT(a.name, " (", a.nationality, ")") AS author, TO_DAYS(NOW()) - TO_DAYS(t.created_at) AS ago
FROM transactions as t
LEFT JOIN clients AS c ON c.client_id = t.client_id
LEFT JOIN books AS b ON b.book_id = t.book_id
LEFT JOIN authors AS a ON b.author_id = a.author_id;

--UPDATE, DELETE & TRUNCATE--
UPDATE clients
SET
    active = 0
WHERE
    client_id IN (1,6,8,27,90)
    OR name LIKE '%Lopez%';

DELETE FROM authors
WHERE
    author_id = 161
LIMIT 1;

TRUNCATE transactions;

SELECT COUNT(book_id),
    SUM(IF(year < 1950, 1,0)) AS '< 1950',
    SUM(IF(year < 1950, 0,1)) AS '> 1950'
FROM books;

SELECT COUNT(book_id),
    SUM(IF(year < 1950, 1, 0)) AS '< 1950',
    SUM(IF(year >= 1950 AND year < 1990, 1, 0)) AS '< 1990',
    SUM(IF(year >= 1990 AND year < 2000, 1, 0)) AS '< 2000',
    SUM(IF(year >= 2000, 1, 0)) AS '< Hoy'
FROM books;

SELECT nationality, COUNT(book_id),
    SUM(IF(year < 1950, 1, 0)) AS '< 1950',
    SUM(IF(year >= 1950 AND year < 1990, 1, 0)) AS '< 1990',
    SUM(IF(year >= 1990 AND year < 2000, 1, 0)) AS '< 2000',
    SUM(IF(year >= 2000, 1, 0)) AS '< Hoy'
FROM books AS b
JOIN authors AS a
    ON a.author_id = b.author_id
WHERE nationality IS NOT NULL
GROUP BY nationality;

ALTER TABLE authors ADD COLUMN birth_year INTEGER DEFAULT 1930 AFTER name;

ALTER TABLE authors MODIFY COLUMN birth_year year DEFAULT 1920;

ALTER TABLE authors DROP COLUMN birth_year;

--MYSQLDUMP para crear respaldos con datos
mysqldump -u root -p cursoplatzi

--MYSQLDUMP para crear respaldo de esquemas sin datos
mysqldump -u root -p -d cursoplatzi | more

--MYSQLDUMP para crear respaldo de esquemas sin datos exportado con nombre y extensión de archivo
mysqldump -u root -p -d cursoplatzi > esquema.sql