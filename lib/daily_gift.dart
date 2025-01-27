import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:habiquest/common.dart';
import 'package:time/time.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habiquest/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> checkDailygift(BuildContext context) async {
  if (true) {
    List<Item> itemData = await loadItems();

    QuerySnapshot data = await FirebaseFirestore.instance
      .collection("users")
      .doc(Auth().currentUser!.uid)
      .collection("dailies")
      .orderBy("date", descending: true)
      .get();

    DocumentSnapshot? data2 = await FirebaseFirestore.instance
      .collection('users')
      .doc(Auth().currentUser!.uid)
      .get();

    Map<String, dynamic> data2map = data2.data() as Map<String, dynamic>;

    if (data2map.containsKey('character')) {
      printMessage('daily: karakter van');
      if (context.mounted) {
        if (data.docs.isEmpty) {
          showDailyGifts(context, 1, itemData);
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
              showDailyGifts(context, dayCounter, itemData);
              return;
            } else if (napkulonbseg == dayCounter) {
              dayCounter++;
            }
          }
          showDailyGifts(context, dayCounter, itemData);
        }
      }
    } else {
      printMessage('daily: karakter nincs');
    } 
  }
}

Future<void> addResume(context) async {
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

Future<void> addLogin(context) async {
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

void showDailyGifts(BuildContext context, int level, List<Item> itemData) {
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
                  for (var i = 0; i < 30; i++)
                    DailyGift(
                      overlayEntry: overlayEntry,
                      level: itemData[i].level,
                      state: itemData[i].level < level
                        ? "previous"
                        : itemData[i].level == level
                          ? "today"
                          : "tomorrow",
                      type: itemData[i].type,
                      value: itemData[i].value,
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
    required this.state,
    required this.type,
    required this.value
  });

  final OverlayEntry overlayEntry;
  final int level;
  final String state; // previous, today, following
  final String type;
  final int value;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (state == "today") {
          addGift(type, value);
          FirebaseFirestore.instance
            .collection("users")
            .doc(Auth().currentUser!.uid)
            .collection("dailies")
            .add({
              "date": DateTime.now(),
            });
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
                type == "money" 
                  ? Icon(Icons.paid, color: Theme.of(context).colorScheme.tertiary,)
                  : const ImageIcon(
                    AssetImage("lib/assets/xp icon.png"),
                    color: Colors.lightBlue,
                    size: 20,
                  ),
                Text(value.toString()),
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

void addGift(String type, int amount) async {
  if (type == "money") {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(Auth().currentUser!.uid);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userDoc);
      if (!snapshot.exists) {
        printError("User document does not exist.");
        return;
      }

      final currentBalance = snapshot.data()?['balance'] as int? ?? 0;
      transaction.update(userDoc, {'balance': currentBalance + amount});
    });
  } else {
    // KARAKTERFEJLŐDÉSRE VÁR (XP szerzés)
  }
}

class Item {
  final int level;
  final String type;
  final int value;

  Item({
    required this.level,
    required this.type,
    required this.value,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      level: json["level"],
      type: json["type"],
      value: json["value"]
    );
  }
}

Future<List<Item>> loadItems() async {
  final String response = await rootBundle.loadString('lib/assets/dailyGifts.json');
  final List<dynamic> data = json.decode(response);
  return data.map((json) => Item.fromJson(json)).toList();
}