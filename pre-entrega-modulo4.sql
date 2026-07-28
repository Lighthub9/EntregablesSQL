/*  Pre-entrega 4:
Consultas multicapa para análisis de negocio.


Poblacion de datos en la tabla de ventas */
INSERT INTO ventas (id_venta, cantidad_vendida, tipo_pago, id_producto, id_cliente)
VALUES
   (DEFAULT, 2, 'tarjeta', 4, 3),
   (DEFAULT, 1, 'efectivo', 1, 2),
   (DEFAULT, 1, 'transferencia', 5, 1),
   (DEFAULT, 2, 'tarjeta', 2, 5),
   (DEFAULT, 2, 'tarjeta', 2, 2),
   (DEFAULT, 4, 'tarjeta', 1, 4),
   (DEFAULT, 1, 'transferencia', 2, 3),
   (DEFAULT, 2, 'tarjeta', 1, 4)
   (DEFAULT, 2, 'efectivo', 1, 1),
   (DEFAULT, 2, 'efectivo', 2, 1),
   (DEFAULT, 6, 'tarjeta', 1, 4),
   (DEFAULT, 3, 'transferencia', 5, 4),
   (DEFAULT, 1, 'tarjeta', 1, 3),
   (DEFAULT, 4, 'tarjeta', 1, 4),
   (DEFAULT, 1, 'transferencia', 5, 1),
   (DEFAULT, 8, 'transferencia', 2, 5),
   (DEFAULT, 5, 'transferencia', 2, 4)
   (DEFAULT, 2, 'tarjeta', 2, 2),
   (DEFAULT, 1, 'tarjeta', 4, 3)


/* Poblacion de la tabla de clientes */
INSERT INTO clientes (id_cliente, nombre, apellido, edad, telefono, email)
VALUES
   (DEFAULT, 'Paula', 'Torres', 48, '', 'sucorreo@email.com'),
   (DEFAULT, 'Alberto', 'Aspe', 36, '55 3456 7890', '');


/* Actualizacion de la tabla ventas integrando el campo de fecha */
ALTER TABLE ventas
ADD COLUMN Fecha DATE;

UPDATE ventas
SET fecha = '2026-06-01'
WHERE id_venta = 1;

UPDATE ventas
SET fecha = '2026-06-01'
WHERE id_venta = 2;

UPDATE ventas
SET fecha = '2026-06-06'
WHERE id_venta = 4;

UPDATE ventas
SET fecha = '2026-07-02'
WHERE id_venta = 5;

UPDATE ventas
SET fecha = '2026-06-30'
WHERE id_venta = 6;

UPDATE ventas
SET fecha = '2026-07-18'
WHERE id_venta = 7;

UPDATE ventas
SET fecha = '2026-06-11'
WHERE id_venta = 8;

UPDATE ventas
SET fecha = '2026-06-02'
WHERE id_venta = 9;

UPDATE ventas
SET fecha = '2026-06-06'
WHERE id_venta = 10;

UPDATE ventas
SET fecha = '2026-07-12'
WHERE id_venta = 11;

UPDATE ventas
SET fecha = '2026-07-12'
WHERE id_venta = 12;

UPDATE ventas
SET fecha = '2026-07-18'
WHERE id_venta = 13;

UPDATE ventas
SET fecha = '2026-07-19'
WHERE id_venta = 14;

UPDATE ventas
SET fecha = '2026-06-06'
WHERE id_venta = 15;

UPDATE ventas
SET fecha = '2026-07-13'
WHERE id_venta = 16;

UPDATE ventas
SET fecha = '2026-07-15'
WHERE id_venta = 17;

UPDATE ventas
SET fecha = '2026-06-18'
WHERE id_venta = 18;

UPDATE ventas
SET fecha = '2026-06-01'
WHERE id_venta = 19;

UPDATE ventas
SET fecha = '2026-06-02'
WHERE id_venta = 20;

UPDATE ventas
SET fecha = '2026-06-29'
WHERE id_venta = 21;

UPDATE ventas
SET fecha = '2026-07-07'
WHERE id_venta = 22;

UPDATE ventas
SET fecha = '2026-07-13'
WHERE id_venta = 23;
UPDATE ventas
SET fecha = '2026-07-04'
WHERE id_venta = 24;

UPDATE ventas
SET fecha = '2026-07-09'
WHERE id_venta = 25;

UPDATE ventas
SET fecha = '2026-06-19'
WHERE id_venta = 26;

UPDATE ventas
SET fecha = '2026-07-09'
WHERE id_venta = 27;

UPDATE ventas
SET fecha = '2026-07-14'
WHERE id_venta = 28;


/*  1. Rentabilidad por categoría:
Unir ventas, productos y categorias; mostrar nombre de categoría, unidades vendidas e ingreso total; 
filtrar por categorías que superen un umbral de ventas que vos definas. 

Problema de negocio que resuelve:
Este query nos permite identificar que categorías generan mayor ingreso y cuáles consumen recursos sin aportar beneficios.
Con esta información, las empresas puede asignar mejor el presupuesto, optimizar inventarios y enfocar esfuerzos comerciales en las áreas más rentables. */

SELECT p.categoria, SUM(v.cantidad_vendida) AS unidades_vendidas, SUM(v.cantidad_vendida * p.precio) AS ingreso_total
FROM productos p
JOIN ventas v
ON p.id_producto = v.id_producto
JOIN clientes c
ON v.id_cliente = c.id_cliente
GROUP BY p.categoria
HAVING SUM(v.cantidad_vendida * p.precio) > 200000
ORDER BY ingreso_total DESC;


/* 2. Clientes sin compras:
Usando LEFT JOIN o subconsulta, identificar clientes registrados que aún no realizaron ninguna compra.

Problema de negocio que resuelve:
Al detectar a estos clientes se pueden diseñar estrategias específicas como promociones iniciales o recordatorios personalizados,
esto permite transformar registros en ingresos reales.  */

-- Usando LEFT JOIN
SELECT v.id_cliente, c.nombre, c.apellido
FROM clientes c
LEFT JOIN ventas v
ON c.id_cliente = v.id_cliente
WHERE v.id_cliente IS NULL;

-- Usando subconsulta
SELECT c.nombre, c.apellido
FROM clientes c
WHERE c.id_cliente NOT IN (SELECT v.id_cliente FROM ventas v);


/* 3. Top de compras por cliente:
Unir clientes, ventas y productos; mostrar nombre del cliente, producto que más veces compró y fecha de su última transacción.

Problema de negocio que resuelve:
Resuelve la segmentacion y fidelizacion, detecta patrones de consumo, diseña estrategias personalizadas que aumenten la lealtad
y optimiza el inventario en funcion de la demanda real.  */

SELECT c.id_cliente, 
	c.nombre,
	c.apellido,
	-- Producto que mas veces compro
	COALESCE((SELECT p.nombre_producto
	FROM productos p
	WHERE p.id_producto = 
		(SELECT v.id_producto
		FROM ventas v
		WHERE v.id_cliente = c.id_cliente
		GROUP BY v.id_producto
		ORDER BY COUNT(*) DESC
		LIMIT 1)
	), 'sin compras') AS producto_mas_comprado,
	-- Cantidad del producto mas comprado
	COALESCE((SELECT SUM(v.cantidad_vendida)
     FROM ventas v
     WHERE v.id_cliente = c.id_cliente
     AND v.id_producto = 
	 	(SELECT v2.id_producto
		FROM ventas v2
		WHERE v2.id_cliente = c.id_cliente
		GROUP BY v2.id_producto
		ORDER BY COUNT(*) DESC
		LIMIT 1)
	), 0) AS cantidad,
	-- Fecha de la ultima transaccion
	(SELECT MAX(v.fecha)
	FROM ventas v
	WHERE v.id_cliente = c.id_cliente
	) AS ultima_transaccion
FROM clientes c;
