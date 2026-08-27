USE pizzeria_don_piccolo;

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