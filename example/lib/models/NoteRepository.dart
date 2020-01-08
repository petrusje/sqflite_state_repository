import 'package:sqflite_state_repository/sqflite_state_repository.dart';
import 'note.dart';

class NoteRepository extends SqfRepository<Note> {
  NoteRepository() : super();

  Note addNew(String title, DateTime date, int priority, [String description]) {
    Note newNote = Note(this.table, title, date, priority, description);
    rows.add(newNote);
    this.current = newNote;
    return newNote;
  }

  @override
  getTableDefiniton() {
    table = TableDef(tableName: 'notes', fields: [
      FieldDef('id', DbType.integer,
          primaryKey: true,
          primaryKeyType: PrimaryKeyType.integer_auto_incremental),
      FieldDef('title', DbType.text),
      FieldDef('description', DbType.text),
      FieldDef('priority', DbType.integer),
      FieldDef('date', DbType.datetime)
    ]);
  }

  @override
  Note getNewRow() {
    return Note(table);
  }
}
