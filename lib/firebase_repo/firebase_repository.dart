import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:todo_app/models/todo_model.dart';

class FirebaseRepository {
  static FirebaseFirestore mFireStore = FirebaseFirestore.instance;
  static String collectionToDo = "todos";

  // add todo
  static void addTodo(TodoModel todo){
    mFireStore
        .collection(collectionToDo)
        .add(todo.toDoc())
        .then((value) {
      mFireStore
          .collection(collectionToDo)
          .doc(value.id)
          .update({"todoId": value.id});
    })
        .onError((error, stackTrace) {});
  }

  // fetch all todo
  static Stream<QuerySnapshot<Map<String, dynamic>>> fetchAllTodo(){
    return mFireStore.collection(collectionToDo).snapshots();
  }

  // update todo
  static void markTodoStatus(String todoId, bool status){

    var completedAt = "";
    if(status){
      completedAt = DateTime.now().millisecondsSinceEpoch.toString();
    }

    mFireStore
        .collection(collectionToDo)
        .doc(todoId)
        .update(
        {
          "isCompleted" : status,
          "completedAt" : completedAt
        }
    );
  }

}