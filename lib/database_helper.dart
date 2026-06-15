import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('restaurante_local.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pedidos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mesa TEXT NOT NULL,
        productos TEXT NOT NULL,
        total REAL NOT NULL,
        fecha TEXT NOT NULL
      )
    ''');
  }

  // === OPERACIONES CRUD ===

  // C - Create (Crear)
  Future<int> insertarPedido(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('pedidos', row);
  }

  // R - Read (Leer todos)
  Future<List<Map<String, dynamic>>> obtenerPedidos() async {
    final db = await instance.database;
    return await db.query('pedidos', orderBy: 'id DESC');
  }

  // U - Update (Actualizar)
  Future<int> actualizarPedido(int id, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update(
        'pedidos',
        row,
        where: 'id = ?',
        whereArgs: [id]
    );
  }

  // D - Delete (Eliminar)
  Future<int> eliminarPedido(int id) async {
    final db = await instance.database;
    return await db.delete(
        'pedidos',
        where: 'id = ?',
        whereArgs: [id]
    );
  }
}