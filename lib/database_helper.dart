import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // Lista en memoria para cuando corra en Web
  final List<Map<String, dynamic>> _pedidosWebMemory = [];

  DatabaseHelper._init();

  Future<Database?> get database async {
    if (kIsWeb) return null; // En la web no inicializamos SQLite clásico
    if (_database != null) return _database!;
    _database = await _initDB('pos_restaurante_v3.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('CREATE TABLE categorias (id INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT, destino_impresora TEXT)');
    await db.execute('CREATE TABLE productos (id INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT, precio REAL, categoria_id INTEGER)');
    await db.execute('CREATE TABLE pedidos (id INTEGER PRIMARY KEY AUTOINCREMENT, mesa TEXT, items TEXT, total REAL, fecha TEXT)');
  }

  // === OBTENER MENÚ (Híbrido para Web y Celular) ===
  Future<List<Map<String, dynamic>>> obtenerProductosMenu() async {
    if (kIsWeb) {
      // Datos estáticos de prueba inmediatos para la Web
      return [
        {'id': 1, 'nombre': 'Pollo a la Brasa', 'precio': 25.0, 'categoria_nombre': 'Cocina (Platos)', 'destino_impresora': '192.168.1.150'},
        {'id': 2, 'nombre': 'Lomo Saltado', 'precio': 35.0, 'categoria_nombre': 'Cocina (Platos)', 'destino_impresora': '192.168.1.150'},
        {'id': 3, 'nombre': 'Vino Tinto Copa', 'precio': 15.0, 'categoria_nombre': 'Bar (Bebidas)', 'destino_impresora': '192.168.1.160'},
        {'id': 4, 'nombre': 'Chicha Morada Jarra', 'precio': 12.0, 'categoria_nombre': 'Bar (Bebidas)', 'destino_impresora': '192.168.1.160'},
      ];
    }

    final db = await database;
    return await db!.rawQuery('''
      SELECT p.*, c.nombre AS categoria_nombre, c.destino_impresora 
      FROM productos p
      INNER JOIN categorias c ON p.categoria_id = c.id
    ''');
  }

  // === OPERACIONES CRUD ADAPTADAS ===
  Future<int> insertarPedido(Map<String, dynamic> row) async {
    if (kIsWeb) {
      final mapaEditable = Map<String, dynamic>.from(row);
      mapaEditable['id'] = _pedidosWebMemory.length + 1;
      _pedidosWebMemory.add(mapaEditable);
      return mapaEditable['id'];
    }
    final db = await database;
    return await db!.insert('pedidos', row);
  }

  Future<List<Map<String, dynamic>>> obtenerPedidos() async {
    if (kIsWeb) return List.from(_pedidosWebMemory.reversed);
    final db = await database;
    return await db!.query('pedidos', orderBy: 'id DESC');
  }

  Future<int> actualizarPedido(int id, Map<String, dynamic> row) async {
    if (kIsWeb) {
      int index = _pedidosWebMemory.indexWhere((p) => p['id'] == id);
    if (index != -1) {
        _pedidosWebMemory[index] = {...row, 'id': id};
        return 1;
      }
      return 0;
    }
    final db = await database;
    return await db!.update('pedidos', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> eliminarPedido(int id) async {
    if (kIsWeb) {
      _pedidosWebMemory.removeWhere((p) => p['id'] == id);
      return 1;
    }
    final db = await database;
    return await db!.delete('pedidos', where: 'id = ?', whereArgs: [id]);
  }
}