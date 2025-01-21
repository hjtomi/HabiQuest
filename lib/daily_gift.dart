import 'package:flutter/material.dart';
import 'package:habiquest/common.dart';
import 'package:time/time.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habiquest/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

void checkDailygift() {
  DateTime now = DateTime.now();
  //FirebaseFirestore.instance.collection("users").doc(currentUser!.uid).collection("activity");
}

Future<void> addResume() async {
  User? user = Auth().currentUser;

  if (user != null) {
    DateTime now = DateTime.now();

    DocumentReference key = await FirebaseFirestore.instance
      .collection("users")
      .doc(user.uid)
      .collection("resumes")
      .add({
        "date": now,
      });
    printMessage("Resume added: $key");
  }
}

Future<void> addLogin() async {
  User? user = Auth().currentUser;

  if (user != null) {
    DateTime now = DateTime.now();

    DocumentReference key = await FirebaseFirestore.instance
      .collection("users")
      .doc(user.uid)
      .collection("logins")
      .add({
        "date": now,
      });
    printMessage("Login added: $key");
  }
}