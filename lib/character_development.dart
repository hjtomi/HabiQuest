import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:habiquest/auth.dart';
import 'package:habiquest/common.dart';
import 'package:habiquest/utils/theme/AppTheme.dart';

Future<void> addXP(int value) async {
    var data = await FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().currentUser!.uid)
        .get();

    int beforeXP = data.data()!['xp'];
    printMessage('xp level before adding: $beforeXP');
    int afterXP = beforeXP + value;
    int level = data.data()!['level'];

    await handleLevelUp(level, afterXP, 0);

    Fluttertoast.showToast(
        msg: "+$value XP",
        toastLength: Toast.LENGTH_SHORT,
        textColor: AppTheme.darkTheme.colorScheme.tertiary,
        fontSize: 20,
        backgroundColor: AppTheme.darkTheme.colorScheme.secondary,
    );
}

Future<void> handleLevelUp(currentLevel, afterXP, levelUpAmount) async {
    // Level up amount gets incremented when the function recursively calls itselfs
    int neededXP = (sqrt(currentLevel) * 100).round();
    if (afterXP >= neededXP) {
        int overflowXP = afterXP - neededXP;
        return handleLevelUp(currentLevel + 1, overflowXP, levelUpAmount + 1);
    } else {
      await FirebaseFirestore.instance
      .collection('users')
      .doc(Auth().currentUser!.uid)
      .update({
        'xp': afterXP,
        'level': currentLevel,
      });

      addHealth(20 * levelUpAmount);
      addAttack(5 * levelUpAmount);
      addDefense(2 * levelUpAmount);
    }
}

Future<void> addHealth(amount) async {
  printMessage('in function');
  var userDoc = await FirebaseFirestore.instance
    .collection('users')
    .doc(Auth().currentUser!.uid)
    .get();

  Map<String, dynamic> userData = userDoc.data()!;

  int in500 = ((userData['health'] + 1) / 500).ceil();
  int newIn500 = ((userData['health'] + amount + 1) / 500).ceil();

  if (newIn500 > in500) {
    addXP((newIn500 - in500) * 50);
  }

  await FirebaseFirestore.instance
  .collection('users')
  .doc(Auth().currentUser!.uid)
  .update({
    'health': FieldValue.increment(amount),
  });
}

Future<void> addAttack(amount) async {
  printMessage('in function');
  var userDoc = await FirebaseFirestore.instance
    .collection('users')
    .doc(Auth().currentUser!.uid)
    .get();

  Map<String, dynamic> userData = userDoc.data()!;

  int in500 = ((userData['attack'] + 1) / 100).ceil();
  int newIn500 = ((userData['attack'] + amount + 1) / 100).ceil();

  if (newIn500 > in500) {
    addXP((newIn500 - in500) * 50);
  }

  await FirebaseFirestore.instance
  .collection('users')
  .doc(Auth().currentUser!.uid)
  .update({
    'attack': FieldValue.increment(amount),
  });
}

Future<void> addDefense(amount) async {
  printMessage('in function');
  var userDoc = await FirebaseFirestore.instance
    .collection('users')
    .doc(Auth().currentUser!.uid)
    .get();

  Map<String, dynamic> userData = userDoc.data()!;

  int in500 = ((userData['defense'] + 1) / 50).ceil();
  int newIn500 = ((userData['defense'] + amount + 1) / 50).ceil();

  if (newIn500 > in500) {
    addXP((newIn500 - in500) * 50);
  }

  await FirebaseFirestore.instance
  .collection('users')
  .doc(Auth().currentUser!.uid)
  .update({
    'defense': FieldValue.increment(amount),
  });
}