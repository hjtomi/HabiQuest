import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habiquest/auth.dart';
import 'package:habiquest/pages/habit_page.dart';
import 'package:habiquest/pages/todo_page.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _dashboardSelectedIndex = 0;

  static final List<Widget> _dashboardPages = <Widget>[
    const HabitPage(),
    const TodoPage(),
  ];

  static final List<String> _dashboardPagesNames = <String>[
    "Szokások",
    "Teendők",
  ];

  void _onDashboardItemTapped(int index) {
    setState(() {
      _dashboardSelectedIndex = index;
    });
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _dashboardPages[_dashboardSelectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        indicatorColor: Theme.of(context).colorScheme.secondary,
        backgroundColor: Colors.grey[900],
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(LucideIcons.listChecks),
            label: 'Habit',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.checkCircle2),
            label: 'Todo',
          ),
        ],
        selectedIndex: _dashboardSelectedIndex,
        onDestinationSelected: _onDashboardItemTapped,
      ),
    );
  }
}
