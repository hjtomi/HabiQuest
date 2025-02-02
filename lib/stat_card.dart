import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:habiquest/auth.dart';
import 'package:habiquest/common.dart';

class StatCard extends StatefulWidget {
  const StatCard({
    super.key,
    required String? character,
  }) : _character = character;

  final String? _character;

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(Auth().currentUser!.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        var data = snapshot.data!.data() as Map<String, dynamic>;
        printMessage(data);

        return Card(
          color: Colors.grey[900],
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget._character != null
                  ? Image(
                      fit: BoxFit.contain,
                      width: 150,
                      height: 150,
                      image: AssetImage(
                          'lib/assets/skins/skin-${data['character']}.png'),
                    )
                  : const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.person, size: 100),
                    ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Level ${data['level']}",
                                ),
                              ],
                            ),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: data['xp'] / (sqrt(data['level']) * 100).round()),
                              duration: const Duration(milliseconds: 100),
                              builder: (context, ainmatedValue, child) {
                                return LinearProgressIndicator(
                                  minHeight: 6,
                                  value: ainmatedValue, // Must be between 0.0 and 1.0
                                  backgroundColor: Colors.black12,
                                  color: Colors.blue,
                                );
                              }
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Text('HP: ${data['health'].round()}', style: const TextStyle(color: Colors.green),),
                          ],
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Text('ATK: ${data['attack'].round()}', style: const TextStyle(color: Colors.red))
                          ],
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Text('DEF: ${data['defense'].round()}', style: const TextStyle(color: Colors.orangeAccent))
                          ],
                        )
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
