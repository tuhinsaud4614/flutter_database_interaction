import 'package:flutter/material.dart';
import 'package:practice1/utils/databse_helper.dart';

class TodoProvider extends ChangeNotifier {
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Map<String, dynamic>> _allTags = [];

  Future<List<Map<String, dynamic>>> get tags async {
    _allTags = await _dbHelper.fetchAllTags();
    return [..._allTags];
  }

  // List<Map<String, dynamic>> get tags {
  //   print("tags");
  //   _dbHelper.fetchAllTags().then((results) {
  //     _allTags = results;
  //     // notifyListeners();
  //   });
  //     return [..._allTags];
  // }

  void saveData(Map<String, dynamic> task) {
    _dbHelper.saveTask(task).then((int value) {
      print(value);
    });
  }

  Future<List<Map<String, dynamic>>> allData() async {
    List<Map<String, dynamic>> result = await _dbHelper.fetchAllTasks();
    // print(result);
    return result;
  }

  void addTag({String newTagName, String newTagColor, int newTagSelected = 1}) {
    _dbHelper.saveTag({
      "title": newTagName,
      "color": newTagColor,
      "is_selected": newTagSelected,
    }).then((int value) {
      print(value);
    });
  }

  Future<void> selectTag(int id) async {
    int value = await _dbHelper.selectTag(id);
    if (value > 0) {
      print(value);
      notifyListeners();
    }
    //  _dbHelper.selectTag(id).then((int value) {
    //     print(value);
    //     notifyListeners();
    //   });
  }
}
