import 'package:habiquest/common.dart';
import 'package:habiquest/daily_gift.dart';
import 'package:habiquest/drawer_page.dart';
import 'package:habiquest/pages/statistics_page.dart';
import 'package:habiquest/skin.dart';
import 'auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
          printMessage("LOGIN");
          addLogin(context);
          addResume(context);

          getSecondsInApp();
          countSecondsInApp();

          Future.delayed(const Duration(seconds: 2), () {
            checkDailygift(context);
          });
          
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
                  return const HoldingPage();
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
