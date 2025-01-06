import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> firestoreAddOrUpdateHabit(String habitId, Map<String, dynamic> formData) async {
  User? user = FirebaseAuth.instance.currentUser;

  String userId = user?.uid ?? 'anonymous';
  try {
    CollectionReference collection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('habits');

    if (habitId.isEmpty) {
      await collection.add(formData);
      print('Form data added to Firestore successfully!');
    } else {
      await collection.doc(habitId).update(formData);
      print('Form data updated in Firestore successfully!');
    }
  } catch (e) {
    print('Error adding or updating form data in Firestore: $e');
  }
}