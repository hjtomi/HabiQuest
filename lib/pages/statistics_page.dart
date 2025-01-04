import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:habiquest/auth.dart';
import 'package:habiquest/common.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}
/*
Future<QuerySnapshot<Map<String, dynamic>>> getUserHabits() async {
  await Future.delayed(const Duration(seconds: 2), () {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    printMessage(firestore.collection('users').doc(Auth().currentUser!.uid).collection('habits').get().toString());
    return firestore.collection('users').doc(Auth().currentUser!.uid).collection('habits').get();
  });
  throw Exception('No data');
}*/

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

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Statisztikák'),
      ),
      body: FutureBuilder(
        future: getUserHabits(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final documents = snapshot.data!.docs; // List of documents in the QuerySnapshot
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final data = documents[index].data(); // Extract document data as a Map
                return ListTile(
                  title: Text(data['cim'] ?? 'No Name'), // Example field access
                  subtitle: Text(data['nehezseg'].toString()), // Example field access
                );
              },
            );
          } else if (snapshot.hasError) {
            // throw Exception(snapshot.error);
            return const Text('There was an error :O');
          } else {
            return const Text('No data yet');
          }
        },
      )
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habiquest/auth.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  Future<QuerySnapshot<Map<String, dynamic>>> getUserHabits() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    return await firestore
        .collection('users')
        .doc(Auth().currentUser!.uid)
        .collection('habits')
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statisztikák'),
      ),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: getUserHabits(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            // Process data to count habits by difficulty
            final documents = snapshot.data!.docs;
            List<int> difficultyCounts = [0, 0, 0, 0];

            for (var doc in documents) {
              final data = doc.data();
              if (data.containsKey('nehezseg')) {
                final int difficultyValue = data['nehezseg'];
                if (difficultyValue >= 0 && difficultyValue <= 3) {
                  difficultyCounts[difficultyValue]++;
                }
              }
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: BarChart(
                BarChartData(
                  barGroups: difficultyCounts
                      .asMap()
                      .entries
                      .map((entry) => BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.toDouble(),
                                color: Colors.blue,
                                width: 16,
                              ),
                            ],
                          ))
                      .toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Easy');
                            case 1:
                              return const Text('Medium');
                            case 2:
                              return const Text('Hard');
                            case 3:
                              return const Text('Extreme');
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                ),
              ),
            );
          }
          return const Center(child: Text('No habits found.'));
        },
      ),
    );
  }
}
*/