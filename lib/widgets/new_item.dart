import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {

  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables];
  var _isSaving = false;
  void _saveItem() async {
    if(_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSaving = true;
      });
      final url = Uri.https('shopping-list-a483a-default-rtdb.firebaseio.com',
          'shopping-list.json');
      final response = await http.post(
          url,
          headers: {
            "content-type": "application/json"
          },
          body: json.encode({
            "name": _enteredName,
            "quantity": _enteredQuantity,
            "category": _selectedCategory!.fruitName
          })
      );
      final Map<String , dynamic> resData = json.decode(response.body);
      if(!context.mounted){
        return;
      }
      {
        Navigator.of(context).pop(GroceryItem(
            id: resData['name'],
            name: _enteredName,
            quantity: _enteredQuantity,
            category: _selectedCategory!
        ));
      }
    }
    //Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("New Item"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text("Name"),
                  ),
                  maxLength: 50,
                  validator: (value){
                    if(
                    value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50
                    ) {
                      return "Must be between 1 and 50";
                    }
                    return null;
                    },
                  onSaved: (value){
                    _enteredName = value!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _enteredQuantity.toString(),
                        decoration: const InputDecoration(
                          label: Text("Quantity"),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value){
                          if(
                          value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0
                          ) {
                            return "Must be valid, positive number ";
                          }
                          return null;
                        },
                        onSaved: (value){
                          _enteredQuantity = int.parse(value!);
                        },
                      ),
                    ),
                    const SizedBox(width: 8,),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: _selectedCategory,
                          items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  height: 16,
                                  width: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 6,),
                                Text(category.value.fruitName),

                              ],
                            ),
                          )
                      ],
                          onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                          }),
                    )
                  ],
                ),
                const SizedBox(height: 12,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                  TextButton(
                    onPressed: _isSaving ? null : (){_formKey.currentState!.reset();},
                    child: const Text("Reset"),),
                  ElevatedButton(
                    onPressed: _isSaving ? null :  _saveItem,
                    child:  _isSaving ?
                    const SizedBox(width: 16,height: 16,child: CircularProgressIndicator(),)
                        :  const Text("Add Item"),),
                ],)
              ],
            ),
          ),
        ));
  }
}
