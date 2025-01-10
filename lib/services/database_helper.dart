import 'package:apper/model/farmer_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('farmers.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'farmers.db');

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
  CREATE TABLE farmers (
      id INTEGER PRIMARY KEY,
      full_name TEXT,
      date_of_birth TEXT,
      gender TEXT,
      contact_number TEXT,
      email TEXT,
      address TEXT,
      photo TEXT,

      )
      ''');
  }

  Future<int> insertFarmer(Farmer farmer) async {
    final db = await instance.database;
    return await db.insert('farmers', farmer.toMap());
  }

  Future<List<Farmer>> fetchAllFarmers() async {
    final db = await instance.database;
    final result = await db.query('farmers');
    return result.map((e) => Farmer.fromMap(e)).toList();
  }

  Future<void> clearFarmers() async {
    final db = await instance.database;
    await db.delete('farmers');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
