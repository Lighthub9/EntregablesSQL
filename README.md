# Proyecto Capstone: Análisis exploratorio de datos (EDA) en PostgreSQL

## Análisis de una distribuidora de Muebles.

Proyecto de creación, configuración, carga y análisis de una base de datos relacional de ventas respondiendo preguntas de negocio mediante SQL.



## Contexto.

Se trata de una empresa *ficticia* distribuidora de muebles ubicada en México que vende tanto a mueblerias como a personas individuales, el periodo de ventas va de enero de 2025 a agosto de 2026, los totales y subtotales se manejan como unidades monetarias.



## Problema de Negocio.

Se require un análisis de la operación comercial para implementar mejoras, el objetivo es contestar las siguientes preguntas:

1. ¿Quiénes son los cinco clientes con mayor gasto realizado?
2. ¿Cómo evolucionan las ventas por mes?
3. ¿Cuáles son los tres productos menos vendidos?
4. Obtener el ranking de ventas por categoría.



## Diagrama Entidad-Relación
![ERD](https://github.com/Lighthub9/EntregablesSQL/tree/main/Imagenes/ERD-capstone_project.png)

### Esquema
![Esquema](https://github.com/Lighthub9/EntregablesSQL/tree/main/Imagenes/Capstone_project-Modelo.png)


## Limpieza y desempeño de la base de datos

- Se cuentan los nulos en campos críticos ejecutandose antes de las consultas finales, dando como resultado cero nulos en los campos de `precio`, `cantidad`, `subtotal`, `total` y `fecha_venta`.

- Se verifica que los tipos de datos `DATE` y `NUMERIC`/`DECIMAL` no fueron importados como texto haciendo la consulta `information_schema.columns`.

- Se contabiliza el volumen de datos de las diferentes tablas.

- Se generan indices `GIN` para agilizar las busquedas en las columnas `JSONB` y `FTS` con estructura de datos complejos y `B-Tree` para busquedas en los campos mas comunes.


## Hallazgos de Negocio

1. *Top 5 clientes con mayor gasto total.*

|top|cliente_id|cliente|gasto_total|pedidos_realizados|ticket_promedio|
|:-:|:--------:|:-----:|:---------:|:----------------:|:-------------:|
|1|12|Bruce Cosio|363,500.00|4|90,875.00|
|2|13|Lisa Huerta|304,000.00|7|43,428.57|
|3|46|Nami Lopez|268,500.00|3|89,500.00|
|4|38|Marvin Juarez|259,700.00|3|86,566.67|
|5|34|Moe Ferrer|239,800.00|5|47,960.00|

| |gasto|%|suma_pedidos|%|
|-----|:-:|:-:|:---------:|:-:|
|Total|6,407,100.00|100|180|100|
|Top_5|1,435,500.00|22.4|22|12.22|

Los gastos aportados por los 5 clientes top suman 1,435,500.00 que representan el 22.4% del total de las ventas realizadas, con 22 ventas concretadas (12.22%) de un total de 180 ventas, por lo que estos clientes son de alto valor, es recomendable tratarlos como un grupo especial, pudiendo implementar programas de lealtad, diseñar recompensas, descuentos o beneficios exclusivos para retenerlos. Además se pueden ofrecer productos complementarios o premium para aumentar el ticket promedio, dirigiendo campañas personalizadas y ofreciendoles atención preferente para mejorar su experiencia.

---
2. *Ventas totales por mes.*

|mes|ventas_realizadas|ventas_totales|ventas_mes_anterior|variacion_mensual|
|---|-----------------|--------------|-------------------|-----------------|
|2025-01|8|375500.00|||
|2025-02|10|237000.00|375500.00|-36.88|
|2025-03|8|388200.00|237000.00|63.80|
|2025-04|8|302800.00|388200.00|-22.00|
|2025-05|8|293100.00|302800.00|-3.20|
|2025-06|12|452900.00|293100.00|54.52|
|2025-07|10|483900.00|452900.00|6.84|
|2025-08|5|60000.00|483900.00|-87.60|
|2025-09|5|185000.00|60000.00|208.33|
|2025-10|12|624300.00|185000.00|237.46|
|2025-11|14|398800.00|624300.00|-36.12|
|2025-12|10|367900.00|398800.00|-7.75|
|2026-01|8|172600.00|367900.00|-53.09|
|2026-02|3|82600.00|172600.00|-52.14|
|2026-03|11|332800.00|82600.00|302.91|
|2026-04|7|125900.00|332800.00|-62.17|
|2026-05|13|480800.00|125900.00|281.89|
|2026-06|8|398600.00|480800.00|-17.10|
|2026-07|11|324400.00|398600.00|-18.62|
|2026-08|9|320000.00|324400.00|-1.36|

Comparando hasta el segundo cuatrimestre del año:
|Indicador|Resultado|
|:--------|:--------|
|Mes top 2025|2025-07	483,900.00|
|Mes top 2026|2026-05   480,800.00|
|Mes mas bajo 2025|2025-08  60,000.00|
|Mes mas bajo 2026|2026-02  82,600.00|
|Total ventas hasta agosto 2025|2,593,400.00|
|Total ventas hasta agosto 2026|2,237,700.00|
|Crecimiento anual hasta agosto 2026|-13.71%|

El análisis se hace hasta el mes de agosto para que la comparación 2025 - 2026 se equitativa por mes. La serie mensual no es consistente, no existen tendencias claras, los picos no se sostienen, el estudio del periodo es corto por lo que aun no se puede identificar la estacionalidad de meses fuertes y meses débiles, una vez conociendolos se pueden ajustar los inventarios para evitar excesos en meses bajos y escasez en meses altos. Hasta lo que va del año presente ha habido un decremento en las ventas totales; en el último cuatrimeste del 2025 se tuvo buen volumen de ventas, si la tendencia en este año es la misma podria cerrarse con numeros positivos, por lo que es importante evaluar el impacto de campañas y promociones establecidas en ciertos meses. 

---
3.  *3 productos menos vendidos.*

|producto_id|nombre_producto|cantidad_vendida|articulo|ingreso|
|:---------:|:-------------:|:--------------:|:------:|:-----:|
|18|Recamara Luis XV|2|recamara|52000.00|
|10|Comedor Luis XV|2|comedor|58000.00|
|2|Sala Luis XV|3|sala|96000.00|

Los productos Luis XV son los menos vendidos de todos los muebles, los tres productos con volúmenes similares, esto indica un nicho muy reducido para este estilo de muebles, la recamara es la menos vendida y la que menos ingresos genera. En el dataset no se encontraron productos con cero ventas, sin embargo el uso del `LEFT JOIN` en la busqueda de los productos sin ventas, ayudaría a mostrar con cero unidades.

El detectar estos productos evita la acumulacion del stock en el almacen ahorrando costos, se pueden generar promociones o descuentos para incentivar su venta, o se puede evaluar retirar estos productos del catalogo ya que son los mas costosos y los menos vendidos.

---
4. *Ranking de ventas por categoría.*

|categoria_id|categoria|producto|cantidad_vendida|total|ranking|
|:----------:|:-------:|:------:|:--------------:|:---:|:-----:|
|1|Sala|Sala Clasica|30|510000.00|1|
|1|Sala|Sala Mid Century|26|468000.00|2|
|1|Sala|Sala Moderna|35|444500.00|3|
|1|Sala|Sala Japandi|25|305000.00|4|
|1|Sala|Sala Industrial|21|273000.00|5|
|1|Sala|Sala Colonial|12|264000.00|6|
|1|Sala|Sala Rustica|11|242000.00|7|
|1|Sala|Sala Luis XV|3|96000.00|8|
|2|Comedor|Comedor Colonial|18|302400.00|1|
|2|Comedor|Comedor Industrial|29|295800.00|2|
|2|Comedor|Comedor Moderno|35|276500.00|3|
|2|Comedor|Comedor Rustico|14|252000.00|4|
|2|Comedor|Comedor Mid Century|21|252000.00|4|
|2|Comedor|Comedor Clasico|25|225000.00|6|
|2|Comedor|Comedor Japandi|19|161500.00|7|
|2|Comedor|Comedor Luis XV|2|58000.00|8|
|3|Recamara|Recamara Rustica|18|358200.00|1|
|3|Recamara|Recamara Japandi|26|330200.00|2|
|3|Recamara|Recamara Colonial|19|298500.00|3|
|3|Recamara|Recamara Mid Century|18|279000.00|4|
|3|Recamara|Recamara Industrial|18|246500.00|5|
|3|Recamara|Recamara Clasica|15|210000.00|6|
|3|Recamara|Recamara Moderna|18|207000.00|7|
|3|Recamara|Recamara Luis XV|2|52000.00|8|

El precio promedio por producto es clave ya que en la categoría de *Sala* la *Clásica* ocupa el ranking 1 con 30 unidades vendidas generando 510,000.00, sin emabargo la *Sala Moderna* vendió mas unidades (35) pero generó menos ingresos 444,500.00 ubicandose en el lugar 3.

Lo mismo sucede con la categoría *Comedor*, el *Colonial* lidera con 302,400 y 18 unidades vendidas, mientras el *Moderno* está en el lugar 3 generando 276,500 con 35 unidades, el producto que mas unidades vendió. En el ranking 4 empatan el *Comedor Rustico* y el *Mid Century* generando 252,000.00 cada uno.

En la categoría *Recámara* la *Rústica* está en el puesto 1 con 358,200 vendiendo 18 unidades, la *Japandi* vendió mas unidades (26) pero genero menos (330,200) quedando en el rank numero 2.

Podemos ver que el precio promedio pesa más que la cantidad vendida. El estilo Luis XV en todos los productos tienen ventas muy bajas, al ser productos costosos podria ser dirigido a un sector de lujo con ciertos gustos, o bien eliminarlo del catalogo.


## Cómo ejecutar el proyecto

Requisitos.
- PostgreSQL 12 o superior.
- DBeaver o pgAdmin 4.
- Usuario con permiso para crear bases de datos.

Pasos.
1. Conectarse a **`postgres`**.
2. Abrir el archivo **`estructura.sql`**.
3. Dar click en el boton **`Ejecutar Script SQL`**. 
![Boton](https://github.com/Lighthub9/EntregablesSQL/tree/main/Imagenes/Boton_ejecutar_script.jpg)
4. Si aparece una ventana para confirmar la ejecución de la instrucción, presionar **`Aceptar`**.
5. Dar click derecho en la base de datos **"postgres"** y presionar **`Renovar`** para visualizar **capstone_project**.  
![Refresh](https://github.com/Lighthub9/EntregablesSQL/tree/main/Imagenes/Refresh.jpg)
6. Abrir el archivo **`analisis.sql`**.
7. Dar click en el boton **`Ejecutar Script SQL`**.
8. Leer los resultados generados de cada consulta junto con el análisis que explica el propósito de negocio.


> Ojo. 👀  Si se vuelve a ejecutar el archivo `estructura.sql` se modificará, eliminando y reconstruyendo las tablas dentro de `capstone_project`.

