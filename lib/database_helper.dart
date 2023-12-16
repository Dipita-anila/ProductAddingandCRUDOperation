import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static void _initialize() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
      CREATE TABLE IF NOT EXISTS data(
        id INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL,
        name TEXT,
        price TEXT,
        createAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    """);
  }

  static Future<sql.Database> db() async {
    _initialize();
    return sql.openDatabase(
      join(await sql.getDatabasesPath(), "database_name.db"),
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> createData(String name, String? price) async {
    final db = await DatabaseHelper.db(); // Corrected the class name here

    final data = {'name': name, 'price': price};
    final id = await db.insert('data', data,
        conflictAlgorithm: sql.ConflictAlgorithm
            .replace); // Corrected the conflictAlgorithm parameter name

    return id;
  }

  static Future<List<Map<String, dynamic>>> getAllData() async {
    final db = await DatabaseHelper.db();
    return db.query('data', orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getSingleData(int id) async {
    final db = await DatabaseHelper.db();
    return db.query('data', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateData(int id, String? name, String? price) async {
    final db = await DatabaseHelper.db();
    final data = {
      'name': name,
      'price': price,
      'createAt': DateTime.now().toString()
    };

    final result =
        await db.update('data', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteData(int id) async {
    final db = await DatabaseHelper.db();
    try {
      await db.delete('data', where: "id = ?", whereArgs: [id]);
    } catch (e) {}
  }
}