import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habiquest/auth.dart';
import 'package:habiquest/pages/habit_page.dart';
import 'package:habiquest/pages/login_page.dart';
import 'package:habiquest/pages/statistics_page.dart';
import 'package:habiquest/pages/todo_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;

  // State variables to hold username and character
  String? _username;
  String? _character; // Still String but converted from int

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch both username and character when the widget is initialized
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users') // Main collection
            .doc(user!.uid) // User's document by UID
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _username = data['username'] as String?;
            // Convert character int to String
            _character = (data['character'] as int?)?.toString();
          });
        } else {
          print('User document does not exist or is empty');
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HabitPage(),
    const TodoPage(),
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
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 32),
          children: [
            Flexible(
              child: Card(
                color: Colors.grey[900],
                child: ListTile(
                  contentPadding: EdgeInsets.all(8),
                  trailing: const Icon(Icons.logout_outlined),
                  leading: _character != null
                      ? Image(
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                          image: AssetImage(
                              'lib/assets/skins/skin-$_character.png'),
                        )
                      : const Icon(
                          Icons.person), // Fallback icon if character is null
                  title: Text(
                    "asjdlkjalskdjalksjdkjad" ?? '',
                    overflow: TextOverflow.fade,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.insert_chart_outlined_rounded),
              title: const Text('Statisztikák'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatisticsPage()),
                );
              }
            ),
            ListTile(
              leading: const Icon(Icons.storefront),
              title: const Text('Piactér'),
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
