import 'package:flutter/material.dart';
import 'package:habiquest/pages/habit-todo/habit-add.dart';
import 'package:habiquest/pages/habit-todo/habit-edit.dart';

class HabitPage extends StatefulWidget {
  const HabitPage({super.key});

  @override
  _HabitPageState createState() => _HabitPageState();
}

class _HabitPageState extends State<HabitPage> {
  final List<Map<String, dynamic>> _teendok = [];

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
      body: ListView.builder(
        itemCount: _teendok.length,
        itemBuilder: (context, index) {
          final teendo = _teendok[index];
          return Card(
            color: _nehezsegSzin(teendo['nehezseg']),
            child: ListTile(
              title: Text(
                teendo['cim'],
                style: const TextStyle(
                    color: Colors.black), // Fekete szín a címhez
              ),
              subtitle: Text(
                'Határidő: ${teendo['hatarido'].toLocal().toString().split(' ')[0]}',
                style: const TextStyle(
                    color: Colors.black), // Fekete szín a szöveghez
              ),
              trailing: Checkbox(
                value: teendo['kesz'],
                onChanged: (_) => _kijelolKeszre(index),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HabitEdit(
                      teendo: teendo,
                      index: index,
                      mentTeendo: _szerkesztTeendo,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, size: 38),
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
