import 'dart:async';
import 'package:doctro_patient/models/model.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

abstract class DB {
  static Database? _db;

  static int get _version => 1;

  static Future<void> init() async {
    if (_db != null) {
      return;
    }

    try {
      var databasesPath = await getDatabasesPath();
      String _path = p.join(databasesPath, 'crud.db');
      _db = await openDatabase(_path, version: _version, onCreate: onCreate);
    } catch (ex) {
      print(ex);
    }
  }

  static void onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE products (id INTEGER PRIMARY KEY AUTOINCREMENT, productName STRING, '
        'medicineId INTEGER, quantity INTEGER, price INTEGER ,pharmacyId INTEGER, shippingStatus INTEGER,'
        'pLat STRING,pLang STRING, prescriptionFilePath STRING, medicineStock INTEGER)');
  }

  static Future<List<Map<String, dynamic>>> query(String table) async => _db!.query(table);

  static Future<int> insert(String table, Model model) async => await _db!.insert(table, model.toMap());

  static Future<int> update(String table, Model model) async => await _db!.update(table, model.toMap(), where: 'id = ?', whereArgs: [model.id]);

  static Future<int> delete(String table, Model model) async => await _db!.delete(table, where: 'id = ?', whereArgs: [model.id]);

  static Future<int> deleteTable(String table, Model model) async => await _db!.delete(table);

  static Future<Batch> batch() async => _db!.batch();
}
