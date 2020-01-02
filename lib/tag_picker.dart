import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:practice1/providers/todo.dart';
import 'package:provider/provider.dart';

class TagPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("[TagPicker] build");
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 40.0,
            alignment: Alignment.center,
            child: Text("ADD TAG"),
          ),
          Divider(
            height: 0,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  CustomTags(),
                  CustomAddTag(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: OutlineButton(
              textTheme: ButtonTextTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                "CANCEL",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTags extends StatelessWidget {
  // var oldData = [];
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<TodoProvider>(context).tags,
      builder: (context, snapShot) {
        print("FutureBuilder");
        if (snapShot.hasData) {
          // if (snapShot.hasData && snapShot.data != oldData) {
          // oldData = snapShot.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ...snapShot.data.map((tag) => CustomTag(tag)).toList(),
            ],
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class CustomTag extends StatelessWidget {
  final tag;
  CustomTag(this.tag);
  @override
  Widget build(BuildContext context) {
    print(
        "[CustomTag] ${tag['title']} : ${tag['is_selected']}, ${tag['color']}");
    return ListTile(
      onTap: () async {
        Provider.of<TodoProvider>(context, listen: false)
            .selectTag(tag['id'])
            .then((_) {
          Navigator.pop(context, tag);
        });
      },
      leading: CircleAvatar(
        backgroundColor: Color(int.parse(tag['color'], radix: 16)),
      ),
      selected: tag['is_selected'] == 1,
      title: Text(
        "${tag['title']}".toUpperCase(),
        style: TextStyle(
          fontFamily: "Tomorrow",
        ),
      ),
      trailing: Icon(
        Icons.check,
        color: tag['is_selected'] == 1
            ? Theme.of(context).primaryColor
            : Colors.grey,
      ),
    );
  }
}

class CustomAddTag extends StatefulWidget {
  @override
  _CustomAddTagState createState() => _CustomAddTagState();
}

class _CustomAddTagState extends State<CustomAddTag> {
  TextEditingController _newTagTxtController;
  bool _isNewTagged = false;
  Color newTagColor = Colors.red;
  @override
  void initState() {
    _newTagTxtController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _newTagTxtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("CustomAddTag");
    return _isNewTagged
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                InkWell(
                  child: Icon(
                    Icons.clear,
                    color: Colors.blueAccent,
                  ),
                  onTap: () {
                    setState(() {
                      _isNewTagged = false;
                    });
                  },
                ),
                SizedBox(
                  width: 15.0,
                ),
                Expanded(
                  child: TextField(
                    controller: _newTagTxtController,
                    autofocus: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(0.0),
                      hintText: "New tag name.",
                    ),
                  ),
                ),
                InkWell(
                  child: Icon(
                    Icons.bookmark,
                    color: newTagColor,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      // barrierDismissible: false,

                      child: AlertDialog(
                        contentPadding: const EdgeInsets.all(0),
                        title: Text("Pick Color"),
                        actions: <Widget>[
                          FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("BACK"),
                          ),
                        ],
                        content: Container(
                          height: 250,
                          constraints: BoxConstraints(
                            maxWidth: 350.0,
                          ),
                          child: MaterialColorPicker(
                            onMainColorChange: (Color color) {
                              print(color
                                  .toString()
                                  .substring(color.toString().length - 10, color.toString().length - 2));
                              setState(() {
                                newTagColor = color;
                              });
                              Navigator.pop(context);
                            },
                            allowShades: false,
                            selectedColor: newTagColor,
                            colors: [
                              Colors.red,
                              Colors.deepOrange,
                              Colors.yellow,
                              Colors.lightGreen
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(
                  width: 15.0,
                ),
                InkWell(
                  child: Icon(
                    Icons.save,
                    color: Colors.blueAccent,
                  ),
                  onTap: () {
                    if (_newTagTxtController.text.isNotEmpty) {
                      Provider.of<TodoProvider>(context, listen: false).addTag(
                          newTagName: _newTagTxtController.text,
                          newTagColor:
                              "${newTagColor.toString().substring(newTagColor.toString().length - 10, newTagColor.toString().length - 2).toString()}",
                          newTagSelected: 0);
                    }
                    Navigator.pop(context);
                    _isNewTagged = false;
                  },
                ),
              ],
            ),
          )
        : FlatButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: () {
              setState(() {
                _isNewTagged = true;
              });
            },
            child: Text(
              "New Tag",
              style: TextStyle(color: Colors.blueAccent),
            ),
          );
  }
}
