import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habiquest/auth.dart';
import 'package:habiquest/pages/friends-page.dart';
import 'package:habiquest/pages/home_page.dart'; // Your Dashboard Page
import 'package:habiquest/pages/inventory_page.dart';
import 'package:habiquest/pages/market_page.dart';
import 'package:habiquest/pages/statistics_page.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:habiquest/stat_card.dart';

enum PageType { dashboard, market, statistics, inventory, friends }

class HoldingPage extends StatefulWidget {
  const HoldingPage({super.key});

  @override
  State<HoldingPage> createState() => _HoldingPageState();
}

class _HoldingPageState extends State<HoldingPage> {
  PageType _selectedPage = PageType.friends;

  // Map PageType to Widgets
  Widget _getPage(PageType page) {
    switch (page) {
      case PageType.dashboard:
        return const HomePage();
      case PageType.market:
        return const MarketPage();
      case PageType.statistics:
        return const StatisticsPage();
      case PageType.inventory:
        return const InventoryPage();
      case PageType.friends:
        return const FriendsPage();
    }
  }

  // Map PageType to Titles
  String _getPageTitle(PageType page) {
    switch (page) {
      case PageType.dashboard:
        return "HabiQuest";
      case PageType.market:
        return "Piactér";
      case PageType.statistics:
        return "Statisztikák";
      case PageType.inventory:
        return "Inventár";
      case PageType.friends:
        return "Barátok";
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

  Stream<int?> _userBalanceStream() {
    final userId = Auth().currentUser?.uid;
    if (userId == null) {
      return const Stream<int?>.empty();
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data()?['balance'] as int?);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle(_selectedPage)),
        actions: [
          StreamBuilder<int?>(
            stream: _userBalanceStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      color: Colors.white,
                    ),
                  ),
                );
              } else if (snapshot.hasError || !snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.paid,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      Text(
                        '${snapshot.data!}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
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
              leading: const Icon(LucideIcons.layoutDashboard),
              title: const Text("Főoldal"),
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
              leading: const Icon(LucideIcons.store),
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
              leading: const Icon(LucideIcons.areaChart),
              title: const Text("Statisztikák"),
            ),
            ListTile(
              onTap: () {
                setState(() {
                  _selectedPage = PageType.inventory;
                });
                Navigator.pop(context);
              },
              selected: _selectedPage == PageType.inventory,
              selectedColor: Theme.of(context).colorScheme.secondary,
              leading: const Icon(LucideIcons.backpack),
              title: const Text("Inventár"),
            ),
            ListTile(
              onTap: () {
                setState(() {
                  _selectedPage = PageType.friends;
                });
                Navigator.pop(context);
              },
              selected: _selectedPage == PageType.friends,
              selectedColor: Theme.of(context).colorScheme.secondary,
              leading: const Icon(LucideIcons.users),
              title: const Text("Barátok"),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: StatCard(character: _character),
          ),
          Expanded(
            child: _getPage(_selectedPage),
          ),
        ],
      ),
    );
  }
}
