import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habiquest/auth.dart';
import 'package:habiquest/common.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:async';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';


bool timeFetched = false;
int timeSpent = 0;
Timer? _timer;
void countSecondsInApp() {
  _timer?.cancel(); // Cancel existing timer if any
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    timeSpent++;
  });
}

void stopCounting() {
  _timer?.cancel(); // Stop the timer when needed
}

void getSecondsInApp() async {
  var qs = await FirebaseFirestore.instance.collection('users').doc(Auth().currentUser!.uid).get();
  timeSpent = qs.data()!['secondsInApp'];
  timeFetched = true;
}

Future<QuerySnapshot<Map<String, dynamic>>> getUserHabits() async {
  await Future.delayed(const Duration(seconds: 1)); // Delay execution
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
      .collection('users')
      .doc(Auth().currentUser!.uid)
      .collection('habits')
      .get();

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

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<Widget> statisticsToShow = [];

  @override
  void initState() {
    updateEachSecond();
    super.initState();
  }

  void updateEachSecond() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    String hours = (timeSpent / 3600).floor().toString().padLeft(2, "0");
    String minutes = (timeSpent % 3600 / 60).floor().toString().padLeft(2, "0");
    String seconds = (timeSpent % 60).toString().padLeft(2, "0");

    return Scaffold(
      body: FutureBuilder(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    """Applikációban eltöltött idő: $hours:$minutes:$seconds""",
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    HabitDifficulties(habits: data['habits']),
                    HabitDifficulties(habits: data['habits']),
                  ]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MoneyChange()
                  ]
                )
              ],
            ),
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

class ChartTop extends StatelessWidget {
  final String text;

  const ChartTop({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 18, shadows: [
        Shadow(
          color: Colors.black,
          offset: Offset(2.5, 2.5),
        ),
      ]),
    );
  }
}

class HabitDifficulties extends StatelessWidget {
  final List<Map<String, dynamic>> habits;

  HabitDifficulties({super.key, required this.habits});

  final double totalRadius = 80;
  final Color randomColor = Color.fromRGBO(
    Random().nextInt(255), Random().nextInt(255), Random().nextInt(255), 1);

  @override
  Widget build(BuildContext context) {
    List<int> difficulties = [0, 0, 0, 0];
    for (int i = 0; i < habits.length; i++) {
      difficulties[habits[i]['nehezseg'].round()]++;
    }
    int d1 = difficulties[0];
    int d2 = difficulties[1];
    int d3 = difficulties[2];
    int d4 = difficulties[3];

    return Column(
      children: [
        const ChartTop(text: "Szokások száma\nnehézség szerint"),
        d1 + d2 + d3 + d4 > 0
            ? SizedBox(
              width: MediaQuery.sizeOf(context).width / 2,
              height: 200,
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
      ]
    );
  }
}

class MoneyChange extends StatelessWidget {
  const MoneyChange({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ChartTop(text: "Pénz összegének változása"),
        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          height: 300,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  barWidth: 4,
                  isCurved: true,
                  dotData: const FlDotData(
                    show: false
                  ),
                  spots: [
                    const FlSpot(0, 0),
                    const FlSpot(1, 10),
                    const FlSpot(2, 40),
                    const FlSpot(3, 5),
                    const FlSpot(4, 60),
                    const FlSpot(5, 0),
                    const FlSpot(6, 10),
                    const FlSpot(7, 40),
                    const FlSpot(8, 5),
                    const FlSpot(9, 60),
                    const FlSpot(10, 0),
                    const FlSpot(11, 10),
                    const FlSpot(12, 40),
                    const FlSpot(13, 5),
                    const FlSpot(14, 60),
                  ],
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color.fromARGB(58, 30, 202, 229)
                  ),
                  shadow: const Shadow(
                    color: Colors.black,
                    blurRadius: 4
                  ),
                  isStrokeCapRound: true,
                )
              ],
              lineTouchData: const LineTouchData(enabled: false),
              titlesData: const FlTitlesData(
                topTitles: AxisTitles(
                  axisNameWidget: SizedBox(height: 10),
                  sideTitles: SideTitles(
                    showTitles: false
                  )
                ),
                rightTitles: AxisTitles(
                  axisNameWidget: SizedBox(width: 15),
                  sideTitles: SideTitles(
                    showTitles: false
                  )
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: bottomTitleWidgets,
                  ),
                ),
              )
            )
          ),
        )
      ],
    );
  }
}

Widget bottomTitleWidgets(double value, TitleMeta meta) {
  const style = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );
  Widget text;
  switch (value.toInt()) {
    case 4:
      text = const Text('MAR', style: style);
      break;
    case 8:
      text = const Text('JUN', style: style);
      break;
    case 12:
      text = const Text('SEP', style: style);
      break;
    default:
      text = const Text('', style: style);
      break;
  }

  return SideTitleWidget(
    meta: meta,
    child: text,
  );
}
