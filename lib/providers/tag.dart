// import 'dart:convert';

// import 'package:flutter/foundation.dart';
// import 'package:practice1/utils/custom_exception.dart';
// // import 'package:shared_preferences/shared_preferences.dart';

// class Tag {
//   final String title;
//   final String color;

//   Tag.fromJson(Map<String, String> json)
//       : title = json['title'],
//         color = json['color'];

//   Map<String, Object> toJson() {
//     return {'title': title, 'color': color};
//   }
// }

// class TagProvider with ChangeNotifier {
//   List<Tag> tags = [];

//   List<Tag> get allTags {
//     return [...tags];
//   }

//   Future<void> readAllTags(String key) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     try {
//       tags = prefs.getString(key) == null
//           ? <Tag>[
//               Tag.fromJson({
//                 'title': 'Travel',
//                 'color': '#ff0000',
//               }),
//               Tag.fromJson({
//                 'title': 'Personal',
//                 'color': '#50C878',
//               }),
//               Tag.fromJson({
//                 'title': 'Life',
//                 'color': '#6a0dad',
//               }),
//               Tag.fromJson({
//                 'title': 'Work',
//                 'color': '#008080',
//               }),
//               Tag.fromJson({
//                 'title': 'Untagged',
//                 'color': '#4285f4',
//               }),
//             ]
//           : (json.decode(prefs.getString(key)) as List<dynamic>)
//               .map((tag) =>
//                   Tag.fromJson({'title': tag['title'], 'color': tag['color']}))
//               .toList();
//       print("tags $tags");
//       notifyListeners();
//     } catch (err) {
//       print("Read prefs value err: $err");
//     }
//   }

//   Future<void> write(String key, dynamic value) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<dynamic> temp = tags.map((tag) => tag.toJson()).toList()
//       ..insert(0, value);
//     await prefs.setString(key, json.encode(temp));
//     readAllTags('tags');
//   }
// }
