import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> firestoreAddOrUpdateHabit(Map<String, dynamic> formData) async {
  User? user = FirebaseAuth.instance.currentUser;

  String userId = user?.uid ?? 'anonymous';
  try {
    CollectionReference collection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('habits');

    await collection.add({
      'cim': formData['cim'],
      'megjegyzes': formData['megjegyzes'],
      'nehezseg': formData['nehezseg'],
      'gyakorisag': formData['gyakorisag'],
      'ismetles': formData['ismetles'],
      'kezdes': formData['kezdes'],
      'kesz': formData['kesz'],
      'streak': formData['streak'],
    });
  } catch (e) {
    print('Error adding or updating form data in Firestore: $e');
  }
}

Future<void> firestoreCompleteHabit(
    {required String habitId, required bool updatedState}) async {
  User? user = FirebaseAuth.instance.currentUser;

  String userId = user?.uid ?? 'anonymous';
  try {
    CollectionReference collection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('habits');

    await collection.doc(habitId).update({'kesz': updatedState});
  } catch (e) {
    print('Error adding or updating form data in Firestore: $e');
  }
}
