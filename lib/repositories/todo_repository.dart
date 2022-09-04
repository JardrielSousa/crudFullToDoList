import 'dart:convert';

import 'package:crudflutter/models/todo.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String todoListKey = 'todo_list';

class TodoRepository {
  late SharedPreferences sharedPreferences;
  
  void saveTodoList(List<Todo> todos){
    final todoString = json.encode(todos);
    sharedPreferences.setString(todoListKey, todoString) ;
  }

  Future<List<Todo>> getTodoList() async{
    sharedPreferences = await SharedPreferences.getInstance();
    final String jsonString = sharedPreferences.getString(todoListKey) ?? '[]';
    final List jsonDecoded = json.decode(jsonString) as List;
    return jsonDecoded.map((e) => Todo.fromJson(e)).toList();
  }

}