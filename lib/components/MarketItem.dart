import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habiquest/auth.dart';
import 'package:habiquest/utils/MarketJSONConverter.dart';
import 'package:slide_to_act/slide_to_act.dart';

class MarketItem extends StatelessWidget {
  const MarketItem({
    super.key,
    required this.item,
  });

  Future<void> confirmPurchase(Item item, int amount) async {
    final String itemId = item.id.toString(); // Ensure item ID is a string
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print("User is not logged in.");
      return;
    }

    final DocumentReference userDoc =
        FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final DocumentSnapshot snapshot = await transaction.get(userDoc);

        if (!snapshot.exists) {
          print("User document does not exist.");
          return;
        }

        // Cast snapshot data to Map<String, dynamic>
        final data = snapshot.data() as Map<String, dynamic>;
        final int currentBalance =
            data['balance'] ?? 0; // Safely access 'balance'

        if (currentBalance < amount) {
          print("Insufficient balance.");
          return;
        }

        // Deduct the item's price from the user's balance
        transaction.update(userDoc, {'balance': currentBalance - amount});

        // Add the item to the user's inventory
        final CollectionReference inventoryCollection =
            userDoc.collection("inventory");

        transaction.set(
          inventoryCollection
              .doc(item.id.toString()), // Use item ID as document ID
          {
            'name': item.name,
            'description': item.description,
            'image': item.image,
            'price': item.price,
            'category': item.category,
            'quantity': 1, // You can customize this field as needed
          },
        );
      });

      switch(item.category) {
        case 'weapon':
          FirebaseFirestore.instance.collection('users').doc(userId).update({
            'attack': FieldValue.increment(item.price * 0.3)
          });
          break;
        case 'armor': 
          FirebaseFirestore.instance.collection('users').doc(userId).update({
            'defense': FieldValue.increment(item.price * 0.1)
          });
          break;
        case 'food':
          FirebaseFirestore.instance.collection('users').doc(userId).update({
            'health': FieldValue.increment(item.price)
          });
          break;
      }

      print("Purchase confirmed, and item added to inventory.");
    } catch (e) {
      print("Error during transaction: $e");
    } catch (e) {
      print("Error during transaction: $e");
    }
  }

  final Item item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled:
              true, // Allows the bottom sheet to resize dynamically
          builder: (BuildContext context) {
            return Padding(
              padding: EdgeInsets.only(
                top: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Wraps content height
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset(
                          item.image,
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(
                          thickness: 2,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      Text(
                        item.description,
                        style: const TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      SlideAction(
                        onSubmit: () {
                          Navigator.of(context).pop();
                          confirmPurchase(item, item.price);
                          return null;
                        },
                        outerColor: Theme.of(context).colorScheme.secondary,
                        text: item.price.toString(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
              color: Theme.of(context).colorScheme.secondary, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(
                item.image,
                width: 64,
                height: 64,
                fit: BoxFit.contain,
                cacheWidth: 200,
                cacheHeight: 200,
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.paid_rounded,
                      color: Theme.of(context).colorScheme.tertiary, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${item.price}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
