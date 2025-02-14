import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habiquest/auth.dart';
import 'package:habiquest/common.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:async';
import 'package:intl/intl.dart';


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
                    StatRatio(
                      health: data['userData']['health'].round(),
                      attack: data['userData']['attack'].round(),
                      defense: data['userData']['defense'].round(),
                    )
                  ]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MoneyChange(userData: data['userData'])
                  ]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ItemCategories(inventory: data['inventory'])
                  ]
                ),
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

class StatRatio extends StatelessWidget {
  final int health;
  final int attack;
  final int defense;

  const StatRatio({super.key, required this.health, required this.attack, required this.defense});

  @override
  Widget build(BuildContext context) {
    double healthRatio = health / 100;
    double attackRatio = attack / 25;
    double defenseRatio = defense / 10;
    double maxRatioValue = [healthRatio, attackRatio, defenseRatio].reduce(max) * 1.4;
    return Column(
      children: [
        const ChartTop(text: "Karaktered\nerősségei"),
        Center(
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width / 2,
            height: 200,
            child: RadarChart(
              RadarChartData(
                dataSets: [
                  RadarDataSet(
                    dataEntries: [
                      RadarEntry(value: health / 100),
                      RadarEntry(value: attack / 25),
                      RadarEntry(value: defense / 10),
                    ],
                    fillColor: Colors.red.withAlpha(100),
                    borderColor: Colors.red.withAlpha(220),
                    borderWidth: 3,
                    entryRadius: 0.0,
                  ),
                  RadarDataSet(
                    dataEntries: [
                      const RadarEntry(value: 1),
                      const RadarEntry(value: 1),
                      const RadarEntry(value: 1),
                    ],
                    fillColor: Colors.transparent,
                    borderColor: Colors.transparent,
                    borderWidth: 0,
                    entryRadius: 0.0,
                  ),
                  RadarDataSet(
                    dataEntries: [
                      RadarEntry(value: maxRatioValue),
                      RadarEntry(value: maxRatioValue),
                      RadarEntry(value: maxRatioValue),
                    ],
                    fillColor: Colors.transparent,
                    borderColor: Colors.transparent,
                    borderWidth: 0,
                    entryRadius: 0.0,
                  ),
                ],
                radarBackgroundColor: Colors.grey.withAlpha(100),
                radarShape: RadarShape.polygon,
                radarBorderData: const BorderSide(
                  color: Colors.black,
                  width: 3,
                ),
                getTitle: (index, angle) {
                  switch (index) {
                    case 0:
                      return RadarChartTitle(text: 'Életerő', angle: angle, positionPercentageOffset: 0.05);
                    case 2:
                      return const RadarChartTitle(text: '            Védekezés', positionPercentageOffset: 0.2);
                    case 1:
                      return const RadarChartTitle(text: 'Támadás                 -', positionPercentageOffset: 0.2);
                    default:
                      return const RadarChartTitle(text: '');
                  }
                },
                titleTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
                titlePositionPercentageOffset: 0.7,
                tickCount: 4,
                ticksTextStyle: const TextStyle(
                  color: Colors.transparent
                ),
                tickBorderData: BorderSide(
                  color: Colors.black.withAlpha(200)
                ),
                gridBorderData: BorderSide(
                  color: Colors.black.withAlpha(150)
                ),
              )
            ),
          ),
        )
      ],
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
    List<int> difficulties = [0, 0, 0];
    for (int i = 0; i < habits.length; i++) {
      difficulties[habits[i]['nehezseg'].round()]++;
    }
    int d1 = difficulties[0];
    int d2 = difficulties[1];
    int d3 = difficulties[2];

    return Column(
      children: [
        const ChartTop(text: "Szokások száma\nnehézség szerint"),
        d1 + d2 + d3 > 0
            ? SizedBox(
              width: MediaQuery.sizeOf(context).width / 2,
              height: 200,
              child: PieChart(PieChartData(
                sections: [
                  PieChartSectionData(
                    value: d1.toDouble(),
                    color: Colors.yellow,
                    radius: totalRadius * 0.75,
                    title: d1.toString(),
                    titleStyle: const TextStyle(color: Colors.black),
                  ),
                  PieChartSectionData(
                    value: d2.toDouble(),
                    color: Colors.orange,
                    radius: totalRadius * 0.75,
                    title: d2.toString(),
                    titleStyle: const TextStyle(color: Colors.black),
                  ),
                  PieChartSectionData(
                    value: d3.toDouble(),
                    color: Colors.red,
                    radius: totalRadius * 0.75,
                    title: d3.toString(),
                    titleStyle: const TextStyle(color: Colors.black),
                  ),
                ],
                centerSpaceRadius: totalRadius * 0.25,
              )),
            )
            : SizedBox(
              width: MediaQuery.sizeOf(context).width / 2,
              height: 200,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: 60,
                ),
                child: Card(
                  color: Colors.yellow.shade800,
                  child: const Center(
                    child: Text(
                      "!!!\nAdj hozzá szokást\n!!!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                      )
                    )
                  ),
                ),
              ),
            )
      ]
    );
  }
}

Duration firstLastDifference = const Duration(seconds: 1);
class MoneyChange extends StatelessWidget {
  final Map<String, dynamic> userData;

  const MoneyChange({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {

    List<FlSpot> flspots = [];
    if (userData.containsKey("moneyChange")) {
      final List<(DateTime, int)> spots = [];
      DateTime temp = DateTime(2000);
      for(int i = 0; i < userData['moneyChange'].length; i++) {
        if (i % 2 == 0) { // Date
          temp = userData['moneyChange'][i].toDate();
        } else if (i % 2 == 1) { // Value
          spots.add((temp, userData['moneyChange'][i]));
        }
      }

      firstLastDifference = spots[spots.length - 1].$1.difference(spots[0].$1);

      for(int i = 0; i < spots.length; i++) {
        flspots.add(FlSpot(spots[i].$1.millisecondsSinceEpoch.toDouble(), spots[i].$2.toDouble()));
      }

      if (flspots.length > 30) {
        flspots = flspots.sublist(flspots.length - 30);
      }
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
              lineBarsData: [
                LineChartBarData(
                  barWidth: 4,
                  isCurved: false,
                  isStepLineChart: true,
                  lineChartStepData: const LineChartStepData(stepDirection: 0),
                  dotData: const FlDotData(
                    show: false
                  ),
                  spots: flspots,
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withAlpha(50),
                        Colors.blue.withAlpha(100)
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    )
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
                    minIncluded: false,
                    maxIncluded: false,
                    reservedSize: 70,
                    showTitles: true,
                    getTitlesWidget: moneyChangeTitles,
                  )
                )
              )
            )
          ),
        )
      ],
    );
  }
}

Widget moneyChangeTitles(double value, TitleMeta meta) {
  Text text;

  DateTime date = DateTime.fromMillisecondsSinceEpoch(value.round());

  if (firstLastDifference.inDays < 1) {
    text = Text("${date.hour.toString().padLeft(2, "0")}:${date.minute.toString().padLeft(2, "0")}");
  } else if (firstLastDifference.inDays < 31) {
    text = Text("${DateFormat('EEE').format(date)} ${date.hour}h");
  } else {
    text = Text("${date.month}/${date.day}");
  }

  return SideTitleWidget(
    meta: meta,
    child: Transform.rotate(angle: -45 * 3.14 / 180, child: text), 
  );
}

class ItemCategories extends StatelessWidget {
  final List<Map<String, dynamic>> inventory;

  const ItemCategories({super.key, required this.inventory});

  @override
  Widget build(BuildContext context) {
    List<double> categories = [0, 0, 0, 0, 0, 0];
    for (int i = 0; i < inventory.length; i++) {
      switch(inventory[i]['category']) {
        case "weapon": categories[0]++;
        case "armor": categories[1]++;
        case "food": categories[2]++;
        case "cosmetic": categories[3]++;
        case "potion": categories[4]++;
        case "misc": categories[5]++;
      }
    }
    return Column(
      children: [
        const ChartTop(text: "Tárgyaid száma\nketegóriánként"),
        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          height: 300,
          child: BarChart(
            BarChartData(
              barGroups: [
                BarChartGroupData( // Fegyver
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: categories[0],
                      gradient: const LinearGradient(
                        colors: [
                          Colors.red,
                          Colors.pink
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 20,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      borderSide: const BorderSide(
                        width: 1.5,
                        color: Colors.black
                      )
                    ),
                  ]
                ),
                BarChartGroupData( // Páncél
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: categories[1],
                      gradient: const LinearGradient(
                        colors: [
                          Colors.orange,
                          Colors.deepOrange
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 20,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      borderSide: const BorderSide(
                        width: 1.5,
                        color: Colors.black
                      )
                    ),
                  ]
                ),
                BarChartGroupData( // Étel
                  x: 2,
                  barRods: [
                    BarChartRodData(
                      toY: categories[2],
                      gradient: const LinearGradient(
                        colors: [
                          Colors.yellow,
                          Colors.orangeAccent
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 20,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      borderSide: const BorderSide(
                        width: 1.5,
                        color: Colors.black
                      )
                    ),
                  ]
                ),
                BarChartGroupData( // Kozmetika
                  x: 3,
                  barRods: [
                    BarChartRodData(
                      toY: categories[3],
                      gradient: const LinearGradient(
                        colors: [
                          Colors.lightGreen,
                          Colors.green
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 20,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      borderSide: const BorderSide(
                        width: 1.5,
                        color: Colors.black
                      )
                    ),
                  ]
                ),
                BarChartGroupData( // Bájital
                  x: 4,
                  barRods: [
                    BarChartRodData(
                      toY: categories[4],
                      gradient: const LinearGradient(
                        colors: [
                          Colors.blue,
                          Colors.lightBlueAccent
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 20,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      borderSide: const BorderSide(
                        width: 1.5,
                        color: Colors.black
                      )
                    ),
                  ]
                ),
                BarChartGroupData( // Egyéb
                  x: 5,
                  barRods: [
                    BarChartRodData(
                      toY: categories[5],
                      gradient: const LinearGradient(
                        colors: [
                          Colors.blueGrey,
                          Colors.grey
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 20,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      borderSide: const BorderSide(
                        width: 1.5,
                        color: Colors.black
                      )
                    ),
                  ]
                ),
              ],
              maxY: categories.reduce(max) + 1,
              alignment: BarChartAlignment.spaceEvenly,
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  axisNameWidget: SizedBox(
                    height: 15,
                  )
                ),
                bottomTitles: AxisTitles(
                  axisNameWidget: const SizedBox(
                    height: 20,
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, meta) {
                      TextStyle style = const TextStyle(fontSize: 8.5);
                      switch(value) {
                        case 0: return Text("Fegyver", style: style);
                        case 1: return Text("Páncél", style: style);
                        case 2: return Text("Étel", style: style);
                        case 3: return Text("Kozemtika", style: style);
                        case 4: return Text("Bájital", style: style);
                        case 5: return Text("Egyéb", style: style);
                      }
                      return const Text("FAIL");
                    },
                  )
                ),
                rightTitles: const AxisTitles(
                  axisNameWidget: SizedBox(width: 20),
                  sideTitles: SideTitles(
                    showTitles: false
                  )
                )
              )
            ),
          ),
        )
      ],
    );
  }
}
