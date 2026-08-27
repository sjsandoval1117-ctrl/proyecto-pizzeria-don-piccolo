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

DROP USER IF EXISTS 'supervisor_cocina'@'localhost';
CREATE USER 'supervisor_cocina'@'localhost' IDENTIFIED BY 'Cocina2026*';
GRANT SELECT ON pizzeria_don_piccolo.* TO 'supervisor_cocina'@'localhost';
GRANT EXECUTE ON PROCEDURE pizzeria_don_piccolo.sp_registrar_detalle_pedido TO 'supervisor_cocina'@'localhost';
FLUSH PRIVILEGES;

