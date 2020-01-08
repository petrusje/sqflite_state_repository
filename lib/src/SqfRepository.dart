import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_state_repository/src/Model.dart';
import 'package:sqflite_state_repository/src/db_helper.dart';
import 'package:sqflite_state_repository/src/tabledefs.dart';
import 'package:state_repository/state_repository.dart';


// This class encapsulates Sqflite Table defined by RowModel, it encapsulats all the CRUD operations
//```dart
// class NoteRepository extends SqfRepository<Note> {
//   NoteRepository() : super();

// Note addNew(String title, DateTime date, int priority, [String description]) {
//   Note newNote = Note(this.table, title, date, priority, description);
//   rows.add(newNote);
//   this.current = newNote;
//   return newNote;
// }
//

//define the table structure and when the class its instantiate, it creates the table

//   @override
//   getTableDefiniton() {
//     table = TableDef(tableName: 'notes', fields: [
//       FieldDef('id', DbType.integer,
//           primaryKey: true,
//           primaryKeyType: PrimaryKeyType.integer_auto_incremental),
//       FieldDef('title', DbType.text),
//       FieldDef('description', DbType.text),
//       FieldDef('priority', DbType.integer),
//       FieldDef('date', DbType.datetime)
//     ]);
//   }

//   @override
//   Note getNewRow() {
//     return Note(table);
//   }
// }

//```

//

abstract class SqfRepository<T extends RowModel> extends Repository {
  static DBManager dbManager = DBManager();

  TableDef table;
  List<T> _rows = [];
  bool useFilter;

  List<T> get rows {
    return _rows;
  }

  set rows(List<T> dataRows) {
    _rows = dataRows;
  }

  T current;

  @mustCallSuper
  SqfRepository([this.useFilter = false]) {
    getTableDefiniton();
    createTable();
    if (!useFilter) getall();
  }

  getTableDefiniton();

  T getNewRow();

  T newRowFromMap(List<Map<String, dynamic>> maps, int i) {
    T row = getNewRow();
    row.fromMap(maps[i]);
    return row;
  }

  setCurrentByKey(dynamic key) {
    for (T row in _rows) if (row[table.primaryKeyName] == key) current = row;
  }

  setCurrent(RowModel currentRow) {
    setCurrentByKey(currentRow.key);
  }

  Future<void> getall() async {
    _rows = await getList();
    if (_rows.length > 0) current = _rows[0];
    notifyListeners();
  }

  //Crud Operations

  Future<int> insert(RowModel newRow) async {
    await dbManager.openDB();
    int result =
        await dbManager.getDB().insert(table.tableName, newRow.toMap());
    if (result == 1) notifyListeners();
    return result;
  }

  Future<int> deleteByKey(dynamic key) async {
    await dbManager.openDB();
    if (rows.length == 0) return 0;
    int result = await dbManager.getDB().delete(table.tableName,
        where: "${table.primaryKeyName}= ?", whereArgs: [key]);
    if (result == 1) notifyListeners();
    return result;
  }

  Future<int> delete(RowModel rowToDelete) async {
    return await deleteByKey(rowToDelete.key());
  }

  Future<int> update(RowModel row) async {
    //record.saveProps();
    await dbManager.openDB();
    int result = await dbManager.getDB().update(table.tableName, row.toMap(),
        where: "${table.primaryKeyName} = ?", whereArgs: [row.key]);
    if (result == 1) notifyListeners();
    return result;
  }

  Future<List<T>> query(String sql, [List<dynamic> arguments]) async {
    await dbManager.openDB();
    final List<Map<String, dynamic>> maps =
        await dbManager.getDB().rawQuery(sql, arguments);
    return List.generate(
      maps.length,
      (i) => newRowFromMap(maps, i),
    );
  }

  Future<List<T>> getList() async {
    await dbManager.openDB();
    final List<Map<String, dynamic>> maps =
        (await dbManager.getDB().query(table.tableName));
    return List.generate(
      maps.length,
      (i) => newRowFromMap(maps, i),
    );
  }

  Future<void> createTable() async {
    await dbManager.openDB();
    dbManager.createTable(table);
  }
}
