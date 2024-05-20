import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ToDoItem extends StatefulWidget {

  final Map? item;
  const ToDoItem({super.key, this.item});


  @override
  State<ToDoItem> createState() => _ToDoItemState();
}

class _ToDoItemState extends State<ToDoItem> {
  bool isEdit = false;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String id = '';


  @override
  void initState() {
    super.initState();
    if(widget.item != null){
      final todo = widget.item;
      isEdit = true;
      titleController.text = todo?['title'];
      descriptionController.text = todo?['description'];
      id = todo?['_id'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          isEdit ? 'Edit Todo' : 'Add Todo',
          style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 25,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsetsDirectional.all(20),
        children: [
          // Text('Title'),
          TextField(
            decoration: InputDecoration(
              labelText: 'Title',
              labelStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
              alignLabelWithHint: true,

            ),
            controller: titleController,

          ),
          SizedBox(height: 20,),
          TextField(
            decoration: InputDecoration(
              labelText: 'Description',
              labelStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
              alignLabelWithHint: true,
            ),
            controller: descriptionController,
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 10,
          ),
          SizedBox(height: 10),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.all(10),
              backgroundColor: Colors.blue,
            ),
            onPressed: isEdit ? updateToDo : addToDo,
            child: Text(
              isEdit ? "Update" : "Add to list",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> addToDo() async {
    String title = titleController.text;
    String description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    var uri = Uri.parse('https://api.nstack.in/v1/todos');
    final response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
      }
    );

    if(response.statusCode == 201){
      print("Create success");
      showSuccessMessage("Create successfully");
      Navigator.pop(context);
    } else {
      showFailedMessage("Create failed");
    }
  }

  Future<void> updateToDo() async {
    final uri = Uri.parse('https://api.nstack.in/v1/todos/$id');
    final body = {
      "title": titleController.text,
      "description": descriptionController.text,
      "is_completed": false
    };
    final response = await http.put(
      uri,
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
      }
    );
    print(response.statusCode);
    print(response.body);
    if(response.statusCode == 200){
      print("Update success");
      showSuccessMessage("Update successfully");
      Navigator.pop(context);
    } else {
      showFailedMessage("Update failed");
    }
  }

  void showSuccessMessage(String s) {
    final snackBar = SnackBar(
      content: Text(s),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showFailedMessage(String s) {
    final snackBar = SnackBar(
      content: Text(
        s,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

}
