
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import '../models/pos_models.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    Directory documentsDirectory = await getApplicationSupportDirectory(); // Better for production than Documents
    String path = join(documentsDirectory.path, "cafeteria_pos.db");
    
    // Ensure the directory exists
    if (!await documentsDirectory.exists()) {
      await documentsDirectory.create(recursive: true);
    }

    return await openDatabase(
      path,
      version: 3, // Incremented version to add Settings
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE MenuItems (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            price REAL NOT NULL,
            category TEXT NOT NULL DEFAULT 'General'
          )
        ''');
        await db.execute('''
          CREATE TABLE Orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            total_amount REAL NOT NULL,
            timestamp TEXT NOT NULL,
            status TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE Settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
        // Default Settings
        await db.insert('Settings', {'key': 'cafeteriaName', 'value': 'كافتيريا الحي'});
        await db.insert('Settings', {'key': 'receiptTitle', 'value': 'إيصال مبيعات'});
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE MenuItems ADD COLUMN category TEXT NOT NULL DEFAULT 'General'");
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE Settings (
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL
            )
          ''');
          await db.insert('Settings', {'key': 'cafeteriaName', 'value': 'كافتيريا الحي'});
          await db.insert('Settings', {'key': 'receiptTitle', 'value': 'إيصال مبيعات'});
        }
      },
    );
  }

  Future<void> updateSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'Settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String> getSetting(String key, String defaultValue) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isNotEmpty) {
      return maps.first['value'] as String;
    }
    return defaultValue;
  }

  Future<int> insertMenuItem(MenuItem item) async {
    final db = await database;
    return await db.insert('MenuItems', item.toMap());
  }

  Future<List<MenuItem>> getMenuItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('MenuItems');
    return List.generate(maps.length, (i) => MenuItem.fromMap(maps[i]));
  }

  Future<int> deleteMenuItem(int id) async {
    final db = await database;
    return await db.delete('MenuItems', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> saveOrder(OrderModel order) async {
    final db = await database;
    return await db.insert('Orders', order.toMap());
  }
}
