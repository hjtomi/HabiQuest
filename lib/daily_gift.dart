import 'package:flutter/material.dart';
import 'package:habiquest/common.dart';
import 'package:time/time.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habiquest/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> checkDailygift(BuildContext context) async {
  QuerySnapshot data = await FirebaseFirestore.instance
    .collection("users")
    .doc(Auth().currentUser!.uid)
    .collection("dailies")
    .orderBy("date", descending: true)
    .get();
  
  if (context.mounted) {
    if (data.docs.isEmpty) {
      showDailyGifts(context, 1);
    } else {
      int dayCounter = 1;
      var today = DateTime.now().date;
      for (var element in data.docs) {
        Map<String, dynamic> data = element.data() as Map<String, dynamic>;
        DateTime date = data["date"].toDate() as DateTime;

        int napkulonbseg = DateTime(today.year, today.month, today.day)
          .difference(DateTime(date.year, date.month, date.day)).inDays;

        if (napkulonbseg == 0) {
          // Ma már volt ajándékátvéve
          return;
        } else if (napkulonbseg > dayCounter) {
          // Újrakezdődik az ajándékozás
          showDailyGifts(context, dayCounter);
          return;
        } else if (napkulonbseg == dayCounter) {
          dayCounter++;
        }
      }
      showDailyGifts(context, dayCounter);
    }
  }
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

void showDailyGifts(BuildContext context, int level) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) {
      return Material(
        color: Colors.black54,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 200
              ),
              child: Container(
                color: Colors.grey,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Prize day: $level"),
                ElevatedButton(
                  onPressed: () {
                    overlayEntry.remove();
                  },
                  child: Text("Okay"),
                )
              ],
            ),
            // Block all interactions with a gesture detector
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  FirebaseFirestore.instance
                  .collection("users")
                  .doc(Auth().currentUser!.uid)
                  .collection("dailies")
                  .add({
                    "date": DateTime.now(),
                  });
                  overlayEntry.remove();
                }, // Prevent interaction with background
              ),
            ),
          ],
        ),
      );
    },
  );

  overlay.insert(overlayEntry);
}