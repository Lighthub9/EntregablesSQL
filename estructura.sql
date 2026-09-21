/*=============================================================================
	Nombre del archivo:  estructura.sql
	Proyecto Capstone: Análisis exploratorio de datos (EDA) en PostgreSQL
		Análisis de una distribuidora de Muebles
  ============================================================================= */

/*============================================================================
   1. Configuración.
   Creacion del esquema "capstone_project" en la base de datos de "postgres".
  ============================================================================ */

CREATE SCHEMA capstone_project;
SET search_path TO capstone_project;


/*============================================================================
    El siguiente bloque crea las tablas que componen la base de datos.
  ============================================================================ */

CREATE TABLE capstone_project.ciudades(
	ciudad_id SERIAL PRIMARY KEY,
	ciudad VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE capstone_project.categorias(
	categoria_id SERIAL PRIMARY KEY,
	nombre_categoria VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE capstone_project.metodos(
	metodo_id SERIAL PRIMARY KEY,
	metodo_pago VARCHAR(20) NOT NULL,
CONSTRAINT chk_metodo_pago
	CHECK (metodo_pago IN ('tarjeta credito', 'tarjeta debito', 'transferencia', 'efectivo'))	
);

CREATE TABLE capstone_project.sucursales(
	sucursal_id SERIAL PRIMARY KEY,
	nombre_sucursal VARCHAR(30) NOT NULL UNIQUE,
	ciudad_id INT NOT NULL,
	direccion VARCHAR(200) NOT NULL,
	telefono VARCHAR(30) NOT NULL,
CONSTRAINT fk_sucursales_ciudades
	FOREIGN KEY (ciudad_id) REFERENCES ciudades(ciudad_id)
);

CREATE TABLE capstone_project.clientes(
	cliente_id SERIAL PRIMARY KEY,
	nombre VARCHAR(30) NOT NULL,
	apellido VARCHAR(30) NOT NULL,
	telefono VARCHAR(30),
	email VARCHAR(70) NOT NULL UNIQUE,
	ciudad_id INT NOT NULL,
CONSTRAINT fk_clientes_ciudades
	FOREIGN KEY (ciudad_id) REFERENCES ciudades(ciudad_id)
);

CREATE TABLE capstone_project.productos(
	producto_id SERIAL PRIMARY KEY,
	nombre_producto VARCHAR(30) NOT NULL UNIQUE,
	descripcion TEXT NOT NULL,
	categoria_id INT NOT NULL,
	precio DECIMAL(8,2) NOT NULL,
	especificaciones JSONB,
	busqueda_fts TSVECTOR,
CONSTRAINT fk_productos_categorias
	FOREIGN KEY (categoria_id) REFERENCES categorias(categoria_id),
CONSTRAINT chk_precio_valido
	CHECK(precio > 0)
);

CREATE TABLE capstone_project.ventas(
	venta_id SERIAL PRIMARY KEY,
	cliente_id INT NOT NULL,
	sucursal_id INT NOT NULL,
	fecha_venta DATE NOT NULL,
	total DECIMAL(10,2) NOT NULL,
	metodo_id INT NOT NULL,
CONSTRAINT fk_ventas_clientes
	FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id),
CONSTRAINT fk_ventas_sucursales
	FOREIGN KEY (sucursal_id) REFERENCES sucursales(sucursal_id),
CONSTRAINT chk_total_valido
	CHECK (total > 0),
CONSTRAINT fk_ventas_metodos
	FOREIGN KEY (metodo_id) REFERENCES metodos(metodo_id)
);

CREATE TABLE capstone_project.detalle_ventas(
	detalle_id SERIAL PRIMARY KEY,
	venta_id INT NOT NULL,
	producto_id INT NOT NULL,
	cantidad INT NOT NULL,
	subtotal DECIMAL(10,2) NOT NULL,
CONSTRAINT fk_detalle_ventas_ventas
	FOREIGN KEY (venta_id) REFERENCES ventas(venta_id),
CONSTRAINT fk_detalle_ventas_productos
	FOREIGN KEY (producto_id) REFERENCES productos(producto_id),
CONSTRAINT chk_cantidad_positiva
	CHECK (cantidad > 0),
CONSTRAINT chk_subtotal_valido
	CHECK (subtotal > 0)
);


/*============================================================================
    El siguiente bloque pobla las tablas con los datos correspondientes.
  ============================================================================ */

INSERT INTO ciudades (ciudad)
VALUES 
('Campeche'),
('Cancun'),
('Chetumal'),
('Ciudad de México'),
('Estado de México'),
('Guadalajara'),
('Guanajuato'),
('Leon'),
('Merida'),
('Monterrey'),
('Puerto Vallarta'),
('Queretaro'),
('San Nicolas de los Garza'),
('Toluca'),
('Zapopan');

INSERT INTO categorias (nombre_categoria)
VALUES 
('Sala'),
('Comedor'),
('Recamara');

INSERT INTO metodos (metodo_pago)
VALUES 
('tarjeta credito'),
('tarjeta debito'),
('transferencia'),
('efectivo');

INSERT INTO sucursales (nombre_sucursal, ciudad_id, direccion, telefono)
VALUES 
('Ciudad de Mexico Norte', 4, 'Calle Montevideo #123, Colonia Lindavista, Alcaldía Gustavo A. Madero, Ciudad de México', '55 1234 5678'),
('Ciudad de Mexico Sur', 4, 'Calle San Jerónimo #456, Colonia La Magdalena Contreras, Alcaldía La Magdalena Contreras, Ciudad de México', '55 5678 9012'),
('Toluca', 5, 'Avenida Morelos #789, Colonia Centro, Municipio Toluca de Lerdo, Estado de México', '722 123 4567'),
('Queretaro', 12, 'Calle Corregidora #654, Colonia Centro Histórico, Municipio Santiago de Querétaro, Querétaro', '442 123 4567'),
('Bajio', 7, 'Callejón del Beso #12, Colonia Alameda, Municipio Guanajuato, Guanajuato', '473 123 4567'),
('Norte', 10, 'Avenida Constitución #987, Colonia  Colinas de San Jeronimo , Municipio Monterrey, Nuevo León', '81 1234 5678'),
('Guadalajara', 6, 'Calle Juárez #741, Colonia Americana, Municipio Guadalajara, Jalisco', '33 1234 5678'),
('Sur', 2, 'Avenida Tulum #852, Colonia Centro, Municipio Benito Juárez (Cancun), Quintana Roo', '998 123 4567');

INSERT INTO clientes (nombre, apellido, telefono, email, ciudad_id)
VALUES 
('Bart', 'Aragon', '5512345678', 'bart.aragon@email.com', 4),
('Homero', 'Vega', '4731234567', 'homero.vega@email.com', 7),
('Pedro', 'Murguia', '5555904188', 'pedro.murguia@email.com', 5),
('Abraham', 'Jimenez', '5556789012', 'abraham.jimenez@email.com', 4),
('Peter', 'Ojeda', '5534567890', 'peter.ojeda@email.com', 4),
('Clark', 'Garcia', '4735678901', 'clark.garcia@email.com', 7),
('Lois', 'Luna', '3312345678', 'lois.luna@email.com', 6),
('Wilma', 'Derbez', '9811234567', 'wilma.derbez@email.com', 1),
('Marge', 'Aparicio', '5543210987', 'marge.aparicio@email.com', 4),
('Hanna', 'Mendez', '5545698712', 'hanna.mendez@email.com', 5),
('Patty', 'Suarez', '8198765432', 'patty.suarez@email.com', 10),
('Bruce', 'Cosio', '3356789012', 'bruce.cosio@email.com', 6),
('Lisa', 'Huerta', '4739876543', 'lisa.huerta@email.com', 7),
('Pablo', 'Herrera', '9991234567', 'pablo.herrera@email.com', 9),
('Betty', 'Higareda', '5598765432', 'betty.higareda@email.com', 4),
('Selma', 'Souza', '9831234567', 'selma.souza@email.com', 3),
('Ned', 'Barraza', '8112398765', 'ned.barraza@email.com', 10),
('Milhouse', 'Heredia', '9835678901', 'milhouse.heredia@email.com', 3),
('Shaggy', 'Gimenez', '3343210987', 'shaggy.gimenez@email.com', 6),
('Daphne', 'Guzman', '3387654321', 'daphne.guzman@email.com', 11),
('Velma', 'Muñoz', '5578922408', 'velma.muñoz@email.com', 5),
('Nelson', 'Gomez', '9995678901', 'nelson.gomez@email.com', 9),
('Ralph', 'Bravo', '9981222347', 'ralph.bravo@email.com', 2),
('Tony', 'Villarreal', '4421234567', 'tony.villarreal@email.com', 12),
('Bruce', 'Aragon', '5512398765', 'bruce.aragon@email.com', 4),
('Diana', 'Garcia', '5576543210', 'diana.garcia@email.com', 4),
('Barry ', 'Rojo', '8134567890', 'barry .rojo@email.com', 13),
('Wanda', 'Iglesias', '5577406945', 'wanda.iglesias@email.com', 5),
('Natasha', 'Mora', '4739876543', 'natasha.mora@email.com', 7),
('Steve', 'Zapata', '5598580110', 'steve.zapata@email.com', 5),
('Selina', 'Iturbide', '3312398765', 'selina.iturbide@email.com', 15),
('Mickey', 'Cortes', '9985678901', 'mickey.cortes@email.com', 2),
('Sarah', 'Vargas', '5578787878', 'sarah.vargas@email.com', 5),
('Moe', 'Ferrer', '5587654321', 'moe.ferrer@email.com', 4),
('Lenny', 'Sanchez', '5502129890', 'lenny.sanchez@email.com', 5),
('Jeff', 'Rivera', '5565892112', 'jeff.rivera@email.com', 5),
('Helen', 'Villa', '7223456789', 'helen.villa@email.com', 14),
('Marvin', 'Juarez', '5599558851', 'marvin.juarez@email.com', 4),
('Martin', 'Diaz', '4771234567', 'martin.diaz@email.com', 8),
('Felix', 'Hidalgo', '7221234567', 'felix.hidalgo@email.com', 14),
('Johnny', 'Tarso', '3221234567', 'johnny.tarso@email.com', 11),
('Dexter', 'Bernal', '5590084466', 'dexter.bernal@email.com', 4),
('Luffy', 'Almeida', '9981234567', 'luffy.almeida@email.com', 2),
('Judy', 'Davila', '8143210987', 'judy.davila@email.com', 13),
('Zoro', 'Paz', '7225678901', 'zoro.paz@email.com', 14),
('Nami', 'Lopez', '8176543210', 'nami.lopez@email.com', 10),
('Usopp', 'Romo', '4425678901', 'usopp.romo@email.com', 12),
('Kuromi', 'Rodriguez', '8187654321', 'kuromi.rodriguez@email.com', 10),
('Wendy', 'Ponce', '3376543210', 'wendy.ponce@email.com', 15),
('Charles', 'Cervantes', '4775678901', 'charles.cervantes@email.com', 8);

INSERT INTO productos (nombre_producto, descripcion, categoria_id, precio)
VALUES 
('Sala Industrial', 'Sala compuesta por sillon, love seat, sofa y mesita central en madera oscura envejecida con vivos en metal negro.', 1, 13000),
('Sala Luis XV', 'Sala compuesta por sillon, love seat, sofa y mesita central, patas curvas y ornamentadas, tallados decorativos, molduras detalladas y tapizado elegante.', 1, 32000),
('Sala Clasica', 'Sala compuesta por sillon, love seat, sofa y mesita central en madera tonos medios, diseño estructurado con proporciones balanceadas.', 1, 17000),
('Sala Rustica', 'Sala amplia compuesta por sillon, love seat, sofa y 3 pequeñas mesas en madera maciza de tonos calidos y textura organica.', 1, 22000),
('Sala Colonial', 'Sala robusta compuesta por sillon, love seat, sofa y mesita central en madera oscura de estetica tradicional.', 1, 22000),
('Sala Japandi', 'Sala confortable compuesta por sillon, love seat, sofa y mesita central en madera clara, con lineas simples.', 1, 12200),
('Sala Mid Century', 'Sala compuesta por sillon, love seat, sofa y mesita central en madera natural con formas organicas y patas inclinadas.', 1, 18000),
('Sala Moderna', 'Sala compuesta por sillon, love seat, sofa y mesita central en color neutro, diseño minimalista, enfoque funcional.', 1, 12700),
('Comedor Industrial', 'Comedor con 6 sillas y una mesa en madera oscura envejecida con marco de metal negro.', 2, 10200),
('Comedor Luis XV', 'Comedor para 10 personas con mesa amplia, patas curvas y ornamentadas, tallados decorativos, molduras detalladas y tapizado elegante.', 2, 29000),
('Comedor Clasico', 'Comedor con 4 sillas y mesa en madera de tonos medios, diseño estructurado con proporciones balanceadas.', 2, 9000),
('Comedor Rustico', 'Comedor con 8 sillas y mesa de gran tamaño en madera maciza de tonos calidos y textura organica.', 2, 18000),
('Comedor Colonial', 'Comedor robusto con 8 sillas y mesa en madera oscura de estetica tradicional.', 2, 18900),
('Comedor Japandi', 'Comedor con 4 sillas y mesa en madera clara, con lineas simples.', 2, 8500),
('Comedor Mid Century', 'Comedor con 6 sillas y una mesa en madera natural con formas organicas y patas inclinadas.', 2, 12000),
('Comedor Moderno', 'Comedor con 4 sillas y mesa en color neutro, diseño minimalista, enfoque funcional.', 2, 7900),
('Recamara Industrial', 'Recamara compuesta por base para colchon, cabecera, dos buroes y tocador en madera oscura envejecida con vivos en metal negro', 3, 14500),
('Recamara Luis XV', 'Recamara compuesta por base para colchon, cabecera, dos buroes, tocador y taburete, patas curvas y ornamentadas, tallados decorativos, molduras detalladas y tapizado elegante.', 3, 26000),
('Recamara Clasica', 'Recamara compuesta por base para colchon, cabecera y dos buroes en madera de tonos medios, diseño estructurado con proporciones balanceadas.', 3, 14000),
('Recamara Rustica', 'Recamara compuesta por base para colchon, cabecera, dos buroes, tocador y taburete en madera maciza de tonos calidos y textura organica.', 3, 19900),
('Recamara Colonial', 'Recamara compuesta por base para colchon, cabecera, dos buroes, tocador y taburete en madera oscura de estetica tradicional.', 3, 18000),
('Recamara Japandi', 'Recamara compuesta por base para colchon, cabecera y dos buroes en madera clara, con lineas simples.', 3, 12700),
('Recamara Mid Century', 'Recamara compuesta por base para colchon, cabecera, dos buroes, tocador y taburete en madera natural con formas organicas y patas inclinadas.', 3, 15500),
('Recamara Moderna', 'Recamara compuesta por base para colchon, cabecera y dos buroes en color neutro, diseño minimalista, enfoque funcional.', 3, 11500);

UPDATE productos
SET especificaciones = '{"metal": "negro", "color": "oscuro", "madera": "envejecida", "articulo": "sala"}'
WHERE producto_id = 1;

UPDATE productos
SET especificaciones = '{"forma": "curva", "patas": "ornamentadas", "molduras": "detalladas", "tapizados": "elegantes", "articulo": "sala"}'
WHERE producto_id = 2;

UPDATE productos
SET especificaciones = '{"madera": "fuerte", "tono": "medio", "diseño": "estructurado", "proporcion": "balanceada", "articulo": "sala"}'
WHERE producto_id = 3; 

UPDATE productos
SET especificaciones = '{"madera": "maciza", "tono": "calido", "textura": "organica", "articulo": "sala"}'
WHERE producto_id = 4;

UPDATE productos
SET especificaciones = '{"mueble": "robusto", "madera": "oscura", "presencia": "fuerte", "estetica": "tradicional", "articulo": "sala"}'
WHERE producto_id = 5;

UPDATE productos
SET especificaciones = '{"lineas": "simples", "madera": "clara", "funcionalidad": "silenciosa", "articulo": "sala"}'
WHERE producto_id = 6;

UPDATE productos
SET especificaciones = '{"patas": "inclinadas", "formas": "organicas", "madera": "natural", "diseño": "funcional", "articulo": "sala"}'
WHERE producto_id = 7;

UPDATE productos
SET especificaciones = '{"color": "neutro", "diseño": "minimalista", "enfoque": "funcional", "articulo": "sala"}'
WHERE producto_id = 8;

UPDATE productos
SET especificaciones = '{"metal": "negro", "tono": "oscuro", "madera": "envejecida", "articulo": "comedor"}'
WHERE producto_id = 9;

UPDATE productos
SET especificaciones = '{"forma": "curva", "patas": "ornamentadas", "molduras": "detalladas",  "tapizados": "elegantes", "articulo": "comedor"}'
WHERE producto_id = 10;

UPDATE productos
SET especificaciones = '{"tono": "medio", "diseño": "estructurado", "proporcion": "balanceada", "articulo": "comedor"}'
WHERE producto_id = 11;

UPDATE productos
SET especificaciones = '{"madera": "maciza", "tono": "calido", "textura": "organica", "articulo": "comedor"}'
WHERE producto_id = 12;

UPDATE productos
SET especificaciones = '{"mueble": "robusto", "madera": "oscura", "presencia": "fuerte", "estetica": "tradicional", "articulo": "comedor"}'
WHERE producto_id = 13;

UPDATE productos
SET especificaciones = '{"lineas": "simples", "madera": "clara", "funcionalidad": "silenciosa", "articulo": "comedor"}'
WHERE producto_id = 14;

UPDATE productos
SET especificaciones = '{"patas": "inclinadas", "formas": "organicas", "madera": "natural", "diseño": "funcional", "articulo": "comedor"}'
WHERE producto_id = 15;

UPDATE productos
SET especificaciones = '{"color": "neutro", "diseño": "minimalista", "enfoque": "funcional", "articulo": "comedor"}'
WHERE producto_id = 16;

UPDATE productos
SET especificaciones = '{"metal": "negro", "tono": "oscuro", "madera": "envejecida", "articulo": "recamara"}'
WHERE producto_id = 17;

UPDATE productos
SET especificaciones = '{"forma": "curva", "patas": "ornamentadas", "molduras": "detalladas", "tapizados": "elegantes", "articulo": "recamara"}'
WHERE producto_id = 18;

UPDATE productos
SET especificaciones = '{"madera": "fuerte", "tono": "medio", "diseño": "estructurado", "proporcion": "balanceada", "articulo": "recamara"}'
WHERE producto_id = 19;

UPDATE productos
SET especificaciones = '{"madera": "maciza", "tono": "calido", "textura": "organica", "articulo": "recamara"}'
WHERE producto_id = 20;

UPDATE productos
SET especificaciones = '{"mueble": "robusto", "madera": "oscura", "presencia": "fuerte", "estetica": "tradicional", "articulo": "recamara"}'
WHERE producto_id = 21;

UPDATE productos
SET especificaciones = '{"lineas": "simples", "madera": "clara", "funcionalidad": "silenciosa", "articulo": "recamara"}'
WHERE producto_id = 22;

UPDATE productos
SET especificaciones = '{"patas": "inclinadas", "formas": "organicas", "madera": "natural", "diseño": "funcional", "articulo": "recamara"}'
WHERE producto_id = 23;

UPDATE productos
SET especificaciones = '{"color": "neutro", "diseño": "minimalista", "enfoque": "funcional", "articulo": "recamara"}'
WHERE producto_id = 24;

UPDATE productos
SET busqueda_fts = to_tsvector('spanish', nombre_producto || ' ' || descripcion);

INSERT INTO ventas (cliente_id, sucursal_id, fecha_venta, total, metodo_id)
VALUES 
(1, 2, '2025/04/04', 59900, 1),
(4, 7, '2026/06/26', 9000, 3),
(38, 8, '2025/10/04', 179000, 1),
(21, 5, '2026/06/30', 87000, 1),
(36, 1, '2025/10/11', 62000, 1),
(3, 4, '2025/12/09', 15500, 3),
(1, 5, '2025/03/06', 10200, 1),
(12, 2, '2025/07/09', 48200, 1),
(1, 3, '2025/10/02', 8500, 1),
(26, 1, '2026/03/24', 24000, 3),
(16, 6, '2025/08/19', 9000, 1),
(42, 2, '2025/01/06', 44000, 3),
(15, 2, '2026/05/01', 110800, 1),
(21, 6, '2025/06/19', 12700, 3),
(43, 1, '2025/10/23', 9000, 3),
(45, 3, '2026/07/31', 15800, 3),
(43, 1, '2026/01/07', 17000, 3),
(50, 4, '2025/12/05', 22000, 3),
(9, 7, '2026/01/04', 10200, 1),
(37, 7, '2025/08/18', 14500, 1),
(37, 4, '2026/05/26', 12000, 1),
(49, 2, '2026/03/10', 26500, 2),
(42, 2, '2026/05/15', 22000, 3),
(46, 4, '2025/12/08', 37800, 1),
(7, 1, '2025/03/23', 9000, 4),
(19, 4, '2026/01/02', 14000, 2),
(16, 5, '2026/07/12', 91400, 1),
(16, 8, '2025/04/25', 19900, 3),
(5, 5, '2026/08/14', 18000, 3),
(45, 6, '2025/07/27', 18900, 2),
(29, 8, '2025/05/29', 40000, 1),
(24, 6, '2026/03/13', 26000, 1),
(1, 1, '2025/12/21', 32100, 1),
(6, 8, '2026/02/07', 36600, 1),
(19, 5, '2025/07/08', 10200, 3),
(36, 1, '2025/11/21', 23700, 1),
(46, 2, '2025/05/31', 38100, 1),
(36, 8, '2026/08/01', 18900, 2),
(43, 6, '2025/11/05', 31600, 1),
(13, 2, '2025/01/21', 36000, 1),
(26, 6, '2026/08/01', 13000, 3),
(13, 5, '2025/06/26', 99500, 1),
(21, 3, '2026/04/11', 11500, 3),
(43, 8, '2025/02/05', 14000, 1),
(28, 5, '2025/10/12', 77600, 1),
(33, 5, '2025/04/06', 58000, 1),
(38, 3, '2025/12/21', 63700, 1),
(4, 1, '2026/07/25', 19900, 3),
(50, 3, '2026/03/16', 55000, 1),
(17, 6, '2025/03/21', 26000, 1),
(26, 2, '2025/11/06', 26000, 3),
(5, 3, '2025/09/29', 36000, 1),
(38, 6, '2025/09/26', 17000, 2),
(11, 1, '2025/09/23', 72000, 1),
(35, 7, '2026/07/28', 12000, 2),
(49, 5, '2026/03/22', 10200, 3),
(16, 6, '2025/02/19', 24400, 3),
(14, 2, '2025/12/12', 60900, 1),
(43, 8, '2026/03/04', 63500, 1),
(40, 3, '2025/06/27', 14000, 4),
(10, 1, '2025/04/29', 18000, 2),
(5, 4, '2026/03/22', 65000, 1),
(49, 1, '2025/03/01', 30600, 1),
(15, 6, '2025/01/31', 51000, 1),
(9, 3, '2026/01/01', 60400, 1),
(46, 7, '2026/06/05', 192600, 1),
(16, 8, '2025/06/28', 48600, 1),
(6, 7, '2025/12/09', 7900, 4),
(32, 2, '2025/04/07', 100000, 1),
(4, 1, '2025/10/06', 56700, 1),
(24, 1, '2025/02/17', 50800, 3),
(40, 2, '2025/03/06', 34000, 1),
(15, 6, '2026/05/10', 13000, 1),
(4, 4, '2025/07/29', 75000, 1),
(10, 3, '2025/05/31', 24400, 3),
(28, 8, '2026/08/26', 63500, 1),
(41, 1, '2025/11/15', 18000, 3),
(2, 6, '2026/04/17', 11500, 4),
(41, 4, '2026/08/11', 64000, 1),
(12, 4, '2025/01/27', 150100, 1),
(34, 2, '2025/08/22', 12000, 2),
(34, 6, '2026/05/05', 62100, 1),
(23, 8, '2025/05/18', 12700, 1),
(37, 7, '2025/03/03', 62400, 1),
(13, 1, '2025/11/28', 36000, 1),
(30, 8, '2025/06/28', 15500, 3),
(5, 5, '2025/10/03', 46500, 1),
(49, 1, '2025/10/26', 24400, 1),
(22, 7, '2025/07/13', 22000, 1),
(43, 4, '2025/07/15', 17000, 2),
(4, 3, '2026/05/04', 8500, 3),
(4, 3, '2025/09/02', 9000, 4),
(30, 2, '2025/01/22', 22400, 3),
(14, 8, '2026/06/19', 43600, 1),
(41, 7, '2025/11/21', 18000, 1),
(24, 3, '2025/06/19', 19900, 1),
(40, 1, '2025/02/14', 31000, 1),
(41, 7, '2026/01/08', 18900, 1),
(21, 2, '2026/05/28', 58000, 1),
(34, 7, '2025/02/01', 32900, 1),
(8, 3, '2025/10/31', 14000, 1),
(7, 5, '2025/10/20', 8500, 2),
(14, 8, '2026/08/22', 68000, 1),
(24, 2, '2026/08/09', 24400, 1),
(47, 8, '2026/04/10', 12700, 1),
(33, 8, '2026/03/16', 12700, 3),
(34, 6, '2025/06/08', 100800, 1),
(3, 2, '2026/04/26', 28200, 1),
(25, 5, '2026/06/14', 28000, 1),
(11, 5, '2026/02/22', 29000, 1),
(5, 2, '2025/05/10', 34000, 1),
(10, 8, '2025/09/16', 51000, 1),
(10, 3, '2025/05/30', 96100, 1),
(13, 2, '2026/06/20', 12700, 2),
(34, 7, '2025/05/22', 32000, 1),
(40, 4, '2025/07/11', 86600, 1),
(42, 3, '2025/01/13', 50800, 1),
(10, 2, '2025/01/24', 8500, 2),
(30, 3, '2026/03/22', 18000, 1),
(36, 1, '2025/11/16', 72000, 1),
(13, 2, '2025/02/02', 22000, 1),
(35, 7, '2025/04/11', 18000, 1),
(45, 8, '2025/11/22', 19900, 1),
(45, 5, '2026/01/17', 14000, 2),
(12, 7, '2025/03/12', 152200, 1),
(21, 7, '2026/05/15', 22000, 1),
(48, 3, '2026/05/02', 56700, 1),
(15, 3, '2025/02/26', 18000, 1),
(15, 8, '2026/07/12', 9000, 3),
(30, 7, '2026/03/06', 18900, 1),
(33, 4, '2025/10/18', 20700, 1),
(15, 3, '2025/11/02', 20400, 3),
(50, 4, '2026/08/20', 40000, 1),
(22, 3, '2026/04/29', 22000, 3),
(11, 3, '2026/05/26', 72000, 1),
(41, 3, '2025/06/16', 18900, 1),
(29, 3, '2025/11/22', 63500, 1),
(28, 5, '2025/12/08', 13000, 2),
(50, 2, '2025/07/20', 23200, 1),
(18, 2, '2025/11/04', 8500, 4),
(20, 2, '2026/07/06', 11500, 2),
(23, 8, '2025/06/24', 15500, 1),
(5, 3, '2025/04/13', 14500, 1),
(23, 1, '2025/10/06', 117400, 1),
(24, 5, '2025/11/19', 40000, 1),
(16, 5, '2025/07/12', 18900, 1),
(16, 2, '2025/06/05', 11500, 1),
(48, 3, '2026/05/27', 12200, 3),
(9, 3, '2026/03/21', 13000, 2),
(39, 1, '2025/11/19', 12700, 3),
(11, 4, '2025/06/06', 10200, 2),
(50, 5, '2026/05/28', 17000, 1),
(33, 7, '2026/07/30', 18000, 1),
(14, 6, '2025/12/10', 12000, 1),
(14, 6, '2026/07/27', 24000, 1),
(42, 8, '2025/03/22', 63800, 1),
(35, 3, '2025/07/26', 163900, 1),
(28, 6, '2026/07/15', 84900, 1),
(47, 1, '2025/08/31', 11500, 1),
(32, 7, '2026/08/01', 10200, 2),
(29, 5, '2026/06/25', 10200, 1),
(13, 8, '2025/02/20', 12000, 1),
(43, 3, '2026/05/14', 14500, 3),
(12, 4, '2025/08/26', 13000, 1),
(42, 2, '2026/07/15', 18000, 1),
(35, 7, '2025/05/25', 15800, 3),
(20, 7, '2025/02/24', 13000, 3),
(30, 7, '2026/04/26', 18000, 1),
(1, 4, '2025/01/03', 12700, 3),
(17, 4, '2025/04/29', 14500, 2),
(27, 2, '2026/06/18', 15500, 1),
(27, 4, '2025/12/08', 103000, 1),
(41, 6, '2026/04/12', 22000, 1),
(8, 7, '2026/07/10', 19900, 1),
(22, 3, '2026/02/13', 17000, 1),
(14, 7, '2025/02/16', 18900, 1),
(42, 1, '2025/11/27', 8500, 4),
(13, 6, '2025/06/16', 85800, 1),
(8, 4, '2026/01/13', 7900, 2),
(41, 2, '2026/01/14', 30200, 1);

INSERT INTO detalle_ventas (venta_id, producto_id, cantidad, subtotal)
VALUES 
(1, 4, 1, 22000),
(1, 12, 1, 18000),
(1, 20, 1, 19900),
(2, 11, 1, 9000),
(3, 1, 3, 39000),
(3, 17, 2, 14500),
(3, 12, 2, 36000),
(3, 24, 5, 57500),
(3, 21, 1, 18000),
(3, 19, 1, 14000),
(4, 2, 1, 32000),
(4, 10, 1, 29000),
(4, 18, 1, 26000),
(5, 8, 2, 25400),
(5, 6, 3, 36600),
(6, 23, 1, 15500),
(7, 9, 1, 10200),
(8, 7, 2, 36000),
(8, 6, 1, 12200),
(9, 14, 1, 8500),
(10, 15, 2, 24000),
(11, 11, 1, 9000),
(12, 5, 2, 44000),
(13, 11, 3, 27000),
(13, 19, 2, 28000),
(13, 17, 1, 14500),
(13, 14, 3, 25500),
(13, 16, 2, 15800),
(14, 22, 1, 12700),
(15, 11, 1, 9000),
(16, 16, 2, 15800),
(17, 3, 1, 17000),
(18, 4, 1, 22000),
(19, 9, 1, 10200),
(20, 17, 1, 14500),
(21, 15, 1, 12000),
(22, 21, 1, 18000),
(22, 14, 1, 8500),
(23, 4, 1, 22000),
(24, 13, 2, 37800),
(25, 11, 1, 9000),
(26, 19, 1, 14000),
(27, 6, 2, 24400),
(27, 23, 2, 31000),
(27, 7, 2, 36000),
(28, 20, 1, 19900),
(29, 21, 1, 18000),
(30, 13, 1, 18900),
(31, 5, 1, 22000),
(31, 12, 1, 18000),
(32, 3, 1, 17000),
(32, 11, 1, 9000),
(33, 24, 1, 11500),
(33, 16, 1, 7900),
(33, 8, 1, 12700),
(34, 6, 3, 36600),
(35, 9, 1, 10200),
(36, 16, 3, 23700),
(37, 8, 3, 38100),
(38, 13, 1, 18900),
(39, 16, 4, 31600),
(40, 12, 2, 36000),
(41, 1, 1, 13000),
(42, 20, 5, 99500),
(43, 24, 1, 11500),
(44, 19, 1, 14000),
(45, 8, 3, 38100),
(45, 16, 5, 39500),
(46, 17, 4, 58000),
(47, 22, 1, 12700),
(47, 3, 3, 51000),
(48, 20, 1, 19900),
(49, 23, 3, 46500),
(49, 14, 1, 8500),
(50, 1, 2, 26000),
(51, 18, 1, 26000),
(52, 11, 4, 36000),
(53, 14, 2, 17000),
(54, 21, 4, 72000),
(55, 15, 1, 12000),
(56, 9, 1, 10200),
(57, 6, 2, 24400),
(58, 13, 1, 18900),
(58, 19, 3, 42000),
(59, 22, 5, 63500),
(60, 19, 1, 14000),
(61, 12, 1, 18000),
(62, 1, 5, 65000),
(63, 9, 3, 30600),
(64, 3, 3, 51000),
(65, 6, 2, 24400),
(65, 15, 3, 36000),
(66, 7, 4, 72000),
(66, 9, 1, 10200),
(66, 23, 2, 31000),
(66, 7, 3, 54000),
(66, 8, 2, 25400),
(67, 21, 3, 18000),
(67, 9, 3, 30600),
(68, 16, 1, 7900),
(69, 9, 2, 20400),
(69, 20, 4, 79600),
(70, 13, 3, 56700),
(71, 22, 4, 50800),
(72, 3, 2, 34000),
(73, 1, 1, 13000),
(74, 17, 2, 29000),
(74, 24, 4, 46000),
(75, 6, 2, 24400),
(76, 8, 5, 63500),
(77, 7, 1, 18000),
(78, 24, 1, 11500),
(79, 1, 1, 13000),
(79, 3, 3, 51000),
(80, 8, 3, 38100),
(80, 2, 1, 32000),
(80, 19, 1, 14000),
(80, 11, 2, 18000),
(80, 16, 2, 15800),
(80, 9, 1, 10200),
(80, 4, 1, 22000),
(81, 15, 1, 12000),
(82, 22, 3, 38100),
(82, 15, 2, 24000),
(83, 8, 1, 12700),
(84, 17, 2, 29000),
(84, 9, 2, 20400),
(84, 1, 1, 13000),
(85, 11, 4, 36000),
(86, 23, 1, 15500),
(87, 21, 3, 46500),
(88, 6, 2, 24400),
(89, 5, 1, 22000),
(90, 14, 2, 17000),
(91, 14, 1, 8500),
(92, 11, 1, 9000),
(93, 17, 1, 14500),
(93, 16, 1, 7900),
(94, 9, 3, 30600),
(94, 1, 1, 13000),
(95, 21, 1, 18000),
(96, 20, 1, 19900),
(97, 23, 2, 31000),
(98, 13, 3, 18900),
(99, 4, 1, 22000),
(99, 21, 2, 36000),
(100, 1, 1, 13000),
(100, 20, 1, 19900),
(101, 19, 1, 14000),
(102, 14, 1, 8500),
(103, 3, 4, 68000),
(104, 6, 2, 24400),
(105, 22, 1, 12700),
(106, 8, 1, 12700),
(107, 23, 1, 15500),
(107, 4, 2, 44000),
(107, 16, 2, 15800),
(107, 14, 3, 25500),
(108, 9, 1, 10200),
(108, 11, 2, 18000),
(109, 19, 2, 28000),
(110, 10, 1, 29000),
(111, 3, 2, 34000),
(112, 3, 3, 51000),
(113, 20, 1, 19900),
(113, 8, 4, 50800),
(113, 22, 2, 25400),
(114, 8, 1, 12700),
(115, 2, 1, 32000),
(116, 9, 3, 30600),
(116, 5, 1, 22000),
(116, 3, 2, 34000),
(117, 22, 4, 50800),
(118, 14, 1, 8500),
(119, 7, 1, 18000),
(120, 12, 4, 72000),
(121, 5, 1, 22000),
(122, 21, 1, 18000),
(123, 20, 1, 19900),
(124, 19, 1, 14000),
(125, 8, 2, 25400),
(125, 12, 2, 36000),
(125, 5, 2, 44000),
(125, 23, 2, 31000),
(125, 16, 2, 15800),
(126, 5, 1, 22000),
(127, 13, 3, 56700),
(128, 21, 1, 18000),
(129, 11, 1, 9000),
(130, 13, 1, 18900),
(131, 6, 1, 12200),
(131, 14, 1, 8500),
(132, 9, 2, 20400),
(133, 19, 1, 14000),
(133, 11, 1, 9000),
(133, 3, 1, 17000),
(134, 4, 1, 22000),
(135, 7, 4, 72000),
(136, 13, 1, 18900),
(137, 22, 5, 63500),
(138, 1, 1, 13000),
(139, 1, 1, 13000),
(139, 9, 1, 10200),
(140, 14, 1, 8500),
(141, 24, 1, 11500),
(142, 23, 1, 15500),
(143, 17, 1, 14500),
(144, 8, 2, 25400),
(144, 16, 5, 39500),
(144, 24, 3, 34500),
(144, 7, 1, 18000),
(145, 4, 1, 22000),
(145, 12, 1, 18000),
(146, 13, 1, 18900),
(147, 24, 1, 11500),
(148, 6, 1, 12200),
(149, 1, 1, 13000),
(150, 8, 1, 12700),
(151, 9, 1, 10200),
(152, 3, 1, 17000),
(153, 11, 2, 18000),
(154, 15, 1, 12000),
(155, 15, 2, 24000),
(156, 15, 4, 48000),
(156, 16, 2, 15800),
(157, 4, 2, 44000),
(157, 5, 2, 44000),
(157, 8, 1, 12700),
(157, 3, 3, 51000),
(157, 6, 1, 12200),
(158, 17, 2, 29000),
(158, 20, 1, 19900),
(158, 7, 2, 36000),
(159, 24, 1, 11500),
(160, 9, 1, 10200),
(161, 9, 1, 10200),
(162, 15, 1, 12000),
(163, 17, 1, 14500),
(164, 1, 1, 13000),
(165, 7, 1, 18000),
(166, 16, 2, 15800),
(167, 1, 1, 13000),
(168, 7, 1, 18000),
(169, 8, 1, 12700),
(170, 17, 1, 14500),
(171, 23, 1, 15500),
(172, 23, 2, 31000),
(172, 15, 3, 36000),
(172, 7, 2, 36000),
(173, 5, 1, 22000),
(174, 20, 1, 19900),
(175, 3, 1, 17000),
(176, 13, 1, 18900),
(177, 14, 1, 8500),
(178, 8, 2, 25400),
(178, 7, 2, 36000),
(178, 6, 2, 24400),
(179, 16, 1, 7900),
(180, 21, 1, 18000),
(180, 6, 1, 12200);


/*==============================================================================
    El siguiente bloque crea los Indices para agilizar busquedas.
  ============================================================================== */

CREATE INDEX idx_clientes_apellido ON clientes (apellido);
CREATE INDEX idx_productos_nombre_producto ON productos (nombre_producto);
CREATE INDEX idx_ventas_cliente_id ON ventas (cliente_id);
CREATE INDEX idx_productos_especificaciones ON productos USING GIN (especificaciones);
CREATE INDEX idx_productos_busqueda_fts ON productos USING GIN (busqueda_fts);

