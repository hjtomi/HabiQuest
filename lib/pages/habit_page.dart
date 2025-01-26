import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gif/gif.dart';
import 'package:habiquest/components/HabitCard.dart';
import 'package:habiquest/pages/habit-todo/habit-add.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HabitPage extends StatefulWidget {
  const HabitPage({super.key});

  @override
  _HabitPageState createState() => _HabitPageState();
}

class _HabitPageState extends State<HabitPage> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid ?? 'anonymous')
            .collection('habits')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Gif(
                  width: 200,
                  height: 200,
                  autostart: Autostart.loop,
                  image: const AssetImage("lib/assets/knight_idle.gif"),
                ),
                Text(
                  'Még nem adtál hozzá szokást!',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontWeight: FontWeight.bold,
                      fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              ],
            ));
          }

          final habits = snapshot.data!.docs;

          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habitData = habits[index].data() as Map<String, dynamic>;
              final habitTitle = habitData['cim'] ?? 'Untitled';
              final habitId = habits[index].id;
              final habitState = habitData['kesz'];
              final habitDifficulty = habitData['nehezseg'];
              return HabitTile(
                title: habitTitle,
                id: habitId,
                state: habitState,
                difficulty: habitDifficulty,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        child: const Icon(LucideIcons.plus),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const HabitAdd(),
            ),
          );
        },
      ),
    );
  }
}
