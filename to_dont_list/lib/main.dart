// Started with https://docs.flutter.dev/development/ui/widgets-intro
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_dont_list/objects/item.dart';
import 'package:to_dont_list/widgets/to_do_items.dart';
import 'package:to_dont_list/widgets/to_do_dialog.dart';

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  State createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  final List<GroceryItem> items = [GroceryItem(name: "add more groceries")];
  final _itemSet = <GroceryItem>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Load the saved list (if any) when the app starts
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('groceries');
    if (saved == null) return; // first launch: keep the default item
    setState(() {
      items.clear();
      _itemSet.clear();
      for (final m in jsonDecode(saved)) {
        final item = GroceryItem(name: m['name'], quantity: m['quantity']);
        items.add(item);
        if (m['done'] == true) _itemSet.add(item);
      }
    });
  }

  // Save the whole list after any change so it survives closing the app
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = items
        .map((i) => {
              'name': i.name,
              'quantity': i.quantity,
              'done': _itemSet.contains(i),
            })
        .toList();
    await prefs.setString('groceries', jsonEncode(data));
  }

  void _handleListChanged(GroceryItem item, bool completed) {
    setState(() {
      // When a user changes what's in the list, you need
      // to change _itemSet inside a setState call to
      // trigger a rebuild.
      // The framework then calls build, below,
      // which updates the visual appearance of the app.

      items.remove(item);
      if (!completed) {
        print("Completing");
        _itemSet.add(item);
        items.add(item);
      } else {
        print("Marking Undone");
        _itemSet.remove(item);
        items.insert(0, item);
      }
    });
    _save();
  }

  void _handleDeleteItem(GroceryItem item) {
    setState(() {
      print("Deleting item");
      items.remove(item);
    });
    _save();
  }

  void _handleNewItem(String itemText, TextEditingController textController) {
    setState(() {
      print("Adding new item");
      String itemName = itemText;
      GroceryItem item = GroceryItem(name: itemName);
      items.insert(0, item);
      textController.clear();
    });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Grocery List'),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          children: items.map((item) {
            return GroceryListItem(
              item: item,
              completed: _itemSet.contains(item),
              onListChanged: _handleListChanged,
              onDeleteItem: _handleDeleteItem,
              // onQuantityChanged: _save,   // <-- uncomment in commit 3
            );
          }).toList(),
        ),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (_) {
                    return ToDoDialog(onListAdded: _handleNewItem);
                  });
            }));
  }
}

void main() {
  runApp(const MaterialApp(
    title: 'To Do List',
    home: ToDoList(),
  ));
}
