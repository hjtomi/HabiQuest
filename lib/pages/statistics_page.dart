import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habiquest/auth.dart';
import 'package:habiquest/common.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

Future<QuerySnapshot<Map<String, dynamic>>> getUserHabits() async {
  await Future.delayed(const Duration(seconds: 1)); // Delay execution
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
      .collection('users')
      .doc(Auth().currentUser!.uid)
      .collection('habits')
      .get();
  printMessage(snapshot.toString());
  return snapshot; // Return the Firestore result
}

Future<Map<String, dynamic>> fetchData() async {
  Future.delayed(const Duration(seconds: 1));
  DocumentReference userDoc = await FirebaseFirestore.instance.collection('users').doc(Auth().currentUser!.uid);
  var userData = await userDoc.get();
  var habits = await userDoc.collection('habits').get();
  var todos = await userDoc.collection('todos').orderBy('kesz').get();
  var dailies = await userDoc.collection('dailies').orderBy('date').get();
  var inventory = await userDoc.collection('inventory').orderBy('category').get();
  var logins = await userDoc.collection('logins').orderBy('date').get();
  var resumes = await userDoc.collection('resumes').orderBy('date').get();
  return {
    "userData": userData.data(),
    "habits": habits.docs.map((doc) => doc.data()).toList(),
    "todos": todos.docs.map((doc) => doc.data()).toList(),
    "dailies": dailies.docs.map((doc) => doc.data()).toList(),
    "inventory": inventory.docs.map((doc) => doc.data()).toList(),
    "logins": logins.docs.map((doc) => doc.data()).toList(),
    "resumes": resumes.docs.map((doc) => doc.data()).toList(),
  };
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<Widget> statisticsToShow = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          printMessage("Snapshot: ${snapshot.data}");

          statisticsToShow.add(
            HabitDifficulties(data: data['habits']),
          );

          return GridView.count(
            childAspectRatio: 0.7,
            crossAxisCount: 2,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            children: statisticsToShow,
          );
        } else if (snapshot.hasError) {
          // throw Exception(snapshot.error);
          return const Text('There was an error :O');
        } else {
          return Center(
            child: LoadingAnimationWidget.dotsTriangle(
              color: Colors.amber, size: 50
            )
          );
        }
      },
    ));
  }
}

class HabitDifficulties extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  HabitDifficulties({super.key, required this.data});

  final double totalRadius = 80;
  final Color randomColor = Color.fromRGBO(
    Random().nextInt(255), Random().nextInt(255), Random().nextInt(255), 1);

  @override
  Widget build(BuildContext context) {
    List<int> difficulties = [0, 0, 0, 0];
    for (int i = 0; i < data.length; i++) {
      difficulties[data[i]['nehezseg'].round()]++;
    }
    int d1 = difficulties[0];
    int d2 = difficulties[1];
    int d3 = difficulties[2];
    int d4 = difficulties[3];

    return Column(children: [
      const Padding(
        padding: EdgeInsets.only(
          left: 8,
          top: 8,
          right: 8,
        ),
        child: Text(
          'Szokások száma nehézség szerint',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, shadows: [
            Shadow(
              color: Colors.black,
              offset: Offset(2.5, 2.5),
            ),
          ]),
        ),
      ),
      d1 + d2 + d3 + d4 > 0
          ? Expanded(
              child: PieChart(PieChartData(
                sections: [
                  PieChartSectionData(
                    value: d1.toDouble(),
                    color: Colors.green,
                    radius: totalRadius * 0.75,
                    title: d1.toString(),
                  ),
                  PieChartSectionData(
                    value: d2.toDouble(),
                    color: Colors.yellow,
                    radius: totalRadius * 0.75,
                    title: d2.toString(),
                    titleStyle: const TextStyle(color: Colors.black),
                  ),
                  PieChartSectionData(
                    value: d3.toDouble(),
                    color: Colors.orange,
                    radius: totalRadius * 0.75,
                    title: d3.toString(),
                  ),
                  PieChartSectionData(
                    value: d4.toDouble(),
                    color: Colors.red,
                    radius: totalRadius * 0.75,
                    title: d4.toString(),
                  ),
                ],
                centerSpaceRadius: totalRadius * 0.25,
              )),
            )
          : const Expanded(
              child: Center(
                child: Text(
                  'Add habit to show data',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            )
    ]);
  }
}
