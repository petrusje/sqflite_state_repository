
import 'package:sqflite_state_repository/sqflite_state_repository.dart'; 

// Could inherit DataRow for encapsulate fields in properties
class Note extends RowModel{

  int get id => this['id'] ;
	String get title => this['title'];
  String get description => this['description'];
  int get priority => this['priority'];
  DateTime get date =>this['date'];

	set title(String newTitle) {
		if (newTitle.length <= 255) {
			this['title'] = newTitle;
		}
	}
  set description(String newDescription) {
		if (newDescription.length <= 255) {
			this['description'] = newDescription;
		}
	}
	set priority(int newPriority) {
		if (newPriority >= 1 && newPriority <= 2) {
			this['priority'] = newPriority;
		}
	}
	set date(DateTime newDate) {
		this['date'] = newDate;
	}

	Note(TableDef tableDef, [title, date, priority, description]) : super(tableDef)
  {
     if(!loaded())
      this.newRecord();
		this['title'] = title;
		this['description'] = description;
		this['priority'] = priority;
		this['date'] = date;   
  }

	Note.withId(TableDef tableDef, id, title, date, priority, [description]) : super(tableDef)
  {
    if(!loaded())
      this.newRecord();
    this['id'] = id;
		this['title'] = title;
		this['description'] = description;
		this['priority'] = priority;
		this['date'] = date;  
  }
}