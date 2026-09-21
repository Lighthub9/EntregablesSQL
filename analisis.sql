/*=============================================================================
	Nombre del archivo:  analisis.sql
	Proyecto Capstone: Análisis exploratorio de datos (EDA) en PostgreSQL
		Análisis de una distribuidora de Muebles
=============================================================================== */

/*=============================================================
   2. Limpieza.
   Informacion de capstone_project: El volumen de datos.
=============================================================== */

SET search_path TO capstone_project;

SELECT 'ciudades' AS tabla, COUNT(*) AS filas FROM ciudades
UNION ALL SELECT 'categorias', COUNT(*) FROM categorias
UNION ALL SELECT 'metodos', COUNT(*) FROM metodos
UNION ALL SELECT 'sucursales', COUNT(*) FROM sucursales
UNION ALL SELECT 'clientes', COUNT(*) FROM clientes
UNION ALL SELECT 'productos', COUNT(*) FROM productos
UNION ALL SELECT 'ventas', COUNT(*) FROM ventas
UNION ALL SELECT 'detalle_ventas', COUNT(*) FROM detalle_ventas;


/* ===============================================================================
     Identificacion de nulos en campos criticos.
     Se comprueba que las fechas, cantidades, precios y totales no esten nulos.
 ================================================================================= */

SELECT
    COUNT(*) FILTER (WHERE p.precio IS NULL) AS productos_sin_precio
FROM productos AS p;

SELECT
    COUNT(*) FILTER (WHERE v.fecha_venta IS NULL) AS ventas_sin_fecha,
    COUNT(*) FILTER (WHERE v.total IS NULL) AS ventas_sin_total
FROM ventas AS v;

SELECT
    COUNT(*) FILTER (WHERE dv.cantidad IS NULL) AS detalles_sin_cantidad,
    COUNT(*) FILTER (WHERE dv.subtotal IS NULL) AS detalles_sin_subtotal
FROM detalle_ventas AS dv;


/* ==========================================================================================================
    Verificacion de tipos de datos DATE y NUMERIC/DECIMAL.
    La consulta revisa el catalogo de PostgreSQL verificando que los campos no fueron importados como texto.
 ========================================================================================================== */

SELECT
    table_name,
    column_name,
    data_type,
    numeric_precision,
    numeric_scale
FROM information_schema.columns
WHERE table_schema = 'capstone_project'
  AND (
    (table_name = 'productos' AND column_name = 'precio')
    OR (table_name = 'ventas' AND column_name IN ('fecha_venta', 'total'))
    OR (table_name = 'detalle_ventas' AND column_name IN ('precio', 'subtotal'))
  )
ORDER BY table_name, column_name;


/* =====================================================================================================================
    3. Analisis.
    Preguntas de Negocio.
    
    1. Top 5 clientes con mayor gasto total.    

En este bloque se esta filtrando a los 5 clientes top para saber el mayor gasto total, el ticket promedio y el numero
de pedidos realizados para implementar programas de lealtad, diseñar recompensas, descuentos y/o beneficios.
========================================================================================================================== */

-- Consulta para agrupar las ventas por cliente, calculando los totales ordenados por gasto, filtrando los 5 primeros para identificar los top.
SELECT 
	v.cliente_id,
	c.nombre || ' ' || c.apellido AS cliente,
	SUM(COALESCE(v.total,0)) AS gasto_total,
	COUNT(v.venta_id) AS pedidos_realizados,
	ROUND(AVG(COALESCE(v.total,0)), 2) AS ticket_promedio
FROM clientes AS c
LEFT JOIN ventas AS v
	ON c.cliente_id = v.cliente_id
GROUP BY v.cliente_id, c.nombre, c.apellido
ORDER BY gasto_total desc
LIMIT 5;

-- En este bloque se obtienen las cantidades porcentuales de los gastos y de los pedidos realizados por los 5 clientes top y los totales.
-- Consulta para obtener las cantidades porcentuales totales, que es el marco de referencia.
SELECT 
	'Total' AS " ",
	SUM(COALESCE(v.total,0)) AS gasto,
	'100' AS "%",
	COUNT(v.venta_id) AS suma_pedidos,
	'100' AS "%"
FROM clientes AS c
JOIN ventas AS v
	ON c.cliente_id = v.cliente_id
UNION all  -- Union para tener a la vista el panorama de las dos tablas (totales vs top), en porcentaje y cantidades totales.
-- Consulta externa que suma los 5 gastos y pedidos de la subconsulta para obtener el resultado final.
SELECT 
	'Top_5',
	SUM(gasto_total),
	ROUND(SUM(gasto_total)*100/6407100, 2),
	SUM(pedidos_realizados),
	ROUND(SUM(pedidos_realizados)*100/180, 2)
FROM (
	-- Subconsulta para agrupar las ventas por cliente, calcula el total del gasto y de los pedidos, dejando solo los top 5 que mas han gastado.
	SELECT 
		v.cliente_id,
		SUM(COALESCE(v.total,0)) AS gasto_total,
		COUNT(v.venta_id) AS pedidos_realizados
	FROM clientes AS c
	JOIN ventas AS v
		ON c.cliente_id = v.cliente_id
	GROUP BY v.cliente_id
	ORDER BY gasto_total DESC
	LIMIT 5
	) AS top5;


/* ============================================================================================================
    2. Ventas totales por mes.
    
 En este bloque se identifica la evolucion de las ventas que han tenido mes tras mes, detectando tendencias 
 en crecimiento, estancamiento o caída.  
 =============================================================================================================== */ 

-- CTE para identificar cantidades y montos de las ventas mensuales
WITH ventas_mensuales AS (
	SELECT
		DATE(DATE_TRUNC('month', v.fecha_venta)) AS mes,
		COUNT(v.venta_id) AS ventas_realizadas,
		SUM(v.total) AS ventas_totales
	FROM ventas AS v
	GROUP BY DATE(DATE_TRUNC('month', v.fecha_venta))
),
-- CTE para obtener el valor de la fila anterior con la funcion LAG, así obtenemos las variaciones mensuales.
comparacion AS (
	SELECT
		vm.*,
		LAG(vm.ventas_totales) OVER (ORDER BY vm.mes) AS ventas_mes_anterior
	FROM ventas_mensuales AS vm
)
-- Consulta final mostrando mes, ventas realizadas, total vendido, total mes anterior y variación porcentual para analizar la evolución de las ventas mes a mes.
SELECT
	TO_CHAR(c.mes, 'YYYY-MM') AS mes,
	c.ventas_realizadas,
	ROUND(c.ventas_totales, 2) AS ventas_totales,
	ROUND(c.ventas_mes_anterior, 2) AS ventas_mes_anterior,
	ROUND(CASE
			WHEN c.ventas_mes_anterior IS NULL OR c.ventas_mes_anterior = 0
				THEN NULL
			ELSE
				(c.ventas_totales - c.ventas_mes_anterior) / c.ventas_mes_anterior * 100
		  END, 2) AS variacion_mensual
FROM comparacion AS c
ORDER BY c.mes;


/* ============================================================================================================
    3. 3 productos menos vendidos.
    
 En este bloque se estan filtrando los 3 productos que no han tenido demanda o la menor demanda, para generar 
 promociones o descuentos y evita la acumulacion del stock.
=============================================================================================================== */ 

SELECT 
	p.producto_id,
	p.nombre_producto,
	SUM(COALESCE (dv.cantidad,0)) AS cantidad_vendida,  -- encontramos cuántas unidades se vendieron de cada producto
	p.especificaciones ->> 'articulo' as articulo,  -- extraemos informacion JSONB para datos semiestructurados
	SUM(COALESCE (dv.subtotal,0)) AS ingreso      -- encontramos cuánto generó cada producto
FROM productos AS p
LEFT JOIN detalle_ventas AS dv    -- Se usa LEFT JOIN para que aparezcan todos los productos, incluso los que no tienen ventas
	ON p.producto_id = dv.producto_id
GROUP BY p.producto_id, p.nombre_producto
ORDER BY cantidad_vendida ASC, ingreso
LIMIT 3;   -- Se limita la busqueda a 3 productos para segmentar los menos vendidos


/* ============================================================================================================
    4. Ranking de ventas por categoría.
    
 =============================================================================================================== */ 

SELECT 
	c.categoria_id,
	c.nombre_categoria AS categoria,
	p.nombre_producto AS producto,
	SUM(COALESCE (dv.cantidad,0)) AS cantidad_vendida,  -- Obtenemos las unidades vendidas
	SUM(COALESCE (dv.subtotal,0)) AS total,     -- Obtenemos el monto vendido
-- La funcion de ventana RANK() se aplica dentro de cada categoría sobre el importe que cada venta aporta.
RANK() OVER(
	PARTITION BY c.nombre_categoria
	ORDER BY SUM(COALESCE (dv.subtotal,0)) DESC
) AS ranking
FROM categorias AS c
JOIN productos AS p
	ON c.categoria_id = p.categoria_id
JOIN detalle_ventas AS dv
	ON p.producto_id = dv.producto_id
GROUP BY c.categoria_id, c.nombre_categoria, p.nombre_producto
ORDER BY c.categoria_id, ranking;

