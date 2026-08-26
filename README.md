# Pizzería Don Piccolo - Sistema de Gestión de Base de Datos (MySQL)

Este proyecto contiene el diseño, implementación y scripts de la base de datos relacional para el sistema de gestión de la **Pizzería Don Piccolo**.

---

## Descripción del Proyecto
El sistema permite gestionar de manera integral el flujo de trabajo de la pizzería:
* Control de clientes y pedidos.
* Menú de pizzas y control de stock de ingredientes (recetas).
* Asignación y tiempos de entrega en domicilios con repartidores.
* Control de precios e historial de auditoría.
* Seguridad y permisos mediante roles (DCL).

---

## Estructura de Tablas y Relaciones

1. **`cliente`**: Almacena los datos personales de los clientes. *(1:N con pedido)*
2. **`pizza`**: Catálogo de pizzas, tamaños y precios base. *(1:N con detalle_pedido y receta)*
3. **`ingrediente`**: Control de inventario y stock mínimo. *(1:N con receta)*
4. **`receta`**: Tabla intermedia que define qué ingredientes y cantidades requiere cada pizza (Llave compuesta).
5. **`repartidor`**: Datos del personal de entrega y su disponibilidad. *(1:N con domicilio)*
6. **`pedido`**: Información general del pedido, estado y total. *(1:N con detalle_pedido, 1:1 con domicilio)*
7. **`detalle_pedido`**: Desglose de pizzas solicitadas en cada pedido.
8. **`domicilio`**: Seguimiento de la logística de entrega y tiempos.
9. **`historial_precios`**: Registro de auditoría para cambios en el precio base de las pizzas.

---

## Instrucciones para Ejecutar los Scripts

Para desplegar la base de datos en MySQL, ejecute los archivos en el siguiente orden estricto desde el cliente MySQL o Workbench:

1. **Creación de la base de datos y estructura:**
   ```bash
   mysql -u root -p < database.sql