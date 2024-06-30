import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {

  final CollectionReference tasks=
      FirebaseFirestore.instance.collection('tasks');

  Future<void> addTask(String task) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('tasks').add({
        'task': task,
        'completed': false,
      });
    }
  }

  Future<void> taskCheck(String docID, bool isCompleted) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('tasks').doc(docID).update({
        'completed': isCompleted,
      });
    }
  }

  Stream<QuerySnapshot> getTaskStream(){
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance.collection('users').doc(user.uid).collection('tasks').snapshots();
    } else {
      throw Exception("User not logged in");
    }
  }

  Future<void> updateTask(String docID, String newTask) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('tasks').doc(docID).update({
        'task': newTask,
      });
  }
  }

  Future<void> deleteTask(String docID) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('tasks').doc(docID).delete();
    }
  }

}