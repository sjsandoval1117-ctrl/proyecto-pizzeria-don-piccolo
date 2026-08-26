USE pizzeria_don_piccolo;

DELIMITER $$

DROP TRIGGER IF EXISTS trg_descontar_stock_ingredientes$$
CREATE TRIGGER trg_descontar_stock_ingredientes
BEFORE INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
    DECLARE v_ingrediente_insuficiente VARCHAR(80);

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

DELIMITER ;
