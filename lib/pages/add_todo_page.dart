import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoPage extends StatefulWidget {
  final Map? todo;
  const AddTodoPage({Key? key, this.todo}) : super(key: key);

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    final todo = widget.todo;
    if(todo != null){
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Todo' : 'Add Todo'),
      ),

      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: 'Title'
            ),
          ),
          const SizedBox(height: 20,),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              hintText: 'Description'
            ),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          const SizedBox(height: 20,),
          ElevatedButton(
              onPressed:isEdit? updateData : submitData,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(isEdit ? 'Update' : 'Submit'),
              ),
          )
        ],
      ),
    );
  }

  Future<void> updateData() async {
    final todo = widget.todo;
    if(todo == null){
      print('you can not call update without previous data');
      return;
    }
    final id = todo['_id'];
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      'title': title,
      'description': description,
      'is_completed': false,
    };
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.put(uri,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'}
    );

    if (response.statusCode == 200) {
      showSuccessMessage('Update Success');
    }else{
      showErrorMessage('Update Failed');
    }
  }

  Future<void> submitData() async {
    //Get the data from form
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      'title': title,
      'description': description,
      'is_completed': false,
    };
    //Submit data to the server
    final url = 'https://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(uri,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'}
    );
    //show success or failed message based on status
    if (response.statusCode == 201) {
      titleController.text = '';
      descriptionController.text = '';
      print('Creation Success');
      showSuccessMessage('Creation Success');
    }else{
      print('Creation Failed');
      showErrorMessage('Creation Failed');
    }
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
