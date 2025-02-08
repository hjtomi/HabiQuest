import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:habiquest/auth.dart';
import 'package:habiquest/common.dart';
import 'package:habiquest/daily_gift.dart';
import 'package:habiquest/pages/statistics_page.dart';

class LifecycleHandler extends StatefulWidget {
  final Widget child;

  const LifecycleHandler({super.key, required this.child});

  @override
  _LifecycleHandlerState createState() => _LifecycleHandlerState();
}

class _LifecycleHandlerState extends State<LifecycleHandler> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    // Handle app lifecycle changes
    if (state == AppLifecycleState.inactive) {
      printMessage("App is inactive.");
    } else if (state == AppLifecycleState.paused) {
      printMessage("App is in the background.");
      stopCounting();
      if (timeFetched) {
        FirebaseFirestore.instance.collection('users').doc(Auth().currentUser!.uid).update({
          "secondsInApp": timeSpent
        });
        timeSpent = 0;
        timeFetched = false;
      }
    } else if (state == AppLifecycleState.resumed) {
      printMessage("App is back in the foreground.");
      addResume(context);
      getSecondsInApp();
      countSecondsInApp();
      checkDailygift(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}