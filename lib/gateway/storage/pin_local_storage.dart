import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:tappin/domain/models/pin/pin.dart';


abstract class PinLocalStorage {
  Future<List<Pin>> fetchPins();
  Future<int> savePin(Pin pin);
  Future<void> deletePin(int id);
}

class PinSQLiteStorage implements PinLocalStorage {
  final Database _db;

  PinSQLiteStorage._(this._db);

  static const _dbName = 'tappin.db';
  static const _tableName = 'pins';

  static Future<PinSQLiteStorage> open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) => _createTable(db),
    );
    return PinSQLiteStorage._(db);
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
