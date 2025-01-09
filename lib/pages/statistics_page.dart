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
  await Future.delayed(const Duration(seconds: 3)); // Delay execution
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
      .collection('users')
      .doc(Auth().currentUser!.uid)
      .collection('habits')
      .get();
  printMessage(snapshot.toString());
  return snapshot; // Return the Firestore result
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<Widget> statisticsToShow = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: FutureBuilder(
        future: getUserHabits(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final documents = snapshot.data!.docs; // List of documents in the QuerySnapshot
            List<int> difficulties = [0, 0, 0, 0];
            for (int i = 0; i < documents.length; i++) {
              difficulties[documents[i]['nehezseg'].round()]++;
            }
            statisticsToShow.add(
              HabitDifficulties(
                difficulties[0],
                difficulties[1],
                difficulties[2],
                difficulties[3]
              )
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
            return Center(child: LoadingAnimationWidget.dotsTriangle(color: Colors.amber, size: 50));
          }
        },
      )
    );
  }
}

class HabitDifficulties extends StatelessWidget {
  final int d1;
  final int d2;
  final int d3;
  final int d4;

  HabitDifficulties(
    this.d1,
    this.d2,
    this.d3,
    this.d4, {
      super.key
    });

  final double totalRadius = 80;
  final Color randomColor = Color.fromRGBO(Random().nextInt(255), Random().nextInt(255), Random().nextInt(255), 1);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(
            left: 8,
            top: 8,
            right: 8,
          ),
          child: Text(
            'Szokások száma nehézség szerint',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(2.5, 2.5),
                ),
              ]
            ),
          ),
        ),
        d1+d2+d3+d4 > 0 ?
        Expanded(
          child: PieChart(
            PieChartData(
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
            )
          ),
        ) : 
        const Expanded(
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
      ]
    );
  }
}