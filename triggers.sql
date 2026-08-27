USE pizzeria_don_piccolo;

DELIMITER $$

DROP TRIGGER IF EXISTS trg_descontar_stock_ingredientes$$
CREATE TRIGGER trg_descontar_stock_ingredientes
BEFORE INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
    DECLARE v_ingrediente_insuficiente VARCHAR(80) DEFAULT NULL;

    SELECT ing.nombre INTO v_ingrediente_insuficiente
    FROM receta r
    JOIN ingrediente ing ON r.id_ingrediente = ing.id_ingrediente
    WHERE r.id_pizza = NEW.id_pizza
      AND ing.stock_actual < (r.cantidad_requerida * NEW.cantidad)
    LIMIT 1;

    IF v_ingrediente_insuficiente IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Stock insuficiente para el ingrediente requerido.';
    ELSE
        UPDATE ingrediente ing
        JOIN receta r ON ing.id_ingrediente = r.id_ingrediente
        SET ing.stock_actual = ing.stock_actual - (r.cantidad_requerida * NEW.cantidad)
        WHERE r.id_pizza = NEW.id_pizza;
    END IF;
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