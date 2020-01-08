import 'package:flutter/material.dart';
import 'package:state_repository/state_repository.dart';
import '../models/NoteRepository.dart';
import '../models/note.dart';
import '../screens/note_detail.dart';
import 'package:intl/intl.dart';


class NoteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

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
}
