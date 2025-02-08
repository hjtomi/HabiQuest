import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:habiquest/utils/calculateHabitMoney.dart';
import 'package:habiquest/utils/theme/AppTheme.dart';

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
      'completions': []
    });
  } catch (e) {
    print('Error adding or updating form data in Firestore: $e');
  }
}

Future<void> firestoreCompleteHabit(
    {required String habitId,
    required bool updatedState,
    required int difficulty}) async {
  User? user = FirebaseAuth.instance.currentUser;

  String userId = user?.uid ?? 'anonymous';

  if (updatedState) {
    CalculateHabitCompletetionReward(difficulty: difficulty);
  }

  try {
    CollectionReference collection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('habits');

    await collection.doc(habitId).update({
      'kesz': updatedState,
      if (updatedState) 'completions': FieldValue.arrayUnion([DateTime.now()])
    });
  } catch (e) {
    print('Error adding or updating form data in Firestore: $e');
  }
}
