import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:habiquest/auth.dart';
import 'dart:math';

void CalculateHabitCompletetionReward({required int difficulty}) async {
  int amount = 0;

  switch (difficulty) {
    case 0:
      amount = 10 + Random().nextInt(5 + 10) - 5;
      break;
    case 1:
      amount = 20 + Random().nextInt(5 + 10) - 5;
      break;
    case 2:
      amount = 30 + Random().nextInt(5 + 10) - 5;
      break;
  }

  final userId = Auth().currentUser?.uid;
  if (userId == null) {
    print("User is not logged in.");
    return;
  }

  final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

  await FirebaseFirestore.instance.runTransaction((transaction) async {
    final snapshot = await transaction.get(userDoc);
    if (!snapshot.exists) {
      print("User document does not exist.");
      return;
    }

    final currentBalance = snapshot.data()?['balance'] as int? ?? 0;
    transaction.update(userDoc, {'balance': currentBalance + amount});
  });
}
