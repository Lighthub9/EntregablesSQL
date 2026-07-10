-- DDL – Estructura de tablas

-- Creacion de base de datos
CREATE DATABASE retail_project;
USE retail_project;

-- Creacion de tablas
CREATE TABLE clientes
(
   id_cliente SERIAL PRIMARY KEY,
   nombre VARCHAR(50) NOT NULL,
   apellido VARCHAR(50) NOT NULL,
   edad INT CHECK(edad >= 18),
   telefono VARCHAR(20),
   email VARCHAR(30) UNIQUE
);

CREATE TABLE productos
(
   id_producto SERIAL PRIMARY KEY,
   nombre_producto VARCHAR(25) NOT NULL,
   categoria VARCHAR(20) NOT NULL,
   precio DECIMAL(11,2) CHECK(precio > 0),
   stock INT CHECK(stock BETWEEN 0 AND 10000)
);

CREATE TABLE ventas
(
   id_venta SERIAL PRIMARY KEY,
   cantidad_vendida INT NOT NULL,
   tipo_pago VARCHAR(20) CHECK(tipo_pago IN('efectivo', 'tarjeta', 'transferencia')),
   id_producto INT NOT NULL,
   id_cliente INT NOT NULL,
   FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
   FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);


-- DML – Datos y mantenimiento

-- Poblacion de tablas
BEGIN;

INSERT INTO clientes (id_cliente, nombre, apellido, edad, telefono, email)
VALUES
   (default, 'Juan', 'Perez', 40, '55 8588 9240', 'juan.perez@email.com'),
   (default, 'Gustavo', 'Serdan', 25, '22 1548 1548', 'gustavoserdan@correo.com'),
   (default, 'Maria', 'Martinoli', 18, '33 1234 5678', 'maria48@gmail.com'),
   (default, 'Jovana', 'Loisa', 55, '55 0199 5495', 'jovana.l@email.com'),
   (default, 'Martin', 'Zurita', 33, '0000', 'martin@empresa.com');

COMMIT;

BEGIN;

INSERT INTO productos (id_producto, nombre_producto, categoria, precio, stock)
VALUES
    (default, 'smartphone', 'telefonia', 8000.00, 150),
	(default, 'laptop', 'computo', 20000.50, 50),
	(default, 'monitor', 'computo', 5000.99, 80),
	(default, 'television', 'electronica', 7500.00, 0),
	(default, 'desktop', 'computo', 15000.00, 100);

COMMIT;

BEGIN;

INSERT INTO ventas (id_venta, cantidad_vendida, tipo_pago, id_producto, id_cliente)
VALUES
   (default, 1, 'tarjeta', 2, 1),
   (default, 2, 'transferencia', 4, 2),
   (default, 5, 'tarjeta', 5, 3),
   (default, 1, 'efectivo', 1, 4),
   (default, 2, 'transferencia', 3, 5),
   (default, 2, 'tarjeta', 1, 4),
   (default, 4, 'tarjeta', 1, 1),
   (default, 1, 'transferencia', 2, 4),
   (default, 1, 'tarjeta', 5, 5);

COMMIT;


-- Sentencia UPDATE modificando el precio de una categoria de productos, por ejemplo con el 10% de descuento
UPDATE productos
SET precio = precio * .9
WHERE categoria = 'computo';

-- Sentencia DELETE que elimina una venta
DELETE FROM ventas
WHERE id_venta = 3;
	
 