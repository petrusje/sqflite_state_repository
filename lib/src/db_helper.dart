import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_state_repository/src/tabledefs.dart';

 class DBManager {
  static Database _database;
  static final DBManager _instance = new DBManager.internal();
 // criaremos uma classe factory porque não será recriada sempre que chamarmos a classe BD (POO)
 factory DBManager() => _instance;

 // internal é um construtor então toda vez que precisamos é só instanciá-lo
 DBManager.internal();

  Future openDB() async {
    if (_database == null) {
      _database = await openDatabase(
          join(await getDatabasesPath(), 'database.db'),
          version: 1, onCreate: (Database db, int version) async {
      });
    }
  }
  Future createTable(TableDef table) async
  {
    await _database.execute(table.toSqLiteTable());
  }

  Database getDB(){return DBManager._database;}

}
