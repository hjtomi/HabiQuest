import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:habiquest/utils/theme/AppColors.dart';
import 'package:habiquest/auth.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  final String currentUserId = Auth().currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  /// Search function for usernames
  Future<void> _searchUsers(String username) async {
    setState(() {
      _isLoading = true;
      _searchResults.clear();
    });

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      List<Map<String, dynamic>> users = querySnapshot.docs
          .where((doc) =>
              (doc.data()['username'] as String?)?.toLowerCase() ==
              username.toLowerCase())
          .map((doc) => {
                "id": doc.id,
                "username": doc.data()['username'],
              })
          .toList();

      setState(() {
        _searchResults = users;
      });
    } catch (e) {
      print("Error searching users: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  /// Add friend by storing only their user ID
  Future<void> _addFriend(String friendId) async {
    try {
      DocumentReference currentUserDoc =
          FirebaseFirestore.instance.collection('users').doc(currentUserId);

      await currentUserDoc
          .collection("friends")
          .doc(friendId)
          .set({"addedAt": FieldValue.serverTimestamp()});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "${_searchResults.firstWhere((user) => user['id'] == friendId)['username']} hozzáadva a barátokhoz!"),
        ),
      );
    } catch (e) {
      print("Error adding friend: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hiba történt a barát hozzáadásakor.")),
      );
    }
  }

  /// Fetch the list of added friends
  Stream<List<Map<String, dynamic>>> _getFriendsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> friends = [];
      for (var doc in snapshot.docs) {
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(doc.id)
            .get();
        friends.add({
          "id": doc.id,
          "username": userDoc.data()?['username'] ?? "Ismeretlen felhasználó",
          "character": userDoc.data()?['character'] ?? 0,
          "attack": userDoc.data()?['attack'] ?? 0,
          "defense": userDoc.data()?['defense'] ?? 0,
          "health": userDoc.data()?['health'] ?? 0,
          "xp": userDoc.data()?['xp'] ?? 0,
          "level": userDoc.data()?['level'] ?? 1,
        });
      }
      return friends;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Barátok"),
        bottom: TabBar(
          indicatorColor: AppColors.secondary,
          labelColor: AppColors.secondary,
          controller: _tabController,
          tabs: const [
            Tab(text: "Keresés"),
            Tab(text: "Barátok"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Keresés tab
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _searchUsers(value);
                    }
                  },
                  cursorColor: AppColors.white,
                  decoration: const InputDecoration(
                    labelStyle: TextStyle(color: AppColors.white),
                    labelText: "Keresés",
                  ),
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const CircularProgressIndicator()
                    : Expanded(
                        child: _searchResults.isEmpty
                            ? const Center(child: Text("Nincs találat"))
                            : ListView.builder(
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title:
                                        Text(_searchResults[index]['username']),
                                    trailing: ElevatedButton(
                                      onPressed: () {
                                        _addFriend(_searchResults[index]['id']);
                                      },
                                      child: const Text("Hozzáadás"),
                                    ),
                                  );
                                },
                              ),
                      ),
              ],
            ),
          ),

          // Barátok tab
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _getFriendsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Nincsenek barátaid."));
              }

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var friend = snapshot.data![index];

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.grey[900],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${friend["username"]}",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image(
                                  fit: BoxFit.contain,
                                  width: 150,
                                  height: 150,
                                  image: AssetImage(
                                      'lib/assets/skins/skin-${friend["character"]}.png'),
                                ), // Small space between image and text
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                          height:
                                              4), // Reduce space below username
                                      Text("Level ${friend["level"]}"),
                                      LinearProgressIndicator(
                                        minHeight: 6,
                                        value: friend["xp"] /
                                            (sqrt(friend["level"]) * 100)
                                                .round(),
                                        backgroundColor: Colors.black12,
                                        color: Colors.blue,
                                      ),
                                      Text(
                                        '${friend["xp"]} / ${(sqrt(friend["level"]) * 100).round()} XP',
                                        style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 8),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                          'Életerő: ${friend["health"].round()}',
                                          style: const TextStyle(
                                              color: Colors.green)),
                                      Text(
                                          'Támadás: ${friend["attack"].round()}',
                                          style: const TextStyle(
                                              color: Colors.red)),
                                      Text(
                                          'Védelem: ${friend["defense"].round()}',
                                          style: const TextStyle(
                                              color: Colors.orangeAccent)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
