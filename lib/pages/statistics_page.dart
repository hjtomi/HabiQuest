import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:habiquest/common.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  @override
  Widget build(BuildContext context) {
    printMessage(firestore.collection('users').doc('habits').get());
    return const Placeholder();
  }
}