# POS para Restaurante (Móvil y Web)

Este es un sistema de Punto de Venta (POS) local que armé en **Flutter** para tomar pedidos en restaurantes. Lo genial es que funciona tanto en tablets/celulares Android como en la web, y está pensado para ser *Local-First* (es decir, no depende para nada de internet; si el Wi-Fi parpadea, el negocio sigue facturando sin perder datos).

## Cómo funciona la impresión (El punto clave)
Para que no nos amarremos a una marca específica de tiqueteras térmicas de comandos (`ESC/POS`), decidí maquetar todo de forma vectorial usando **hojas A4 (PDF)**. 

Lo mejor de este enfoque es que **funciona tanto con impresoras que tienen una IP fija como con las que no**. En Android, la app despierta el servicio nativo del sistema y detecta cualquier impresora en la red local. En la Web, simplemente se abre la ventana clásica de impresión de Chrome o Edge, permitiéndote mandarlo a cualquier máquina que ya tengas instalada en la computadora.

---

## ¿Cómo está organizado el código? (`lib/`)
Separé el proyecto de forma súper limpia en 5 archivos dentro de la carpeta `lib`:

* `main.dart`: El arranque oficial de la aplicación.
* `database_helper.dart`: El cerebro de los datos. Si entras desde el celular, levanta una base de datos SQLite real; si entras desde la web (donde no hay almacenamiento nativo directo), usa una lógica híbrida en memoria para que puedas hacer pruebas al instante.
* `impresora_service.dart`: Aquí está la magia. Recibe el pedido, diseña el PDF en A4 y se encarga de separar los tickets.
* `pedido_screen.dart`: La pantalla táctil donde el mesero selecciona los platos del menú, sube o baja cantidades con botones (`+` / `-`) y manda la orden.
* `historial_screen.dart`: El panel CRUD. Sirve para ver el historial de pedidos guardados, editar una comanda si el cliente cambió de opinión, o borrar un registro.

---

## División Inteligente de Comandas (Por Categoría)
Ya no usamos cuadros de texto libre donde el mesero escribe todo junto. Ahora, al presionar **"Despachar Orden"**, el sistema hace esto de forma automática:

1.  **Filtra y agrupa:** Revisa qué productos se seleccionaron. Si alguien pidió un "Pollo a la Brasa" (Cocina) y un "Vino Copa" (Bar), el código los separa por su categoría.
2.  **Lanza tickets independientes:** Genera un voucher PDF A4 exclusivo para la cocina (solo con la comida) y otro exclusivo para el bar (solo con las bebidas), mandando cada cosa a su respectiva área de preparación en segundos.

---

## Comandos para Correr el Proyecto

### Para compilar el APK de Android
Asegúrate de haber puesto el permiso de `INTERNET` dentro de tu `AndroidManifest.xml` (fuera de la etiqueta `application`) y corre en tu terminal:
```bash
flutter build apk