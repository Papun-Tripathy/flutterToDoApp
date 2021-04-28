import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do_app/models/task_models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database _db;

  DatabaseHelper._instance();
  String tasksTable = 'taskstable';
  String colId = 'id';
  String colTitle = 'title';
  String colDate = 'date';
  String colPriority = 'priority';
  String colStatus = 'status';
  String colTime = 'time';

  Future<Database> get db async {
    print(_db);
    if (_db == null) {
      print('init called');
      _db = await _initDb();
    }
    return _db;
  }

  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + 'the_on_device_todo_list.db';

    print('Path: '+path);
    final todoListDb = await openDatabase(path, version: 2,onCreate: _createDb);

    return todoListDb;
  }

  void _createDb(Database db, int version) async {
    print('came to create DB');
    await db.execute(
        'CREATE TABLE $tasksTable ($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDate TEXT, $colPriority TEXT, $colStatus INTEGER, $colTime VARCHAR(12)) ');

  }

  Future<List<Map<String, dynamic>>> getTaskMapList() async {
    Database db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(tasksTable);
    return result;
  }

  Future<List<Task>> getTaskList() async {
    final List<Map<String, dynamic>> taskMapList = await getTaskMapList();
    final List<Task> taskList = [];

    taskMapList.forEach((element) {
      taskList.add(Task.fromMap(element));
    });
    taskList.sort((task1, task2) => task1.date.compareTo(task2.date));
    print(taskList);
    return taskList;
  }

  Future<int> insertTask(Task task) async {
    Database db = await this.db;

    final int result = await db.insert(tasksTable, task.toMap());

    return result;
  }

  Future<int> updateTask(Task task) async {
    Database db = await this.db;
    final int result = await db.update(
      tasksTable,
      task.toMap(),
      where: '$colId = ?',
      whereArgs: [task.id],
    );
    return result;
  }

  Future<int> deleteTask(int id) async {
    Database db = await this.db;
    final int result = await db.delete(
      tasksTable,
      where: '$colId = ?',
      whereArgs: [id],
    );
    return result;
  }
}
