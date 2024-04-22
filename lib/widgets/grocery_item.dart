import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;

import 'new_item.dart';

class ListItem extends StatefulWidget{
   const ListItem ({super.key});

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;
  @override
  void initState() {
    late Future<List<GroceryItem>> _loadedItems;
    super.initState();
    _loadedItems = _loadItems();
  }

  Future<List<GroceryItem>> _loadItems() async {
  final url = Uri.https('shopping-list-a483a-default-rtdb.firebaseio.com',
      'shopping-list.json');

    final response = await http.get(url);
    if(response.statusCode >= 400)
    {
      setState(() {
        _error = "Failed to fetch the data, please try again later.";
      });
    }
    if(response.body == 'null'){
      return [];
    }
    final Map<String,dynamic> listData = json.decode(response.body);
    List<GroceryItem> _loadedItems = [];
    for(final item in listData.entries){
      final category = categories.entries.firstWhere(
              (element) => element.value.fruitName == item.value['category']).value;
      _loadedItems.add(
          GroceryItem(
              id: item.key,
              name: item.value['name'],
              quantity: item.value['quantity'],
              category: category
          ));
    }
    return _loadedItems;
     }

   void _addItem() async {

      final newItem = await Navigator.of(context).push<GroceryItem>(
       MaterialPageRoute(
         builder: (ctx) => const NewItem(),
       ),
     );
      if (newItem == null){
        return;
      }
      {
        setState(() {
          _groceryItems.add(newItem);
        });
      }
   }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https('shopping-list-a483a-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final respose = await http.delete(url);
    if(respose.statusCode >= 400){
      setState(() {
        _groceryItems.insert(index, item);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to remove item")));
      });
    }
  }

   @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text("There is no added category"),);

    if(_isLoading){
      content = const Center(child: CircularProgressIndicator(),);
    }

    if(_groceryItems.isNotEmpty){
      content = ListView.builder(
          itemCount: _groceryItems.length,
          itemBuilder: (ctx , index) =>  Dismissible(
            onDismissed: (direction){
              _removeItem(_groceryItems[index]);
            },
            key: ValueKey(_groceryItems[index].id),
            child: ListTile(
              title: Text(_groceryItems[index].name),
              leading: Container(
                height: 24,
                width: 24,
                color: _groceryItems[index].category.color,
              ),
              trailing: Text(_groceryItems[index].quantity.toString()),
            ),
          ));}
    if(_error != null){
      _isLoading = false;
      content = Center(child: Text(_error!),);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Your Categories"),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body:  content
    );
  }
}