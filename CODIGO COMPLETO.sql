DROP DATABASE IF EXISTS pizzeria_don_piccolo;
CREATE DATABASE pizzeria_don_piccolo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE pizzeria_don_piccolo;

CREATE TABLE cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    direccion VARCHAR(150) NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE pizza (
    id_pizza INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    tamano ENUM('Personal', 'Mediana', 'Familiar') NOT NULL,
    precio_base DECIMAL(10, 2) NOT NULL,
    tipo ENUM('clasica', 'especial', 'vegetariana') NOT NULL,
    disponible BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE ingrediente (
    id_ingrediente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    stock_actual DECIMAL(10, 2) NOT NULL,
    stock_minimo DECIMAL(10, 2) NOT NULL,
    costo_unitario DECIMAL(10, 2) NOT NULL,
    unidad_medida VARCHAR(20) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE receta (
    id_pizza INT NOT NULL,
    id_ingrediente INT NOT NULL,
    cantidad_requerida DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (id_pizza, id_ingrediente),
    FOREIGN KEY (id_pizza) REFERENCES pizza(id_pizza) ON DELETE CASCADE,
    FOREIGN KEY (id_ingrediente) REFERENCES ingrediente(id_ingrediente) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE repartidor (
    id_repartidor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    zona_asignada VARCHAR(80) NOT NULL,
    estado ENUM('disponible', 'no disponible') DEFAULT 'disponible'
) ENGINE=InnoDB;

CREATE TABLE pedido (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    metodo_pago ENUM('efectivo', 'tarjeta', 'app') NOT NULL,
    estado ENUM('pendiente', 'en preparacion', 'entregado', 'cancelado') DEFAULT 'pendiente',
    costo_envio DECIMAL(10, 2) DEFAULT 0.00,
    total DECIMAL(10, 2) DEFAULT 0.00,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE detalle_pedido (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_pizza INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE CASCADE,
    FOREIGN KEY (id_pizza) REFERENCES pizza(id_pizza) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE domicilio (
    id_domicilio INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT UNIQUE NOT NULL,
    id_repartidor INT NOT NULL,
    hora_salida DATETIME NULL,
    hora_entrega DATETIME NULL,
    distancia_km DECIMAL(5, 2) NOT NULL,
    costo_envio DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE CASCADE,
    FOREIGN KEY (id_repartidor) REFERENCES repartidor(id_repartidor) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE historial_precios (
    id_historial INT AUTO_INCREMENT PRIMARY KEY,
    id_pizza INT NOT NULL,
    precio_anterior DECIMAL(10, 2) NOT NULL,
    precio_nuevo DECIMAL(10, 2) NOT NULL,
    fecha_cambio DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pizza) REFERENCES pizza(id_pizza) ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT INTO cliente (nombre, telefono, direccion, correo) VALUES
('Sara Sandoval', '3001234567', 'Calle 10 #20-30', 'sara@email.com'),
('Carlos Mendoza', '3159876543', 'Carrera 15 #45-12', 'carlos@email.com'),
('Ana Gómez', '3104567890', 'Avenida 8 #12-04', 'ana@email.com');

INSERT INTO pizza (nombre, tamano, precio_base, tipo, disponible) VALUES
('Especial Don Piccolo', 'Familiar', 35000.00, 'especial', TRUE),
('Hawaiana', 'Mediana', 28000.00, 'clasica', TRUE),
('Pepperoni', 'Personal', 18000.00, 'clasica', TRUE),
('Vegetariana', 'Familiar', 32000.00, 'vegetariana', TRUE);

INSERT INTO ingrediente (nombre, stock_actual, stock_minimo, costo_unitario, unidad_medida) VALUES
('Queso Mozzarella', 50.00, 10.00, 12000.00, 'Kg'),
('Salsa de Tomate', 30.00, 5.00, 5000.00, 'Litro'),
('Pepperoni', 20.00, 3.00, 18000.00, 'Kg'),
('Masa para Pizza', 100.00, 20.00, 2000.00, 'Unidad');

INSERT INTO receta (id_pizza, id_ingrediente, cantidad_requerida) VALUES
(1, 1, 0.40),
(1, 2, 0.20),
(1, 3, 0.25),
(2, 1, 0.30),
(2, 2, 0.15);

INSERT INTO repartidor (nombre, zona_asignada, estado) VALUES
('Pedro Infante', 'Zona Norte', 'disponible'),
('Luisa López', 'Zona Centro', 'disponible'),
('Carlos Rueda', 'Zona Sur', 'no disponible');

INSERT INTO pedido (id_cliente, fecha_hora, metodo_pago, estado, costo_envio, total) VALUES
(1, NOW(), 'efectivo', 'entregado', 5000.00, 40000.00),
(2, NOW(), 'tarjeta', 'en preparacion', 4000.00, 32000.00),
(3, NOW(), 'app', 'pendiente', 3000.00, 21000.00);

INSERT INTO detalle_pedido (id_pedido, id_pizza, cantidad, precio_unitario) VALUES
(1, 1, 1, 35000.00),
(2, 2, 1, 28000.00),
(3, 3, 1, 18000.00);

INSERT INTO domicilio (id_pedido, id_repartidor, hora_salida, hora_entrega, distancia_km, costo_envio) VALUES
(1, 1, NOW(), NOW(), 3.50, 5000.00),
(2, 2, NOW(), NULL, 2.10, 4000.00);

INSERT INTO historial_precios (id_pizza, precio_anterior, precio_nuevo, fecha_cambio) VALUES
(1, 32000.00, 35000.00, NOW()),
(2, 25000.00, 28000.00, NOW());

DELIMITER $$

DROP FUNCTION IF EXISTS fn_calcular_total_pedido$$
CREATE FUNCTION fn_calcular_total_pedido(p_id_pedido INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_subtotal DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_costo_envio DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_total DECIMAL(10,2) DEFAULT 0.00;

    SELECT IFNULL(SUM(cantidad * precio_unitario), 0.00) 
    INTO v_subtotal 
    FROM detalle_pedido 
    WHERE id_pedido = p_id_pedido;

    SELECT IFNULL(costo_envio, 0.00) 
    INTO v_costo_envio 
    FROM domicilio 
    WHERE id_pedido = p_id_pedido;

    SET v_total = (v_subtotal + v_costo_envio) * 1.19;

    RETURN v_total;
END$$

DROP FUNCTION IF EXISTS fn_ganancia_neta_diaria$$
CREATE FUNCTION fn_ganancia_neta_diaria(p_fecha DATE) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total_ventas DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_total_costos DECIMAL(10,2) DEFAULT 0.00;

    SELECT IFNULL(SUM(total), 0.00) 
    INTO v_total_ventas 
    FROM pedido 
    WHERE DATE(fecha_hora) = p_fecha AND estado != 'cancelado';

    SELECT IFNULL(SUM(dp.cantidad * r.cantidad_requerida * ing.costo_unitario), 0.00)
    INTO v_total_costos
    FROM pedido p
    JOIN detalle_pedido dp ON p.id_pedido = dp.id_pedido
    JOIN receta r ON dp.id_pizza = r.id_pizza
    JOIN ingrediente ing ON r.id_ingrediente = ing.id_ingrediente
    WHERE DATE(p.fecha_hora) = p_fecha AND p.estado != 'cancelado';

    RETURN v_total_ventas - v_total_costos;
END$$

DROP PROCEDURE IF EXISTS sp_registrar_entrega_domicilio$$
CREATE PROCEDURE sp_registrar_entrega_domicilio(
    IN p_id_domicilio INT,
    IN p_hora_entrega DATETIME
)
BEGIN
    DECLARE v_id_pedido INT;

    SELECT id_pedido INTO v_id_pedido 
    FROM domicilio 
    WHERE id_domicilio = p_id_domicilio;

    IF v_id_pedido IS NOT NULL THEN
        UPDATE domicilio 
        SET hora_entrega = p_hora_entrega 
        WHERE id_domicilio = p_id_domicilio;

        UPDATE pedido 
        SET estado = 'entregado' 
        WHERE id_pedido = v_id_pedido;
    END IF;
END$$

DROP PROCEDURE IF EXISTS sp_registrar_detalle_pedido$$
CREATE PROCEDURE sp_registrar_detalle_pedido(
    IN p_id_pedido INT,
    IN p_id_pizza INT,
    IN p_cantidad INT,
    IN p_precio_unitario DECIMAL(10,2)
)
BEGIN
    INSERT INTO detalle_pedido (id_pedido, id_pizza, cantidad, precio_unitario)
    VALUES (p_id_pedido, p_id_pizza, p_cantidad, p_precio_unitario);
END$$

DROP TRIGGER IF EXISTS trg_descontar_stock_ingredientes$$
CREATE TRIGGER trg_descontar_stock_ingredientes
AFTER INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
    UPDATE ingrediente ing
    JOIN receta r ON ing.id_ingrediente = r.id_ingrediente
    SET ing.stock_actual = ing.stock_actual - (r.cantidad_requerida * NEW.cantidad)
    WHERE r.id_pizza = NEW.id_pizza;
END$$

DROP TRIGGER IF EXISTS trg_auditoria_precio_pizza$$
CREATE TRIGGER trg_auditoria_precio_pizza
BEFORE UPDATE ON pizza
FOR EACH ROW
BEGIN
    IF OLD.precio_base <> NEW.precio_base THEN
        INSERT INTO historial_precios (id_pizza, precio_anterior, precio_nuevo, fecha_cambio)
        VALUES (OLD.id_pizza, OLD.precio_base, NEW.precio_base, NOW());
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_liberar_repartidor$$
CREATE TRIGGER trg_liberar_repartidor
AFTER UPDATE ON domicilio
FOR EACH ROW
BEGIN
    IF OLD.hora_entrega IS NULL AND NEW.hora_entrega IS NOT NULL THEN
        UPDATE repartidor 
        SET estado = 'disponible' 
        WHERE id_repartidor = NEW.id_repartidor;
    END IF;
END$$

DELIMITER ;

DROP USER IF EXISTS 'supervisor_cocina'@'localhost';
CREATE USER 'supervisor_cocina'@'localhost' IDENTIFIED BY 'Cocina2026*';
GRANT SELECT ON pizzeria_don_piccolo.* TO 'supervisor_cocina'@'localhost';
GRANT EXECUTE ON PROCEDURE pizzeria_don_piccolo.sp_registrar_detalle_pedido TO 'supervisor_cocina'@'localhost';
FLUSH PRIVILEGES;

CREATE OR REPLACE VIEW vw_resumen_pedidos_cliente AS
SELECT 
    c.id_cliente,
    c.nombre AS nombre_cliente,
    COUNT(p.id_pedido) AS cantidad_pedidos,
    IFNULL(SUM(p.total), 0.00) AS total_gastado
FROM cliente c
LEFT JOIN pedido p ON c.id_cliente = p.id_cliente AND p.estado != 'cancelado'
GROUP BY c.id_cliente, c.nombre;

CREATE OR REPLACE VIEW vw_desempeno_repartidores AS
SELECT 
    r.id_repartidor,
    r.nombre AS repartidor,
    r.zona_asignada,
    COUNT(d.id_domicilio) AS total_entregas,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, d.hora_salida, d.hora_entrega)), 1) AS tiempo_promedio_min
FROM repartidor r
JOIN domicilio d ON r.id_repartidor = d.id_repartidor
WHERE d.hora_entrega IS NOT NULL
GROUP BY r.id_repartidor, r.nombre, r.zona_asignada;

CREATE OR REPLACE VIEW vw_stock_ingredientes_critico AS
SELECT 
    id_ingrediente,
    nombre,
    stock_actual,
    stock_minimo,
    unidad_medida,
    (stock_minimo - stock_actual) AS faltante
FROM ingrediente
WHERE stock_actual < stock_minimo;

SELECT DISTINCT c.id_cliente, c.nombre, c.correo, p.fecha_hora
FROM cliente c
JOIN pedido p ON c.id_cliente = p.id_cliente
WHERE p.fecha_hora BETWEEN '2026-08-01 00:00:00' AND '2026-08-31 23:59:59';

SELECT 
    pz.nombre AS pizza,
    pz.tamano,
    SUM(dp.cantidad) AS total_unidades_vendidas
FROM detalle_pedido dp
JOIN pizza pz ON dp.id_pizza = pz.id_pizza
GROUP BY pz.id_pizza, pz.nombre, pz.tamano
ORDER BY total_unidades_vendidas DESC;

SELECT 
    r.nombre AS repartidor,
    p.id_pedido,
    p.fecha_hora,
    p.estado,
    d.distancia_km
FROM repartidor r
JOIN domicilio d ON r.id_repartidor = d.id_repartidor
JOIN pedido p ON d.id_pedido = p.id_pedido;

SELECT 
    r.zona_asignada,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, d.hora_salida, d.hora_entrega)), 2) AS tiempo_promedio_entrega_min
FROM domicilio d
JOIN repartidor r ON d.id_repartidor = r.id_repartidor
WHERE d.hora_entrega IS NOT NULL
GROUP BY r.zona_asignada;

SELECT 
    c.id_cliente,
    c.nombre,
    SUM(p.total) AS total_invertido
FROM cliente c
JOIN pedido p ON c.id_cliente = p.id_cliente
WHERE p.estado != 'cancelado'
GROUP BY c.id_cliente, c.nombre
HAVING SUM(p.total) > 100000.00;

SELECT * FROM pizza
WHERE nombre LIKE '%Especial%';

SELECT id_cliente, nombre, correo
FROM cliente
WHERE id_cliente IN (
    SELECT id_cliente
    FROM pedido
    WHERE MONTH(fecha_hora) = MONTH(CURRENT_DATE()) 
      AND YEAR(fecha_hora) = YEAR(CURRENT_DATE())
      AND estado != 'cancelado'
    GROUP BY id_cliente
    HAVING COUNT(id_pedido) > 5
);
