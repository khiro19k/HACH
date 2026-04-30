import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../core/constants/constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE glucose_records (
        id TEXT PRIMARY KEY,
        value REAL NOT NULL,
        timestamp TEXT NOT NULL,
        type TEXT NOT NULL,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE medications (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        times TEXT NOT NULL,
        isTaken INTEGER NOT NULL,
        isDoctorPrescribed INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }
  
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
