import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import './providers/tag.dart';
import './providers/todo.dart';
import './tag_picker.dart';
import 'package:provider/provider.dart';

import 'utils/hex_color_generator.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: TodoProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
        home: MyHomePage(),

        // MyHomePage(title: 'Flutter Demo Home Page')),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _date = DateTime.now();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  // TextEditingController imageController = TextEditingController();
  String imageData = "";
  File _image;
  Map<String, dynamic> _tag = {
    "title": "untagged",
    "color": "ff4285f4",
    "is_selected": 1,
  };

  bool _isInit = false;

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      _isInit = true;
      Provider.of<TodoProvider>(context, listen: false).tags.then((tags) {
        _tag = tags.firstWhere((Map<String, dynamic> tag) {
          return tag['is_selected'] == 1;
        });
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("add Todo"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.bookmark,
                color: Color(
                  int.parse(_tag['color'], radix: 16),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => TagPicker(),
                ).then((dynamic tag) {
                  if (tag != null) {
                    setState(() {
                      _tag = tag;
                    });
                  }
                  print(Color(int.parse(_tag['color'], radix: 16)));
                });
              },
            ),
            SizedBox(
              height: 10.0,
            ),
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "title"),
            ),
            SizedBox(
              height: 10.0,
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: "description"),
            ),
            SizedBox(
              height: 10.0,
            ),
            // TextField(
            //   controller: imageController,
            //   decoration: InputDecoration(labelText: "image"),
            // ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  height: 150.0,
                  width: 150.0,
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: _image == null
                      ? Text("No image selected")
                      : Image.file(
                          _image,
                        ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton.icon(
                      icon: Icon(Icons.image),
                      label: Text("Gallery"),
                      onPressed: () async {
                        var image = await ImagePicker.pickImage(
                          source: ImageSource.gallery,
                        );

                        setState(() {
                          _image = image;
                        });
                      },
                    ),
                    RaisedButton.icon(
                      icon: Icon(Icons.camera_alt),
                      label: Text("Camera"),
                      onPressed: () async {
                        var image = await ImagePicker.pickImage(
                          source: ImageSource.camera,
                        );

                        setState(() {
                          _image = image;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Container(
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () {
                      showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2019),
                        lastDate: DateTime(2030),
                      ).then((date) {
                        if (date != null && date != _date) {
                          setState(() {
                            _date = date;
                          });
                        }
                      });
                    },
                  ),
                  Text("Due Date: ${_date.toString()}"),
                ],
              ),
            ),

            SizedBox(
              height: 10.0,
            ),
            RaisedButton.icon(
              onPressed: () {
                if (_image != null) {
                  imageData = base64.encode(_image.readAsBytesSync());
                }
                Provider.of<TodoProvider>(context, listen: false)
                    .saveData(<String, dynamic>{
                  "title": titleController.text,
                  "description": descriptionController.text,
                  "image": imageData,
                  "due_date": _date.toIso8601String(),
                  "tag_id": _tag['id'],
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return DetailPage();
                    },
                  ),
                );
              },
              icon: Icon(Icons.save),
              label: Text("Save"),
            ),
            SizedBox(
              height: 10.0,
            ),
            RaisedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return DetailPage();
                    },
                  ),
                );
              },
              child: Text("Show ALL Data"),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ALL DATA"),
      ),
      body: FutureBuilder(
        future: Provider.of<TodoProvider>(context, listen: false).allData(),
        builder: (context, snapShot) {
          // print(snapShot.data);
          if (snapShot.hasData) {
            print(snapShot.data);
            return snapShot.data.length != 0
                ? ListView.separated(
                    separatorBuilder: (context, index) {
                      return Divider(
                        height: 0,
                      );
                    },
                    padding: const EdgeInsets.only(top: 15.0),
                    itemCount: snapShot.data.length,
                    itemBuilder: (context, index) {
                      // print(base64.decode(snapShot.data[index]['image']));
                      return ListTile(
                        onTap: () {},
                        leading: CircleAvatar(
                          backgroundImage: MemoryImage(
                            base64.decode(snapShot.data[index]['image']),
                          ),
                        ),
                        title: Text("${snapShot.data[index]['title']}"),
                        subtitle: Text(
                            "${snapShot.data[index]['description']} ${snapShot.data[index]['tag_title']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text("${snapShot.data[index]['due_date']}"),
                            Icon(
                              Icons.bookmark,
                              color: Color(int.parse(
                                  snapShot.data[index]['color'],
                                  radix: 16)),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text("No Data Found"),
                  );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key key, this.title}) : super(key: key);

//   final String title;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   // List<Tag> _allTags;
//   bool _init = false;
//   @override
//   void didChangeDependencies() {
//     print("[_MyHomePageState] didChangeDependencies()");
//     if (!_init) {
//       _init = true;
//       Provider.of<TagProvider>(context).readAllTags("tags");
//     }
//     super.didChangeDependencies();
//   }

//   @override
//   Widget build(BuildContext context) {
//     print("[_MyHomePageState] Build()");
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Home"),
//       ),
//       body: Column(
//         children: <Widget>[
//           RaisedButton(
//             onPressed: () {
//               print("RaisedButton");
//               Provider.of<TagProvider>(context)
//                   .write('tags', {"title": "new", "color": "#ff00ff"})
//                   .then((_) => {print("Successful")})
//                   .catchError((err) => print("$err"));
//             },
//             child: Text("Add value"),
//           ),
//           Expanded(
//             child: Consumer<TagProvider>(
//               builder: (context, tags, child) => ListView.builder(
//                 itemCount: tags.allTags.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(tags.allTags[index].title),
//                     leading: CircleAvatar(
//                       backgroundColor: HexColorGenerator(
//                           hexColorString: tags.allTags[index].color),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//       // floatingActionButton: FloatingActionButton(
//       //   onPressed: () {
//       //     Provider.of<TagProvider>(context, listen: false).read('tags');
//       //   },
//       //   tooltip: 'Increment',
//       //   child: Icon(Icons.add),
//       // ),
//     );
//   }
// }
