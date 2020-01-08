 
// This file contains SQLite Table e Field Definitions 

// It defines the table and fields that que repository creates 
// and manage CRUD operations 
// /
// ```dart
// table = TableDef(tableName: 'notes', fields: [
//   FieldDef('id', DbType.integer,
//       primaryKey: true,
//       primaryKeyType: PrimaryKeyType.integer_auto_incremental),
//   FieldDef('title', DbType.text),
//   FieldDef('description', DbType.text),
//   FieldDef('priority', DbType.integer),
//   FieldDef('date', DbType.datetime)
//  ```
// Primary Key Types
enum PrimaryKeyType { integer_auto_incremental, text, integer_unique, none }
enum DbType {
  integer,
  text,
  blob,
  real,
  numeric,
  // bool is not a supported SQLite type. 
  // Repository convert this type to numeric values (false=0, true=1)
  bool,
  // Repository controls conversion 
  //using date.millisecondsSinceEpoch and fromMillisecondsSinceEpoch. 
  datetime,
  date
}

//
//Encapsulate the SQLite Field
//
class FieldDef {
  const FieldDef(this.fieldName, this.dbType,
      {this.primaryKey=false, this.primaryKeyType = PrimaryKeyType.none, 
      this.defaultValue});
  final String fieldName;
  final DbType dbType;
  final dynamic defaultValue;
  final bool primaryKey;
  final PrimaryKeyType primaryKeyType;

  String toSqLiteField() {
    String type;
    switch (dbType) {
      case DbType.bool:
      case DbType.datetime:
      case DbType.date:
        type = 'numeric';
        break;
      default:
        type = dbType.toString().replaceAll('DbType.', '');
    }
    return '$fieldName $type';
  }
}

//
//Encapsulate the SQLite Table
//
class TableDef {
    TableDef(
      {this.tableName,
      this.fields})
      {
        bool hasprimaryKey = false;
        for(FieldDef field in fields)
          if(field.primaryKey)
          {
            primaryKeyName = field.fieldName;
            primaryKeyType = field.primaryKeyType;
            hasprimaryKey = true;
          }
          if(!hasprimaryKey)
            throw new Exception('No primary key defined for $tableName !');
      }
  final String tableName;
  final List<FieldDef> fields;
  String primaryKeyName;
  PrimaryKeyType primaryKeyType;

  String toSqLiteTable() {
    final _createTableSQL = StringBuffer('');
    switch (primaryKeyType) {
      case PrimaryKeyType.integer_unique:
        _createTableSQL.write('int UNIQUE');
        break;
      case PrimaryKeyType.text:
        _createTableSQL.write('text UNIQUE');
        break;
      default:
        _createTableSQL.write('integer primary key');
    }
    for (FieldDef field in fields) {
      if(!field.primaryKey)
        _createTableSQL.write(', ${field.toSqLiteField()}');
    }

    return 'Create table if not exists $tableName ($primaryKeyName ${_createTableSQL.toString()})';
  }
}
