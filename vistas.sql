USE pizzeria_don_piccolo;

DELIMITER $$

DROP FUNCTION IF EXISTS fn_calcular_total_pedido$$
CREATE FUNCTION fn_calcular_total_pedido(p_id_pedido INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_subtotal DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_costo_envio DECIMAL(10,2) DEFAULT 0.00;
    
    SELECT IFNULL(SUM(cantidad * precio_unitario), 0.00) INTO v_subtotal 
    FROM detalle_pedido WHERE id_pedido = p_id_pedido;

    SELECT IFNULL(costo_envio, 0.00) INTO v_costo_envio 
    FROM domicilio WHERE id_pedido = p_id_pedido;

    RETURN (v_subtotal + v_costo_envio) * 1.19;
END$$

DROP FUNCTION IF EXISTS fn_ganancia_neta_diaria$$
CREATE FUNCTION fn_ganancia_neta_diaria(p_fecha DATE) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total_ventas DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_total_costos DECIMAL(10,2) DEFAULT 0.00;

    SELECT IFNULL(SUM(total), 0.00) INTO v_total_ventas 
    FROM pedido WHERE DATE(fecha_hora) = p_fecha AND estado != 'cancelado';

    SELECT IFNULL(SUM(dp.cantidad * r.cantidad_requerida * ing.costo_unitario), 0.00) INTO v_total_costos
    FROM pedido p
    JOIN detalle_pedido dp ON p.id_pedido = dp.id_pedido
    JOIN receta r ON dp.id_pizza = r.id_pizza
    JOIN ingrediente ing ON r.id_ingrediente = ing.id_ingrediente
    WHERE DATE(p.fecha_hora) = p_fecha AND p.estado != 'cancelado';

    RETURN v_total_ventas - v_total_costos;
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

DROP PROCEDURE IF EXISTS sp_registrar_entrega_domicilio$$
CREATE PROCEDURE sp_registrar_entrega_domicilio(
    IN p_id_domicilio INT,
    IN p_hora_entrega DATETIME
)
BEGIN
    DECLARE v_id_pedido INT;
    SELECT id_pedido INTO v_id_pedido FROM domicilio WHERE id_domicilio = p_id_domicilio;
    IF v_id_pedido IS NOT NULL THEN
        UPDATE domicilio SET hora_entrega = p_hora_entrega WHERE id_domicilio = p_id_domicilio;
        UPDATE pedido SET estado = 'entregado' WHERE id_pedido = v_id_pedido;
    END IF;
END$$

DELIMITER ;

GRANT EXECUTE ON PROCEDURE pizzeria_don_piccolo.sp_registrar_detalle_pedido TO 'supervisor_cocina'@'localhost';
FLUSH PRIVILEGES;