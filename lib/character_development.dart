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

    await handleLevelUp(level, afterXP);

    Fluttertoast.showToast(
        msg: "+$value XP",
        toastLength: Toast.LENGTH_SHORT,
        textColor: AppTheme.darkTheme.colorScheme.tertiary,
        fontSize: 20,
        backgroundColor: AppTheme.darkTheme.colorScheme.secondary,
    );
}

Future<void> handleLevelUp(currentLevel, afterXP) async {
    int neededXP = (sqrt(currentLevel) * 100).round();
    if (afterXP >= neededXP) {
        int overflowXP = afterXP - neededXP;
        return handleLevelUp(currentLevel + 1, overflowXP);
    } else {
        await FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().currentUser!.uid)
        .update({
            'xp': afterXP,
            'level': currentLevel
        });
    }
}