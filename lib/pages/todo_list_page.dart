import 'package:crudflutter/models/todo.dart';
import 'package:crudflutter/repositories/todo_repository.dart';
import 'package:crudflutter/widgets/todo_list_item.dart';
import 'package:flutter/material.dart';

class CrudFlutter extends StatefulWidget {
   CrudFlutter({Key? key}) : super(key: key);

  @override
  State<CrudFlutter> createState() => _CrudFlutterState();
}

class _CrudFlutterState extends State<CrudFlutter> {
   final TextEditingController todoController = TextEditingController();
   final TodoRepository todoRepository = TodoRepository();
   List<Todo> todos = [];
   Todo? deletedTodo;
   int? deletedTodoPosition;
   String? erroText;
   @override
  void initState() {
    super.initState();
    todoRepository.getTodoList().then((value){
      setState(() {
        todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: todoController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Adicione uma tarefa',
                            errorText: erroText,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xff00d7f3),
                              width: 2
                            )
                          )
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                        onPressed: (){
                          String txt = todoController.text;
                          if(txt.isEmpty){
                            setState(() {
                              erroText  = 'titulo é obrigatório';
                            });
                            return;
                          }
                          setState(() {
                            Todo newTodo = new Todo(
                                title: txt,
                                dateTime: DateTime.now());
                            todos.add(newTodo);
                            erroText = null;

                          });
                          todoController.clear();
                          todoRepository.saveTodoList(todos);
                        },
                        style: ElevatedButton.styleFrom(
                            primary: Color(0xff00d7f3),
                            padding: EdgeInsets.all(14)
                        ),
                        child: Icon(
                          Icons.add,
                          size: 30,
                        ))
                  ],
                ),
                SizedBox(height: 16,),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for(Todo todo in todos)
                        TodoListItem(
                          todo: todo,
                          onDelete: onDelete,)
                    ],
                  ),
                ),
                SizedBox(height: 16,),
                Row(
                  children: [
                    Expanded(child: Text('Você possui ${todos.length} tarefas pendentes')),
                    SizedBox(width: 8,),
                    ElevatedButton(
                        onPressed: showDeleteConfirmationDialog,
                        child: Text('Limpar tudo'),
                        style: ElevatedButton.styleFrom(
                        primary: Color(0xff00d7f3),
                        padding: EdgeInsets.all(14)
                    ))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

   void onDelete(Todo todo){
    deletedTodo = todo;
    deletedTodoPosition = todos.indexOf(todo);
     setState(() {
       todos.remove(todo);
     });
    todoRepository.saveTodoList(todos);

    ScaffoldMessenger.of(context).clearSnackBars();
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
         content:Text('Tarefa ${todo.title} removida com sucesso!',
         style: TextStyle(color: Colors.black),),
         backgroundColor: Colors.white,
         action: SnackBarAction(
           label: 'Desfazer',
           textColor: const Color(0xff00d7f3),
           onPressed: (){
             setState(() {
               todos.insert(deletedTodoPosition!, deletedTodo!);
             });
             todoRepository.saveTodoList(todos);
           },
         ),
         duration: const Duration(seconds: 5),
       ),

     );
   }

   void showDeleteConfirmationDialog(){
    showDialog(
      context: context,
      builder: (context)=>AlertDialog(
        title: Text('Limpar tudo ?'),
        content: Text('Você tem certeza que deseja apagar todas as tarefas?'),
        actions: [
          TextButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: Text('Cancelar')),
          TextButton(
              onPressed: (){
                Navigator.of(context).pop();
                deleteAllTodos();
              },
              child: Text('Limpar Tudo!'),
              style: TextButton.styleFrom(primary: Colors.red),)

        ],
      )
    );
   }

   void deleteAllTodos(){
    setState(() {
      todos.clear();
    });
    todoRepository.saveTodoList(todos);
  }
}