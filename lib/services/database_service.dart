import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'rafiik_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table for glucose levels
    await db.execute('''
      CREATE TABLE glucose_levels(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        value REAL,
        timestamp TEXT,
        type TEXT,
        notes TEXT
      )
    ''');
    
    // Table for medications
    await db.execute('''
      CREATE TABLE medications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        dosage TEXT,
        time TEXT,
        is_taken INTEGER
      )
    ''');
  }
}
