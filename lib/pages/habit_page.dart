import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habiquest/components/HabitCard.dart';
import 'package:habiquest/pages/habit-todo/habit-add.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HabitPage extends StatefulWidget {
  const HabitPage({super.key});

  @override
  _HabitPageState createState() => _HabitPageState();
}

class _HabitPageState extends State<HabitPage> {
  final List<Map<String, dynamic>> _teendok = [];

  User? user = FirebaseAuth.instance.currentUser;

  void _hozzaadTeendo(
      String cim, String megjegyzes, int nehezseg, DateTime hatarido) {
    setState(() {
      _teendok.add({
        'cim': cim,
        'megjegyzes': megjegyzes,
        'nehezseg': nehezseg,
        'hatarido': hatarido,
        'kesz': false,
      });
    });
  }

  void _szerkesztTeendo(int index, String cim, String megjegyzes, int nehezseg,
      DateTime hatarido) {
    setState(() {
      _teendok[index] = {
        'cim': cim,
        'megjegyzes': megjegyzes,
        'nehezseg': nehezseg,
        'hatarido': hatarido,
        'kesz': false,
      };
    });
  }

  void _kijelolKeszre(int index) {
    setState(() {
      _teendok.removeAt(index);
    });
  }

  Color _nehezsegSzin(int nehezseg) {
    switch (nehezseg) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
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

          // Extract data from snapshot
          final habits = snapshot.data!.docs;

          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habitData = habits[index].data() as Map<String, dynamic>;
              final habitTitle = habitData['cim'] ?? 'Untitled';
              final frequency = habitData['gyakorisag'] ?? 'Unknown';
              final notes = habitData['megjegyzes'] ?? 'No notes';
              final difficulty = habitData['nehezseg']?.toString() ?? 'Unknown';

              return HabitTile(title: habitTitle);
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
              builder: (context) => HabitAdd(
                hozzaadTeendo: _hozzaadTeendo,
              ),
            ),
          );
        },
      ),
    );
  }
}
