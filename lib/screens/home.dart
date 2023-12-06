import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo_app_api/screens/add_todo_screen.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List items = [];
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("ToDO App"),
        ),
      ),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                final id = item['_id'] as String;

                return Visibility(
                  visible: items.isNotEmpty,
                  replacement: const Center(
                    child: Text("List is empty"),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text("${index + 1}"),
                    ),
                    title: Text(item['title']),
                    subtitle: Text(item['description']),
                    trailing: PopupMenuButton(onSelected: (value) {
                      if (value == 'edit') {
                        navigateToEditPage(item);
                      } else {
                        deleteById(id);
                      }
                    }, itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ];
                    }),
                  ),
                );
              }),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToAddPage();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void navigateToEditPage(Map items) async {
    final route = MaterialPageRoute(
      builder: (context) => AddScreen(
        todo: items,
      ),
    );

    await Navigator.push(context, route);

    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  void navigateToAddPage() async {
    final route = MaterialPageRoute(
      builder: (context) => const AddScreen(),
    );

    await Navigator.push(context, route);

    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> fetchTodo() async {
    const url = "https://api.nstack.in/v1/todos?page=1&limit=10";

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

    print(response.statusCode);
    print(response.body);
  }

  void deleteById(String id) async {
    final url = "https://api.nstack.in/v1/todos/$id";

    final uri = Uri.parse(url);

    final response = await http.delete(uri);

    final filteredItems =
        items.where((element) => element['_id'] != id).toList();

    setState(() {
      items = filteredItems;
    });

    if (response.statusCode == 200) {
      showSuccessMessage("deleted successfully");
    } else {
      showErrorMessage('Error in deleting');
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
}
