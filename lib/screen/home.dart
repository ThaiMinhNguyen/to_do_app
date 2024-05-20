import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:to_do_app/screen/to_do.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = true;

  List items = [];

  @override
  void initState() {
    super.initState();
    fetchData();
    print(items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white10,
        centerTitle: true,
        title: Text(
          'To Do List',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 25,
          ),
        ),
        titleTextStyle: TextStyle(

        ),
      ),
      body: Visibility(
        visible: isLoading,
        child: SpinKitRotatingCircle(
          color: Colors.white,
          size: 100.0,
        ),
        replacement: RefreshIndicator(
          onRefresh: fetchData,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(items[index]['title']),
              subtitle: Text(items[index]['description']),
              trailing: PopupMenuButton(
                onSelected: (value) {
                  if(value == 'edit'){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ToDoItem(item: items[index],),)).then((value){
                      setState(() {
                        fetchData();
                      });
                    });
                  } else if (value == 'delete') {
                    // print(items[index]['_id']);
                    deleteItem(items[index]['_id']);
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      child: Text("Edit"),
                      value: 'edit',
                    ),
                    PopupMenuItem(
                      child: Text("Delete"),
                      value: 'delete',
                    )
                  ];
                },
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ToDoItem(),)).then((value){
            setState(() {
              fetchData();
            });
          });
        },
        label: Text('Add'),
      ),
    );
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    final uri = Uri.parse('https://api.nstack.in/v1/todos?page=1&limit=10');
    final response = await http.get(uri);
    print(response.statusCode);
    print(response.body);
    if(response.statusCode == 200){
      final result = jsonDecode(response.body);
      final a = result['items'] as List;
      setState(() {
        items = a;
        isLoading = false;
      });
    }
    // setState(() {
    //   isLoading = false;
    // });
  }

  Future<void> deleteItem(String id) async {
    final uri = Uri.parse('https://api.nstack.in/v1/todos/$id');
    final response = await http.delete(uri);
    print(response.statusCode);
    print(response.body);
    setState(() {
      fetchData();
    });
  }

}
