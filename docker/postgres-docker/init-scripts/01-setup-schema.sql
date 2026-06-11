-- Este script se ejecutará al iniciar el contenedor por primera vez.

-- 1. Crear una base de datos específica
CREATE DATABASE learningsmall;

-- 2. Conectarse a la nueva base de datos
\connect learningsmall

-- 3. Crear una tabla de ejemplo
CREATE TABLE productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio NUMERIC(10, 2) DEFAULT 0.00
);

-- 4. Insertar datos iniciales
INSERT INTO productos (nombre, precio) VALUES ('Laptop', 1200.00);
INSERT INTO productos (nombre, precio) VALUES ('Mouse', 25.50);