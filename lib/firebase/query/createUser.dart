import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addUser(String name, String email, int age) {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  return users
      .add({
        'name': name,
        'email': email,
        'age': age,
      })
      .then((value) => print("User added successfully!"))
      .catchError((error) => print("Failed to add user: $error"));
}
