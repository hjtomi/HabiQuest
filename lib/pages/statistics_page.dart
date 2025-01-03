import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habiquest/auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:habiquest/common.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

Future<List<Map<String, dynamic>>> fetchUserHabits() async {
  try {
    // Get the current user's UID
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No user is logged in.");
    }

    String uid = user.uid;

    // Reference to the habits sub-collection
    CollectionReference habitsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('habits');

    // Get the documents in the habits sub-collection
    QuerySnapshot querySnapshot = await habitsCollection.get();

    // Check if the sub-collection exists and contains data
    if (querySnapshot.docs.isNotEmpty) {
      // Map the documents into a list of maps
      return querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
    } else {
      printWarning("No habits found for the current user.");
      return [];
    }
  } catch (e) {
    printError("Error fetching habits: $e");
    return [];
  }
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  Widget build(BuildContext context) {
    
    fetchUserHabits().then((value) => {
      printMessage(value[0]['cim'])
    });

    Future<QuerySnapshot<Map<String, dynamic>>> fetchHabits() async {
      final String uid = Auth().currentUser!.uid;
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      return users.doc(uid).collection('habits').get();
    }
    

    return FutureBuilder(
      future: fetchHabits(), 
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('There was an error');
        } else if (snapshot.hasData) {
          return const Text('Data recieved');
        } else {
          return const Text('No data yet');
        }
      }
    );

    /*return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.amber,),
        title: const Text("Statisztikák"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 255.0),
        child: Container(
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  spots: [
                    FlSpot(0, 1),
                    FlSpot(1, 3),
                    FlSpot(2, 2),
                    FlSpot(3, 1.5),
                    FlSpot(4, 2.8),
                    FlSpot(5, 2.5),
                  ],
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: true),
          ),
              ),
        ),
      )
    );*/
  }
}