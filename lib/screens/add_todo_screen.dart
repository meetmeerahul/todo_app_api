import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddScreen extends StatefulWidget {
  final Map? todo;
  const AddScreen({super.key, this.todo});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptoionController = TextEditingController();

  bool isEdit = false;

  @override
  void initState() {
    // TODO: implement initState

    final todo = widget.todo;
    super.initState();

    if (widget.todo != null) {
      isEdit = true;
      final title = todo?['title'];
      final description = todo?['description'];

      titleController.text = title;
      descriptoionController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: isEdit ? const Text("Edit page") : const Text("Add to list")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: "Task"),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: descriptoionController,
            decoration: const InputDecoration(hintText: "Description"),
            keyboardType: TextInputType.multiline,
            minLines: 3,
            maxLines: 8,
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: isEdit ? updateData : submitData,
            child: isEdit ? const Text("Edit") : const Text('Submit'),
          )
        ],
      ),
    );
  }

  Future<void> submitData() async {
    final title = titleController.text;
    final description = descriptoionController.text;

    var body = {
      "title": title,
      "description": description,
      "is_completed": false
    };

    const url = 'https://api.nstack.in/v1/todos';
    var uri = Uri.parse(url);

    var response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {'Content-type': 'application/json'},
    );

    if (response.statusCode == 201) {
      print("Creation success");
      showSuccessMessage("Created succesfully");
    } else {
      print(response.statusCode);
      print(response.body);
      showErrorMessage("Error in creation");
    }
  }

  showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  showSuccessMessage(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> updateData() async {
    final todo = widget.todo;

    if (todo == null) {
      print('You canot edit this data');
      return;
    }
    final title = titleController.text;
    final description = descriptoionController.text;
    final id = todo['_id'];
    // final isCompleated = todo['is_compleated'];

    var body = {
      "title": title,
      "description": description,
      "is_completed": false
    };

    final url = 'https://api.nstack.in/v1/todos/$id';
    var uri = Uri.parse(url);

    final response = await http.put(
      uri,
      body: jsonEncode(body),
      headers: {'Content-type': 'application/json'},
    );

    print(response.statusCode);
    if (response.statusCode == 200) {
      //print("Updation success");
      showSuccessMessage("Updated succesfully");
    } else {
      // print(response.statusCode);
      // print(response.body);
      showErrorMessage("Error in Updation");
    }
  }
}
