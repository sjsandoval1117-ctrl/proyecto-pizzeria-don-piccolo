USE pizzeria_don_piccolo;

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