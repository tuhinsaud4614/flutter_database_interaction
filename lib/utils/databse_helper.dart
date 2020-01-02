import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final _instance = DatabaseHelper._internal();
  static Database _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get db async {
    if (_database != null) {
      return _database;
    }

    _database = await _init();
    return _database;
  }

  Future<Database> _init() async {
    print("db");
    Directory directory = await getApplicationDocumentsDirectory();
    String dbPath = join(directory.path, 'todo.db');

    Database database = await openDatabase(dbPath,
        version: 1, onCreate: _onCreate, onConfigure: _onConfigure);
    return database;
  }

  static Future<void> _onCreate(Database db, int version) async {
    print("_onCreate");
    await db.execute(
      "CREATE TABLE task(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT, image TEXT NULL, due_date DATETIME, tag_id INTEGER, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL)",
    );

    await db.execute(
      "CREATE TABLE tag(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, color TEXT, is_selected INTEGER)",
    );
    await db.execute(
        "INSERT INTO tag(title, color, is_selected) VALUES('travel', 'ffff0000', 0),('personal', 'ff50C878', 0),('life', 'ff6a0dad', 0),('work', 'ff008080', 0),('untagged', 'ff4285f4', 1)");
  }

  static Future<void> _onConfigure(Database db) async {
    await db.execute("PRAGMA foreign_keys = ON");
  }

  Future<int> saveTask(Map<String, dynamic> task) async {
    Database client = await db;
    print(task['description']);
    int res = await client.insert("task", task);
    return res;
  }

  Future<List<Map<String, dynamic>>> fetchAllTasks() async {
    Database client = await db;
    List<Map<String, dynamic>> result = await client.rawQuery(
        "SELECT task.title, task.description, task.image, task.due_date, task.tag_id, tag.title as 'tag_title', tag.color FROM task INNER JOIN tag ON task.tag_id = tag.id");
    return result;
  }

  Future<List<Map<String, dynamic>>> fetchAllTags() async {
    Database client = await db;
    List<Map<String, dynamic>> result =
        await client.rawQuery("SELECT * FROM tag");
    return result;
  }

  Future<int> saveTag(Map<String, dynamic> tag) async {
    Database client = await db;
    int res = await client.insert("tag", tag);
    return res;
  }

  Future<int> selectTag(int id) async {
    Database client = await db;
    int res = await client.rawUpdate("""
      UPDATE tag SET is_selected = 1 WHERE id= $id""");
    res = await client.rawUpdate("""
      UPDATE tag SET is_selected = 0 WHERE NOT id = $id""");
    return res;
  }
}
