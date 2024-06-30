import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/firestore.dart';
import 'util/dialog_box.dart';
import 'util/todo_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final FirestoreService firestoreService =FirestoreService();
  final _controller = TextEditingController();

  //checkbox function
  void checkBoxChanged(bool? value, String docID, bool currentStatus) {
    setState(() {
      firestoreService.taskCheck(docID, !currentStatus);
    });
  }

  void saveEditTask(String docID){
    setState(() {
      firestoreService.updateTask(docID, _controller.text);
      _controller.clear();
    });
    Navigator.of(context).pop();
  }
  void editTask({String? docID, required String currentTask}){
    _controller.text = currentTask;
    showDialog(context: context, builder: (context){
       return DialogBox(
         controller:_controller,
         onSave: ()=>saveEditTask(docID!),
         onCancel: ()=> Navigator.of(context).pop(),
       );
    });
  }

  void saveNewTask(){
    setState(() {
        firestoreService.addTask(_controller.text);
      _controller.clear();
    });
    Navigator.of(context).pop();
  }
  void createNewTask(){
    showDialog(context: context, builder: (context){
      return DialogBox(
        controller:_controller,
        onSave: saveNewTask,
        onCancel: ()=> Navigator.of(context).pop(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(94, 173, 234, 1.0),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(6, 24, 83, 1.0),
        title: const Text('To Do App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Colors.white,
            fontFamily: 'Impact',
          ),),
        centerTitle: true,
        titleSpacing: 10,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        backgroundColor: const Color.fromRGBO(6, 24, 83, 1.0),
        child:const Icon(Icons.add,
        color: Colors.white,),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getTaskStream(),
        builder: (context, snapshot){
          if (snapshot.hasData){
            List toDoList = snapshot.data!.docs;
            return ListView.builder(
                itemCount: toDoList.length,
                itemBuilder: (context, index){
                  // get document and task from the doc
                  DocumentSnapshot doc =toDoList[index];
                  String docID =doc.id;
                  Map<String, dynamic> data= doc.data() as Map<String, dynamic>;
                  String taskText= data['task'];
                  bool checkBox = data['completed']?? false;

                  return ToDoTile(
                    taskName: taskText,
                    taskCompleted: checkBox,
                    onChanged: (value) => checkBoxChanged(value, docID, checkBox),
                    deleteFunction: (context) => firestoreService.deleteTask(docID),
                    onEdit: () => editTask(docID: docID, currentTask: taskText),
                  );
                }
            );
          }
          else{
            return const Text("No Task!");
          }
        },
      )
    );
  }
}
