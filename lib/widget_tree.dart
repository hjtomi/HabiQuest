import 'package:habiquest/skin.dart';
import 'auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:habiquest/pages/home_page.dart';
import 'package:habiquest/pages/login_page.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final user = snapshot.data;

          // Listen for real-time updates to the user's Firestore document
          return StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('users').doc(user!.uid).snapshots(),
            builder: (context, docSnapshot) {
              if (docSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (docSnapshot.hasData && docSnapshot.data!.exists) {
                final data = docSnapshot.data!.data()
                    as Map<String, dynamic>; //Itt megolom magam

                if (data.containsKey('character') &&
                    data['character'] != null) {
                  return const HomePage();
                } else {
                  return const CharacterSelector();
                }
              } else {
                return const CharacterSelector();
              }
            },
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
