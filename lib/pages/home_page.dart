import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo_api/pages/add_todo_page.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List items = [];
  bool isLoading = true;

  @override
  void initState() {
    fetchTodo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: Visibility(
        visible: isLoading,
        child:  Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index){
                final item = items[index] as Map;
                final id = item['_id'] as String;
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(item['title']),
                  subtitle: item['is_completed']?Text(item['description']): Text(item['title']),
                  trailing: PopupMenuButton(
                    onSelected: (value){
                      if(value == 'edit'){
                        navigateToEditPage(item);
                      }else if(value == 'delete'){
                        deleteById(id);
                      }else if(value == 'done') {
                        doneById(item);
                      }
                    },
                    itemBuilder: (context){
                      return [
                        PopupMenuItem(
                            child: Text('Edit'),
                            value: 'edit',
                        ),
                        PopupMenuItem(
                            child: Text('Delete'),
                            value: 'delete',
                        ),
                        PopupMenuItem(
                          child: Text('Done'),
                          value: 'done',
                        ),
                      ];
                    },
                  ),
                );
              }
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateToAddPage,
          label: const Text('Add Todo')
      ),
    );
  }

  Future<void> navigateToAddPage() async{
    final route = MaterialPageRoute(
        builder: (context) => AddTodoPage(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> navigateToEditPage(Map item) async{
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(todo: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> deleteById(String id) async{
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if(response.statusCode == 200) {
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    } else{
      showErrorMessage('Deletion Failed');
    }
  }



  Future<void> doneById(item) async{
    if(item == null){
      print('you can not call update without previous data');
      return;
    }
    final id = item['_id'];
    final title = item['title'];
    final description = item['description'];
    final body = {
      'title': title,
      'description': description,
      'is_completed': true,
    };
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.put(uri,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'}
    );

    print(response.statusCode);

    if (response.statusCode == 404) {
      showSuccessMessage('Update Success');
    }else{
      showErrorMessage('Update Failed');
    }
  }



  Future<void> fetchTodo() async {
    final url = 'http://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    }
    setState(() {
      isLoading = false;
    });
  }


  void showSuccessMessage(String message){
    final snackBar = SnackBar(content:  Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message){
    final snackBar = SnackBar(
      content:  Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
