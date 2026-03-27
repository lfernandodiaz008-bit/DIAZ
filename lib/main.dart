import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() => runApp(NotesApp());

class NotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      home: NotesHomePage(),
    );
  }
}

class NotesHomePage extends StatefulWidget {
  @override
  _NotesHomePageState createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  List<String> notes = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final Database db = await _openDatabase();
    final List<Map<String, dynamic>> maps = await db.query('notes');
    setState(() {
      notes = List.generate(maps.length, (i) {
        return maps[i]['note'];
      });
    });
  }

  Future<void> _addNote() async {
    final Database db = await _openDatabase();
    await db.insert('notes', {'note': _controller.text});
    _controller.clear();
    _loadNotes();
  }

  Future<Database> _openDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'notes_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, note TEXT)',
        );
      },
      version: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes App'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: "Add a Note"),
          ),
          ElevatedButton(
            onPressed: _addNote,
            child: Text("Add Note"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(notes[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}