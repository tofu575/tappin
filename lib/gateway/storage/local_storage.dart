import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:tappin/domain/models/pin/pin.dart';

const _dbName = 'tappin.db';

abstract class LocalStorage {
  Future<List<Pin>> fetchPins();
  Future<int> savePin(Pin pin);
  Future<void> deletePin(int id);
}

class SQLiteStorage implements LocalStorage {
  final Database _db;

  SQLiteStorage._(this._db);

  static const _tableName = 'pins';

  static Future<SQLiteStorage> open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) => _createTable(db),
    );
    return SQLiteStorage._(db);
  }

  static Future<void> _createTable(Database db) async {
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
  Future<List<Pin>> fetchPins() async {
    final maps = await _db.query(_tableName, orderBy: 'created_at DESC');
    return maps.map(Pin.fromMap).toList();
  }

  @override
  Future<int> savePin(Pin pin) async {
    return _db.insert(_tableName, pin.toMap());
  }

  @override
  Future<void> deletePin(int id) async {
    await _db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}
