import 'dart:math';
import 'package:flutter/material.dart';
import 'package:habiquest/auth.dart';
import 'package:habiquest/utils/theme/AppColors.dart';
import 'package:habiquest/skin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MonsterPage extends StatefulWidget {
  const MonsterPage({super.key});

  @override
  _MonsterPageState createState() => _MonsterPageState();
}

class _MonsterPageState extends State<MonsterPage> {
  int defeatedMonsters = 0;
  double monsterHealth = 1.0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadDefeatedMonsters();
  }

  Future<void> _loadDefeatedMonsters() async {
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user!.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          defeatedMonsters = userDoc['defeatedMonsters'] ?? 0;
        });
      }
    }
  }

  Future<void> _updateDefeatedMonsters() async {
    if (user != null) {
      await _firestore.collection('users').doc(user!.uid).update({
        'defeatedMonsters': defeatedMonsters,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final monsterImage = 'lib/assets/monsters/monster_${defeatedMonsters + 1}.png';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Szörnyek'),
        backgroundColor: AppColors.secondary,
      ),
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              monsterImage,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Image.asset(
              monsterImage,
              width: 80,
              height: 80,
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: LinearProgressIndicator(
              value: monsterHealth,
              backgroundColor: Colors.red[200],
              color: Colors.red,
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      monsterHealth -= 0.1;
                      if (monsterHealth <= 0) {
                        defeatedMonsters++;
                        monsterHealth = 1.0;
                        _updateDefeatedMonsters();
                      }
                    });
                  },
                  child: const Text('Támadás'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Védekezés'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Gyógyulás'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}