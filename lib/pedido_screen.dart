import 'dart:convert';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'impresora_service.dart';
import 'historial_screen.dart';

class PedidoScreen extends StatefulWidget {
  const PedidoScreen({super.key});

  @override
  State<PedidoScreen> createState() => _PedidoScreenState();
}

class _PedidoScreenState extends State<PedidoScreen> {
  final TextEditingController _mesaController = TextEditingController(text: "Mesa 05");
  final Map<int, int> _cantidadesSeleccionadas = {};
  List<Map<String, dynamic>> _menuProductos = [];
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _cargarCatalogoMenu();
  }

  void _cargarCatalogoMenu() async {
    final productos = await DatabaseHelper.instance.obtenerProductosMenu();
    if (!mounted) return;
    setState(() {
      _menuProductos = productos;
    });
  }

  double _calcularTotal() {
    double total = 0.0;
    for (var producto in _menuProductos) {
      int id = producto['id'];
      int cantidad = _cantidadesSeleccionadas[id] ?? 0;
      if (cantidad > 0) {
        total += (producto['precio'] * cantidad);
      }
    }
    return total;
  }

  void _enviarPedidoSistema() async {
    List<Map<String, dynamic>> itemsParaDespachar = [];

    for (var producto in _menuProductos) {
      int id = producto['id'];
      int cantidad = _cantidadesSeleccionadas[id] ?? 0;
      if (cantidad > 0) {
        var itemFormateado = Map<String, dynamic>.from(producto);
        itemFormateado['cantidad'] = cantidad;
        itemsParaDespachar.add(itemFormateado);
      }
    }

    if (itemsParaDespachar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor selecciona al menos un producto.")),
      );
      return;
    }

    setState(() { _cargando = true; });

    try {
      final nuevoPedido = {
        'mesa': _mesaController.text,
        'items': jsonEncode(itemsParaDespachar),
        'total': _calcularTotal(),
        'fecha': DateTime.now().toString().substring(0, 19),
      };

      await DatabaseHelper.instance.insertarPedido(nuevoPedido);
      await ImpresoraService().despacharComandasPorCategoria(_mesaController.text, itemsParaDespachar);

      if (!mounted) return;
      setState(() { _cantidadesSeleccionadas.clear(); });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Pedido procesado y enviado a sus respectivas áreas!")),
      );
    } catch (e) {
      debugPrint("Error general: $e");
    } finally {
      if (mounted) setState(() { _cargando = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Toma de Pedidos", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistorialScreen()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _mesaController,
              decoration: const InputDecoration(labelText: "Número de Mesa", icon: Icon(Icons.table_restaurant)),
            ),
            const SizedBox(height: 15),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Menú del Establecimiento:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _menuProductos.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: _menuProductos.length,
                itemBuilder: (context, index) {
                  final producto = _menuProductos[index];
                  int id = producto['id'];
                  int cantidadActual = _cantidadesSeleccionadas[id] ?? 0;

                  return Card(
                    child: ListTile(
                      title: Text(producto['nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${producto['categoria_nombre']} - S/. ${producto['precio'].toStringAsFixed(2)}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: cantidadActual > 0 ? () {
                              setState(() { _cantidadesSeleccionadas[id] = cantidadActual - 1; });
                            } : null,
                          ),
                          Text('$cantidadActual', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                            onPressed: () {
                              setState(() { _cantidadesSeleccionadas[id] = cantidadActual + 1; });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
              child: Row(
                // CORREGIDO: spaceBetween con B mayúscula
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total Actual: S/. ${_calcularTotal().toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ElevatedButton(
                    onPressed: _cargando ? null : _enviarPedidoSistema,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: _cargando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("DESPACHAR ORDEN", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}