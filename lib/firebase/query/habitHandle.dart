import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> firestoreAddHabit(Map<String, dynamic> formData) async {
  User? user = FirebaseAuth.instance.currentUser;

  try {
    CollectionReference collection = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('habits');

    await collection.add(formData);

    print('Form data added to Firestore successfully!');
  } catch (e) {
    print('Error adding form data to Firestore: $e');
  }
}
