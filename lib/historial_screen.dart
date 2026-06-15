import 'package:flutter/material.dart';
import 'database_helper.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  List<Map<String, dynamic>> _pedidos = [];

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  void _cargarPedidos() async {
    final datos = await DatabaseHelper.instance.obtenerPedidos();
    setState(() {
      _pedidos = datos;
    });
  }

  void _eliminar(int id) async {
    await DatabaseHelper.instance.eliminarPedido(id);
    _cargarPedidos();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pedido eliminado de la base de datos')),
    );
  }

  void _mostrarDialogoEditar(Map<String, dynamic> pedido) {
    final mesaCtrl = TextEditingController(text: pedido['mesa']);
    final prodCtrl = TextEditingController(text: pedido['productos']);
    final totalCtrl = TextEditingController(text: pedido['total'].toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Editar Pedido #${pedido['id']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: mesaCtrl, decoration: const InputDecoration(labelText: 'Mesa')),
              TextField(controller: prodCtrl, decoration: const InputDecoration(labelText: 'Productos'), maxLines: 3),
              TextField(controller: totalCtrl, decoration: const InputDecoration(labelText: 'Total'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await DatabaseHelper.instance.actualizarPedido(pedido['id'], {
                'mesa': mesaCtrl.text,
                'productos': prodCtrl.text,
                'total': double.tryParse(totalCtrl.text) ?? 0.0,
                'fecha': pedido['fecha'] // Mantenemos la fecha original
              });
              Navigator.pop(ctx);
              _cargarPedidos();
            },
            child: const Text('Guardar Cambios'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historial SQLite (CRUD)")),
      body: _pedidos.isEmpty
          ? const Center(child: Text("No hay pedidos locales guardados todavía."))
          : ListView.builder(
        itemCount: _pedidos.length,
        itemBuilder: (context, index) {
          final item = _pedidos[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(child: Text("#${item['id']}")),
              title: Text("${item['mesa']} - S/. ${item['total'].toStringAsFixed(2)}"),
              subtitle: Text("${item['productos']}\n${item['fecha']}"),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _mostrarDialogoEditar(item),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _eliminar(item['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}