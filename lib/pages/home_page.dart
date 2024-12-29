import 'package:flutter/material.dart';
import 'package:habiquest/auth.dart';
import 'package:habiquest/pages/habit_page.dart';
import 'package:habiquest/pages/todo_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Tracks the selected index for the dashboard's bottom navigation bar
  int _dashboardSelectedIndex = 0;

  // Pages for the bottom navigation bar
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
              icon: Icon(Icons.toc),
              label: 'Habit',
            ),
            NavigationDestination(
              icon: Icon(Icons.check_circle),
              label: 'Todo',
            ),
          ],
          selectedIndex: _dashboardSelectedIndex,
          onDestinationSelected: _onDashboardItemTapped,
        ));
  }
}
