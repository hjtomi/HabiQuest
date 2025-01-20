import 'package:flutter/material.dart';
import 'package:time/time.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habiquest/auth.dart';

void checkDailygift() {
    DateTime now = DateTime.now();
    FirebaseFirestore.instance.collection("users").doc(currentUser!.uid).collection("activity");
}

void addResume() {
    var collection = FirebaseFirestore.instance.collection("users").doc(currentUser!.uid).collection("activity");
    
}

void addLogin() {

}