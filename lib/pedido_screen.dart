import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'impresora_service.dart';
import 'historial_screen.dart'; // Importamos la nueva pantalla del CRUD

class PedidoScreen extends StatefulWidget {
  const PedidoScreen({super.key});

  @override
  State<PedidoScreen> createState() => _PedidoScreenState();
}

class _PedidoScreenState extends State<PedidoScreen> {
  // Controladores para capturar el texto de la interfaz
  final TextEditingController _ipController = TextEditingController(text: "192.168.1.150");
  final TextEditingController _mesaController = TextEditingController(text: "Mesa 04");
  final TextEditingController _productosController = TextEditingController(
      text: "2x Ceviche Clásico\n1x Jalea Mixta\n1x Chicha Morada Jarra"
  );
  final TextEditingController _totalController = TextEditingController(text: "85.00");

  bool _cargando = false;

  void _procesarPedidoYImpresion() async {
    setState(() { _cargando = true; });

    final nuevoPedido = {
      'mesa': _mesaController.text,
      'productos': _productosController.text,
      'total': double.tryParse(_totalController.text) ?? 0.0,
      'fecha': DateTime.now().toString().substring(0, 19),
    };

    try {
      // 1. Guardar Localmente en SQLite
      int idGuardado = await DatabaseHelper.instance.insertarPedido(nuevoPedido);

      // 2. Levantar el gestor de impresión A4 de Android
      bool impresionExitosa = await ImpresoraService().imprimirPedidoA4(nuevoPedido);

      if (impresionExitosa) {
        _mostrarAlerta("Éxito", "Pedido #$idGuardado registrado en SQLite.");
      } else {
        // CORREGIDO: Quitamos la variable 'ipImpresora' que causaba el error
        _mostrarAlerta("Aviso", "Pedido #$idGuardado guardado en SQLite local, pero se canceló o falló el envío a la impresora.");
      }
    } catch (error) {
      _mostrarAlerta("Error General", "Ocurrió un problema inesperado: $error");
    } finally {
    setState(() { _cargando = false; });
  }
  }

  void _mostrarAlerta(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK")
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("POS Restaurante Local", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        // Agregamos el botón en el AppBar para abrir el CRUD
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt, color: Colors.white, size: 28),
            tooltip: "Ver Historial CRUD",
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Configuración de Red:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextField(
                controller: _ipController,
                decoration: const InputDecoration(
                    labelText: "IP de la Impresora (Puerto 9100)",
                    hintText: "Ej. 192.168.1.150"
                ),
                keyboardType: TextInputType.number, // Teclado numérico limpio
              ),
              const SizedBox(height: 25),
              const Text("Datos del Pedido:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextField(
                controller: _mesaController,
                decoration: const InputDecoration(labelText: "Identificador de Mesa"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _productosController,
                decoration: const InputDecoration(labelText: "Productos (Líneas independientes)"),
                maxLines: 4,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _totalController,
                decoration: const InputDecoration(labelText: "Total de la cuenta (S/.)"),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _procesarPedidoYImpresion,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                  ),
                  child: _cargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                      "GUARDAR E IMPRIMIR",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}