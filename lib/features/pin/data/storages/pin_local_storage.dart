import 'package:sqflite/sqflite.dart';
import 'package:tappin/features/pin/data/models/pin_model.dart';

abstract class PinLocalStorage {
  Future<List<PinModel>> fetchPins();
  Future<int> savePin(PinModel pin);
  Future<void> deletePin(int id);
}

class PinSQLiteStorage implements PinLocalStorage {
  final Database db;

  PinSQLiteStorage(this.db);

  static const _tableName = 'pins';

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  @override
  Future<List<PinModel>> fetchPins() async {
    final maps = await db.query(_tableName, orderBy: 'created_at DESC');
    return maps.map((m) => PinModel.fromMap(m)).toList();
  }

  @override
  Future<int> savePin(PinModel pin) async {
    return db.insert(_tableName, pin.toMap());
  }

  @override
  Future<void> deletePin(int id) async {
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}
