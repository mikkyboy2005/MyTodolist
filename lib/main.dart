import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytodolist/todo_view_model.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TodoViewModel(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.blue,
          accentColor: Colors.orange,
        ),
        home: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String todoTitle = '';

  createTodos() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("MyTodos").doc(todoTitle);

    // Map
    Map<String, String> todos = {
      "todoTitle": todoTitle,
    };
    documentReference.set(todos).whenComplete(
      () {
        print('$todoTitle created');
      },
    );
  }

  deleteTodos(item) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("MyTodos").doc(item);

    documentReference.delete().whenComplete(() {
      print('$item deleted');
    });
  }

  @override
  Widget build(BuildContext context) {
    TodoViewModel viewModel = Provider.of<TodoViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('My Todos'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                title: Text('Add Todolist'),
                content: TextField(
                  onChanged: (String value) {
                    todoTitle = value;
                  },
                ),
                actions: [
                  FlatButton(
                    onPressed: () {
                      createTodos();
                      Navigator.pop(context);
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("MyTodos").snapshots(),
        builder: (context, snapshots) {
          if (snapshots.data == null) return CircularProgressIndicator();
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshots.data.docs.length,
            itemBuilder: (BuildContext context, index) {
              DocumentSnapshot documentSnapshot =
                  snapshots.data.documents[index];
              return Dismissible(
                onDismissed: (direction) {
                  deleteTodos(documentSnapshot["todoTitle"]);
                },
                key: Key(documentSnapshot["todoTitle"]),
                child: Card(
                  elevation: 4.0,
                  margin: EdgeInsets.all(8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    title: Text(documentSnapshot["todoTitle"]),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        viewModel.delete(documentSnapshot["todoTitle"]);
                        // setState(() {
                        //   deleteTodos(documentSnapshot["todoTitle"]);
                        // });
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
