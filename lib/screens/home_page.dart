import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/firestore.dart';
import '../util/dialog_box.dart';
import '../util/todo_tile.dart';
import 'login.dart';

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

  void signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Login()),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(e.toString()),
          );
        },
      );
    }
  }

  String? userEmail = "";
  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }
  Future<void> _fetchUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(94, 173, 234, 1.0),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(6, 24, 83, 1.0),
          title: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'To Do App',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    fontFamily: 'Impact',
                  ),
                ),
                if (userEmail != null)
                  Text(
                    '| $userEmail |',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(163, 181, 181, 1.0),
                    ),
                  ),
              ],
            ),
          ),
          titleSpacing: 10,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => signOut(context),
              color: Colors.white,
            ),
          ],
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