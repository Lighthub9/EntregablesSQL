/*  Pre-entrega 5: Script de análisis avanzado con Window Functions */

--CTE agrupa ventas por mes y categoría, calculando la suma total.
WITH ventas_mensuales AS
(
	SELECT
		EXTRACT(MONTH FROM v.fecha) AS mes,
		p.categoria,		
		SUM(p.precio * v.cantidad_vendida) AS venta
	FROM productos p
	JOIN ventas v
	ON p.id_producto = v.id_producto
	GROUP BY p.categoria, v.fecha
	-- 1no ORDER BY mes, p.categoria, venta
),

-- CTE rankeando las categorías por ventas por mes y el acumulado por categoría.
metricas_ventana AS
(
	SELECT
		mes,
		categoria,
		venta,
		RANK() OVER(PARTITION BY mes ORDER BY venta DESC) AS ranking,
		SUM(venta) OVER(PARTITION BY categoria ORDER BY mes) AS total_acumulado
	FROM ventas_mensuales
),

-- CTE para obtener el promedio historico de cada categoría.
promedio_general AS
(
	SELECT
		categoria,
		AVG(venta) AS promedio_categoria
	FROM ventas_mensuales
	GROUP BY categoria
)

-- Consulta principal donde se compara la venta mensual contra el promedio y etiqueta el mes.
SELECT
	mv.mes,
	mv.categoria,
	mv.venta,
	mv.ranking,
	mv.total_acumulado,
	CASE
		WHEN mv.venta >= pg.promedio_categoria 
		THEN 'Exitoso'
		ELSE 'Bajo el promedio'
	END AS comparativa
FROM metricas_ventana mv
JOIN promedio_general pg
ON mv.categoria = pg.categoria
ORDER BY mv.mes, mv.ranking;
