import 'package:apper/model/activityreport.dart';
import 'package:apper/model/farmer_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class FarmerDatabaseHelper {
  static final FarmerDatabaseHelper instance = FarmerDatabaseHelper._init();

  static Database? _database;

  FarmerDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('farmers.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'farmers.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    // Create farmers table
    await db.execute('''
    CREATE TABLE farmers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      full_name TEXT,
      date_of_birth TEXT,
      gender TEXT,
      contact_number TEXT,
      email TEXT,
      address TEXT,
      photo TEXT
    )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Create activity reporting table
      await db.execute('''
      CREATE TABLE IF NOT EXISTS activity_reporting (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        completion_date TEXT,
        reporting_date TEXT,
        farm_reference TEXT,
        activity_done TEXT,
        sub_activity_done TEXT,
        farmer_name TEXT,
        farm_size REAL,
        farm_location TEXT
      )
      ''');
    }
  }

  Future<int?> insertFarmer(Farmer farmer) async {
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

  Future<void> printTableSchema() async {
    final db = await database;
    var tableInfo = await db.rawQuery('PRAGMA table_info(farmers)');
    print('Table Schema: $tableInfo');
  }

  Future<int?> insertActivityReport(ActivityReport activityReport) async {
    final db = await instance.database;
    return await db.insert('activity_reporting', activityReport.toMap());
  }

  Future<List<ActivityReport>> fetchAllActivityReports() async {
    final db = await instance.database;
    final result = await db.query('activity_reporting');
    return result.map((e) => ActivityReport.fromMap(e)).toList();
  }
}
