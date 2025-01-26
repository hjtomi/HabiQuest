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
  const double hpadding = 20;
  const double vpadding = 35;

  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) {
      return SafeArea(
        child: Material(
          color: Colors.black54,
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: hpadding,
                  vertical: vpadding
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: Color.fromRGBO(51, 51, 51, 1),
                  ),
                ),
              ),
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: hpadding + 10,
                  vertical: vpadding + 10,
                ),
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  for (var i = 1; i < 31; i++)
                    DailyGift(
                      overlayEntry: overlayEntry,
                      level: i,
                      state: i < level ? "previous" : i == level ? "today" : "tomorrow"
                    )
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  overlay.insert(overlayEntry);
}

class DailyGift extends StatelessWidget {
  const DailyGift({
    super.key,
    required this.overlayEntry,
    required this.level,
    required this.state
  });

  final OverlayEntry overlayEntry;
  final int level;
  final String state; // previous, today, following

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (state == "today") {
          overlayEntry.remove();
        }
      },
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(51, 51, 51, 1),
              border: Border.all(
                color: state == "previous"
                  ? Colors.grey
                  : state == "today"
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.grey,
                width: 5.0,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.paid, color: Theme.of(context).colorScheme.tertiary,),
                Text(level.toString()),
              ]
            )
          ),
          if (state == "previous")
            // Cross overlay
            Positioned.fill(
              child: CustomPaint(
                painter: CrossPainter(),
              ),
            ),
          if (state == "previous")
            const Material(
              color: Colors.black54,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
        ]
      ),
    );
  }
}

class CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 5;

    // Draw the two diagonal lines
    canvas.drawLine(Offset(3, 3), Offset(size.width - 3, size.height - 3), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}