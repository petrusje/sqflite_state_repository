# sqflite_state_repository

This package encapsulates Sqflite Table defined by RowModel, it encapsulats all the CRUD operations

## Getting Started

First we define the table Structure using Tabledef and Fieldefs

// It defines the table and fields that que repository creates
// and manage CRUD operations
// /
//

```dart
 table = TableDef(tableName: 'notes', 
 fields: [  
   FieldDef('id', DbType.integer,  primaryKey: true,  primaryKeyType: PrimaryKeyType.integer_auto_incremental),  
   FieldDef('title', DbType.text),  
   FieldDef('description', DbType.text),  
   FieldDef('priority', DbType.integer),  
   FieldDef('date', DbType.datetime)
```

After we define the RowModel

Must create the props and implement

```dart
class Note extends RowModel {
  int get id => this['id'];
  String get title => this['title'];
  String get description => this['description'];
  int get priority => this['priority'];
  DateTime get date => this['date'];

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

  Note(TableDef tableDef, [title, date, priority, description])
      : super(tableDef) {
    if (!loaded()) this.newRecord();
    this['title'] = title;
    this['description'] = description;
    this['priority'] = priority;
    this['date'] = date;
  }
}
```

At last we inherit from SqfRepository<Note>

```dart
 class NoteRepository extends SqfRepository<Note> {
   NoteRepository() : super();

 Note addNew(String title, DateTime date, int priority, [String description]) {
   Note newNote = Note(this.table, title, date, priority, description);
   rows.add(newNote);
   this.current = newNote;
   return newNote;
 }
```

Define the table structure and when the class its instantiate, it creates the table

```dart
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
```

Then we can use in widgets and sign for change notifications
Code for list

```dart

class NoteListState extends NotifiableState<NoteList> {
  NoteRepository noteRepo;
  @override
  void initState() {
    noteRepo = NoteRepository();
    noteRepo.addListener(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('FAB clicked');
          noteRepo.addNew('',DateTime.now(),2);
          navigateToDetail('Add Note');
        },
        tooltip: 'Add Note',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;

    return ListView.builder(
      itemCount: noteRepo.rows.length,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                     getPriorityColor(noteRepo.rows[position]['priority']),
              child: getPriorityIcon(noteRepo.rows[position]['priority']),
            ),
            title: Text(
              //noteRepo.rows[position]['title'] work's this way either
              noteRepo.rows[position].title,
              style: titleStyle,
            ),
            subtitle: Text(DateFormat.yMMMMd().format(noteRepo.rows[position].date)),
            trailing: GestureDetector(
              child: Icon(
                Icons.delete,
                color: Colors.grey,
              ),
              onTap: () {
                _delete(context, noteRepo.rows[position]);
              },
            ),
            onTap: () {
              debugPrint("ListTile Tapped");
              noteRepo.setCurrent(noteRepo.rows[position]);
              navigateToDetail('Edit Note');
            },
          ),
        );
      },
    );
  }

  // Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;

      default:
        return Colors.yellow;
    }
  }

  // Returns the priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;

      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await noteRepo.delete(note);
    if (result == 1) {
      _showSnackBar(context, 'Note Deleted Successfully');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(String title) async {
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(title);
    }));
  }

```

Code for detail

```dart
class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  Note note;

  NoteDetail(this.appBarTitle);

  @override
  NotifiableState<StatefulWidget> createState() {
    return NoteDetailState(this.appBarTitle);
  }
}

class NoteDetailState extends NotifiableState<NoteDetail> {
  static var _priorities = ['High', 'Low'];

  String appBarTitle;
  Note note;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.appBarTitle);

  @override
  void initState() {
    note = Repository.of<NoteRepository>().current;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(
        onWillPop: () {
          // Write some code to control things, when user press Back navigation button in device navigationBar
          moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  // Write some code to control things, when user press back button in AppBar
                  moveToLastScreen();
                }),
          ),
          body: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                // First element
                ListTile(
                  title: DropdownButton(
                      items: _priorities.map((String dropDownStringItem) {
                        return DropdownMenuItem<String>(
                          value: dropDownStringItem,
                          child: Text(dropDownStringItem),
                        );
                      }).toList(),
                      style: textStyle,
                      value: getPriorityAsString(note.priority),
                      onChanged: (valueSelectedByUser) {
                        setState(() {
                          debugPrint('User selected $valueSelectedByUser');
                          updatePriorityAsInt(valueSelectedByUser);
                        });
                      }),
                ),

                // Second Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: titleController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint('Something changed in Title Text Field');
                      updateTitle();
                    },
                    decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                // Third Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: descriptionController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint('Something changed in Description Text Field');
                      updateDescription();
                    },
                    decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                // Fourth Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Save',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            debugPrint("Save button clicked");
                            _save();
                          },
                        ),
                      ),
                      Container(
                        width: 5.0,
                      ),
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Delete',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            debugPrint("Delete button clicked");
                            _delete();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // Convert the String priority in the form of integer before saving it to Database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  // Convert int priority to String priority and display it to user in DropDown
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; // 'High'
        break;
      case 2:
        priority = _priorities[1]; // 'Low'
        break;
    }
    return priority;
  }

  // Update the title of Note object
  void updateTitle() {
    note.title = titleController.text;
  }

  // Update the description of Note object
  void updateDescription() {
    note.description = descriptionController.text;
  }

  // Save data to database
  void _save() async {
    moveToLastScreen();

    note.date = DateTime.now();
    int result;
    if (note.id != null) {
      // Case 1: Update operation
      result = await Repository.of<NoteRepository>().update(note);
    } else {
      // Case 2: Insert Operation
      result = await Repository.of<NoteRepository>().insert(note);
    }

    if (result != 0) {
      // Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _delete() async {
    moveToLastScreen();

    // Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
    // the detail page by pressing the FAB of NoteList page.
    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await Repository.of<NoteRepository>().delete(note);
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured while Deleting Note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
```
