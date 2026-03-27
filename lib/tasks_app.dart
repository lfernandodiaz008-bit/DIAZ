import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() => runApp(TaskApp());

class TaskApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TaskList(),
    );
  }
}

class Task {
  int? id;
  String title;
  String description;
  bool isDone;
  String createdAt;

  Task({this.id, required this.title, required this.description, this.isDone = false}) : createdAt = DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone': isDone ? 1 : 0,
      'createdAt': createdAt,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isDone: map['isDone'] == 1,
    );
  }
}

class TaskList extends StatefulWidget {
  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  late Database database;
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    initDatabase();
  }

  Future<void> initDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'tasks.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY, title TEXT, description TEXT, isDone INTEGER, createdAt TEXT)',
        );
      },
    );
    loadTasks();
  }

  Future<void> loadTasks() async {
    final List<Map<String, dynamic>> maps = await database.query('tasks');
    setState(() {
      tasks = List.generate(maps.length, (i) {
        return Task.fromMap(maps[i]);
      });
    });
  }

  Future<void> addTask(Task task) async {
    await database.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await database.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await database.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return ListTile(
            title: Text(task.title),
            subtitle: Text(task.description),
            trailing: Checkbox(
              value: task.isDone,
              onChanged: (bool? value) {
                setState(() {
                  task.isDone = value!;
                  updateTask(task);
                });
              },
            ),
            onLongPress: () => deleteTask(task.id!),
            onTap: () {
              // Logic for editing task could go here
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Logic for adding task could go here
        },
        tooltip: 'Add Task',
        child: Icon(Icons.add),
      ),
    );
  }
}
