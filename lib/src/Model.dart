
// Must create the props and implement 
// ```dart
// class Note extends RowModel{
//   int get id => this['id'] ;
// 	String get title => this['title'];
//   String get description => this['description'];
//   int get priority => this['priority'];
//   DateTime get date =>this['date'];

// 	set title(String newTitle) {
// 		if (newTitle.length <= 255) {
// 			this['title'] = newTitle;
// 		}
// 	}
//   set description(String newDescription) {
// 		if (newDescription.length <= 255) {
// 			this['description'] = newDescription;
// 		}
// 	}
// 	set priority(int newPriority) {
// 		if (newPriority >= 1 && newPriority <= 2) {
// 			this['priority'] = newPriority;
// 		}
// 	}
// 	set date(DateTime newDate) {
// 		this['date'] = newDate;
// 	}

// 	Note(TableDef tableDef, [title, date, priority, description]) : super(tableDef)
//   {
//      if(!loaded())
//       this.newRecord();
// 		this['title'] = title;
// 		this['description'] = description;
// 		this['priority'] = priority;
// 		this['date'] = date;   
//   }
// }
//  ```

import 'package:sqflite_state_repository/src/tabledefs.dart';

class RowModel {

  RowModel(this.tableDef, {Map<String, dynamic> row}) {
    if(row != null)
      _row = Map<String, dynamic>.from(row);
  }
  final TableDef tableDef;
  Map<String, dynamic> _row;

  bool isNew = false;
  bool isModified = false;

  bool loaded()
  {
    return _row != null;
  }

  void newRecord() {
    isNew = true;
    _row = Map<String, dynamic>();
    for (FieldDef field in tableDef.fields)
      if (field.primaryKey)
        _row[field.fieldName] = null;
      else
        _row[field.fieldName] = field.defaultValue;
  }

  dynamic key() {
    return _row[tableDef.primaryKeyName];
  }

  Map<String, dynamic> toMap() {
    return _row;
  }

  void fromMap(Map<String, dynamic> map) {
    _row = Map<String, dynamic>.from(map);
  }

  //todo: type checking
  void operator []=(String field, dynamic value) {
    isModified = true;
    FieldDef sqfField = getField(field);
    switch (sqfField.dbType) {
      case DbType.date:
      case DbType.datetime:
        {
          // dates in numeric
          DateTime date = value;
          _row[field] = date?.millisecondsSinceEpoch;
          break;
        }
      case DbType.bool:
        {
          // bool in numeric
          _row[field] = value == 1 ? true : false;
          break;
        }
      default:
        _row[field] = value;
    }
  }

  //todo: type checking
  dynamic operator [](String field) {
    FieldDef sqfField = getField(field);
    switch (sqfField.dbType) {
      case DbType.date:
      case DbType.datetime:
        {
          // dates in numeric
          int date = _row[field];
          return DateTime.fromMillisecondsSinceEpoch(date);
        }
      case DbType.bool:
        {
          // dates in numeric
          return _row[field] == 0 ? false : true;
        }
      default:
        return _row[field];
    }
  }

  FieldDef getField(String searchedField) {
    for (FieldDef field in tableDef.fields)
      if (field.fieldName
              .toLowerCase()
              .compareTo(searchedField.toLowerCase()) ==
          0) return field;
    throw new Exception(
        "Can't find Field: $searchedField on table: ${tableDef.tableName}");
  }
}

