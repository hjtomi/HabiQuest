import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habiquest/auth.dart';
import 'package:habiquest/pages/habit_page.dart';
import 'package:habiquest/pages/todo_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;

  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HabitPage(),
    const TodoPage()
  ];
  static final List<String> _pageTitles = <String>["Szokások", "Teendők"];

  Future<void> signOut() async {
    await Auth().signOut();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: signOut,
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: _widgetOptions[_selectedIndex],
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
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
      ),
    );
  }
}
