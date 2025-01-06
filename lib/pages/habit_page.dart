import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habiquest/pages/habit-todo/habit-edit.dart';
import 'package:habiquest/components/HabitCard.dart';
import 'package:habiquest/pages/habit-todo/habit-add.dart';

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
            return const Center(child: Text('No habits found.'));
          }

          final habits = snapshot.data!.docs;

          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habitData = habits[index].data() as Map<String, dynamic>;
              final habitTitle = habitData['cim'] ?? 'Untitled';
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => HabitEdit(
                        teendo: habitData,
                        index: index,
                        mentTeendo: (index, cim, megjegyzes, nehezseg, gyakorisag, ismetles, kezdIdo, kesz, streak) {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(user?.uid ?? 'anonymous')
                              .collection('habits')
                              .doc(habits[index].id)
                              .update({
                            'cim': cim,
                            'megjegyzes': megjegyzes,
                            'nehezseg': nehezseg,
                            'gyakorisag': gyakorisag,
                            'ismetles': ismetles,
                            'kezdes': kezdIdo,
                            'kesz': kesz,
                            'streak': streak,
                          });
                        },
                      ),
                    ),
                  );
                },
                child: HabitTile(title: habitTitle),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        child: const Icon(Icons.add),
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