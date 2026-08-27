# Pizzería Don Piccolo - Sistema de Gestión de Base de Datos (MySQL)

Este proyecto contiene el diseño, implementación y scripts de la base de datos relacional para el sistema de gestión de la **Pizzería Don Piccolo**.

---

## Descripción del Proyecto

El sistema permite gestionar de manera integral el flujo de trabajo operacional de la pizzería:
* **Clientes y Pedidos:** Registro detallado y seguimiento de estados de órdenes en tiempo real.
* **Menú e Inventario:** Control de pizzas, recetas asociadas y deducción automática de stock de ingredientes.
* **Logística de Domicilios:** Asignación de repartidores y cálculo de tiempos de entrega.
* **Auditoría:** Historial automatizado sobre variaciones en los precios base de las pizzas.
* **Seguridad y Permisos (DCL):** Control de acceso granular asignado al rol de supervisor.

---

## Estructura de Tablas y Relaciones

| Tabla | Descripción | Relación Principal |
| :--- | :--- | :--- |
| **`cliente`** | Almacena datos personales de contacto y registro. | $1:N$ con `pedido` |
| **`pizza`** | Catálogo de pizzas, tamaños y precios base. | $1:N$ con `detalle_pedido` y `receta` |
| **`ingrediente`** | Control de inventario, stock actual, mínimo y costos unitarios. | $1:N$ con `receta` |
| **`receta`** | Relación de ingredientes requeridos por pizza. | Clave compuesta (`id_pizza`, `id_ingrediente`) |
| **`repartidor`** | Datos del personal de entrega y disponibilidad. | $1:N$ con `domicilio` |
| **`pedido`** | Registro general del pedido, estados y costos totales. | $1:N$ con `detalle_pedido`, $1:1$ con `domicilio` |
| **`detalle_pedido`** | Desglose de ítems y cantidades por orden. | $N:1$ con `pedido` y `pizza` |
| **`domicilio`** | Tiempos de salida, llegada y costo de envío. | $1:1$ con `pedido`, $N:1$ con `repartidor` |
| **`historial_precios`** | Auditoría automática de cambios de precios. | $N:1$ con `pizza` |

---

## Instrucciones para Ejecutar los Scripts

Para desplegar la base de datos en MySQL, ejecute los archivos en el siguiente orden estricto desde el cliente MySQL o Workbench:

1. **Estructura y Datos Base:**
   ```bash
   mysql -u root -p < database.sql
