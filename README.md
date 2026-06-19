# POS Restaurante Local (Híbrido Móvil/Web)

Sistema Punto de Venta (POS) local desarrollado en **Flutter** para la gestión e impresión automatizada de comandas en formato **A4**, con soporte híbrido para dispositivos móviles (Android) y navegadores web.

## 🚀 Explicación de lo que se está usando
*   **Impresión sin restricciones:** La librería `printing` y `pdf` se puede usar en impresoras con IPv4 estático y también en las que no tienen IP. El sistema autodetecta dinámicamente las impresoras mediante el spooler nativo de Android en entornos móviles, o a través del cuadro de diálogo nativo del navegador en entornos web[cite: 1, 2].

---

## 🛠️ Estructura del Proyecto (`lib/`)
*   `main.dart`: Inicialización global y punto de entrada de la aplicación[cite: 1, 2].
*   `database_helper.dart`: Gestión relacional del CRUD mediante SQLite en dispositivos móviles, adaptado con persistencia simulada en memoria limpia para la arquitectura web[cite: 1, 2].
*   `impresora_service.dart`: Algoritmo de división inteligente de comandas y maquetación PDF vectorial en formato A4[cite: 1, 2].
*   `pedido_screen.dart`: Panel táctil interactivo para seleccionar productos del catálogo, ajustar cantidades dinámicamente y despachar órdenes[cite: 1, 2].
*   `historial_screen.dart`: Vista de auditoría interna para Leer, Actualizar y Eliminar pedidos del historial local[cite: 1, 2].

---

## ⚡ Lógica de División de Comandas
El sistema ya no depende de campos de texto libre[cite: 1, 2]. Al presionar **"Despachar Orden"**, el motor de impresión ejecuta un filtro automático basado en las categorías del menú[cite: 1, 2]:
1.  **Agrupación:** Separa los artículos del pedido según su destino (ej. *Cocina* o *Bar*)[cite: 1, 2].
2.  **Fraccionamiento:** Genera y despacha de manera consecutiva comprobantes A4 independientes a cada área de preparación, optimizando los tiempos del restaurante[cite: 1, 2].

---

## ⚙️ Comandos de Ejecución

### 📱 Dispositivos Móviles (Android)
Asegúrate de tener el permiso de `INTERNET` declarado en tu `AndroidManifest.xml`[cite: 1, 2]:
```bash
flutter build apk