import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> firestoreAddTodo(Map<String, dynamic> formData) async {
  User? user = FirebaseAuth.instance.currentUser;

  String userId = user?.uid ?? 'anonymous';
  try {
    CollectionReference collection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('todos');

    await collection.add(formData);

    print('Todo data added to Firestore successfully!');
  } catch (e) {
    print('Error adding todo data to Firestore: $e');
  }
}

Future<void> firestoreUpdateTodo(String todoId, Map<String, dynamic> formData) async {
  User? user = FirebaseAuth.instance.currentUser;

  String userId = user?.uid ?? 'anonymous';
  try {
    DocumentReference document = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('todos')
        .doc(todoId);

    await document.update(formData);

    print('Todo data updated in Firestore successfully!');
  } catch (e) {
    print('Error updating todo data in Firestore: $e');
  }
}