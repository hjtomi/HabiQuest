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
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(Auth().currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        var data = snapshot.data!.data() ?? {};

        // Ensure all numerical values have defaults
        int level = (data['level'] ?? 1) as int;
        int xp = (data['xp'] ?? 0) as int;
        int health = (data['health'] ?? 100) as int;
        int attack = (data['attack'] ?? 10) as int;
        int defense = (data['defense'] ?? 5) as int;

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
                          'lib/assets/skins/skin-${data['character'] ?? 'default'}.png'),
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
                                  "Level $level",
                                ),
                              ],
                            ),
                            TweenAnimationBuilder<double>(
                              tween: Tween(
                                  begin: 0.0,
                                  end: xp / (sqrt(level) * 100).round()),
                              duration: const Duration(milliseconds: 100),
                              builder: (context, animatedValue, child) {
                                return LinearProgressIndicator(
                                  minHeight: 6,
                                  value:
                                      animatedValue, // Must be between 0.0 and 1.0
                                  backgroundColor: Colors.black12,
                                  color: Colors.blue,
                                );
                              },
                            ),
                            Text(
                              '$xp / ${(sqrt(level) * 100).round()}',
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 8),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.green),
                                children: [
                                  TextSpan(text: 'Életerő: ${health.round()}'),
                                  TextSpan(
                                    text:
                                        '   /   ${((health + 1) / 500).ceil() * 500}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.red),
                                children: [
                                  TextSpan(text: 'Támadás: ${attack.round()}'),
                                  TextSpan(
                                    text:
                                        '   /   ${((attack + 1) / 100).ceil() * 100}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                style:
                                    const TextStyle(color: Colors.orangeAccent),
                                children: [
                                  TextSpan(text: 'Védelem: ${defense.round()}'),
                                  TextSpan(
                                    text:
                                        '   /   ${((defense + 1) / 50).ceil() * 50}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
