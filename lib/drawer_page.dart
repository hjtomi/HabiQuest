import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habiquest/auth.dart';
import 'package:habiquest/pages/home_page.dart'; // Your Dashboard Page
import 'package:habiquest/pages/market_page.dart';

enum PageType { dashboard, market, statistics }

class HoldingPage extends StatefulWidget {
  const HoldingPage({super.key});

  @override
  State<HoldingPage> createState() => _HoldingPageState();
}

class _HoldingPageState extends State<HoldingPage> {
  PageType _selectedPage = PageType.market;

  // Map PageType to Widgets
  Widget _getPage(PageType page) {
    switch (page) {
      case PageType.dashboard:
        return const HomePage(); // Replace with your Dashboard page
      case PageType.market:
        return const MarketPage();
      default:
        return const Center(child: Text("Page not found"));
    }
  }

  // Map PageType to Titles
  String _getPageTitle(PageType page) {
    switch (page) {
      case PageType.dashboard:
        return "Dashboard";
      case PageType.market:
        return "Piactér";
      case PageType.statistics:
        return "Statisztikák";
      default:
        return "App";
    }
  }

  final User? user = Auth().currentUser;

  String? _username;
  String? _character;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _username = data['username'] as String?;
            _character = (data['character'] as int?)?.toString();
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle(_selectedPage)),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 32),
          children: [
            Card(
              color: Colors.grey[900],
              child: ListTile(
                contentPadding: const EdgeInsets.all(8),
                trailing: IconButton(
                    onPressed: () => Auth().signOut(),
                    icon: const Icon(Icons.logout_outlined)),
                leading: _character != null
                    ? Image(
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                        image:
                            AssetImage('lib/assets/skins/skin-$_character.png'),
                      )
                    : const Icon(Icons.person),
                title: Text(
                  _username ?? '',
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
            ListTile(
              onTap: () {
                setState(() {
                  _selectedPage = PageType.dashboard;
                });
                Navigator.pop(context); // Close the drawer
              },
              selected: _selectedPage == PageType.dashboard,
              selectedColor: Theme.of(context).colorScheme.secondary,
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
            ),
            ListTile(
              onTap: () {
                setState(() {
                  _selectedPage = PageType.market;
                });
                Navigator.pop(context);
              },
              selected: _selectedPage == PageType.market,
              selectedColor: Theme.of(context).colorScheme.secondary,
              leading: const Icon(Icons.storefront),
              title: const Text("Piactér"),
            ),
            ListTile(
              onTap: () {
                setState(() {
                  _selectedPage = PageType.statistics;
                });
                Navigator.pop(context);
              },
              selected: _selectedPage == PageType.statistics,
              selectedColor: Theme.of(context).colorScheme.secondary,
              leading: const Icon(Icons.insert_chart_outlined_rounded),
              title: const Text("Statistics"),
            ),
          ],
        ),
      ),
      body: _getPage(_selectedPage), // Load the selected page dynamically
    );
  }
}
