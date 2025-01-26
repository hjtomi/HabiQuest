import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habiquest/utils/theme/AppColors.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  late String userId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    userId = user?.uid ?? 'anonymous';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('inventory')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('An error occurred while fetching data.'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No items in the inventory.'),
            );
          }

          // Fetching the inventory items
          final inventoryItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: inventoryItems.length,
            itemBuilder: (context, index) {
              final item = inventoryItems[index];
              final data = item.data() as Map<String, dynamic>;

              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.secondary,
                        width: 2), // Red border with 2px width
                    borderRadius: BorderRadius.circular(
                        12), // Rounded corners with 12px radius
                  ),
                  child: ListTile(
                    leading: Image(image: AssetImage(data['image'] ?? '')),
                    title: Text(
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      data['name'] ?? 'Unnamed Item',
                    ),
                    subtitle: Text(
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      data['description'] ?? 'No description available',
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
