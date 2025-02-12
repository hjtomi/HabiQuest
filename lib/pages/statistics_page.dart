import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habiquest/auth.dart';
import 'package:habiquest/common.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:async';
import 'package:time/time.dart';


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
                    MoneyChange(userData: data['userData'])
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
  final Map<String, dynamic> userData;

  const MoneyChange({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final List<Timestamp> dates = [];
    List<int> values = [];
    for(int i = 0; i < userData['moneyChange'].length; i++) {
      if (i % 2 == 0) { // Date
        if (i == 0) {
          dates.add(userData['moneyChange'][i]);
        } else if (dates[dates.length-1].toDate().isAtSameDayAs(userData['moneyChange'][i].toDate())) {
          dates.removeLast();
          values.removeLast();
          dates.add(userData['moneyChange'][i]);
        } else {
          dates.add(userData['moneyChange'][i]);
        }
      } else if (i % 2 == 1) { // Value
        values.add(userData['moneyChange'][i]);
      }
    }

    final List<FlSpot> spots = [];
    for(int i = 0; i < dates.length; i++) {
      //spots.add(FlSpot(dates[i].toDate().day.toDouble(), values[i].toDouble()));
      spots.add(FlSpot(dates[i].toDate().millisecondsSinceEpoch.toDouble(), values[i].toDouble()));
    }

    return Column(
      children: [
        const ChartTop(text: "Pénz összegének változása\nnaponta"),
        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          height: 300,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: (values.reduce(max).toDouble() ~/ 100) * 100 + 100,
              lineBarsData: [
                LineChartBarData(
                  barWidth: 4,
                  isCurved: false,
                  isStepLineChart: true,
                  lineChartStepData: const LineChartStepData(stepDirection: 0),
                  dotData: const FlDotData(
                    show: false
                  ),
                  spots: spots,
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
                  axisNameWidget: SizedBox(height: 20),
                  sideTitles: SideTitles(
                    showTitles: false,
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

  text = Text("${DateTime.fromMillisecondsSinceEpoch(value.round()).day}");

  return SideTitleWidget(
    meta: meta,
    child: text,
  );
}
