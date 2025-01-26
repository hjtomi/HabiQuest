import 'package:flutter/material.dart';
import 'package:habiquest/common.dart';
import 'package:habiquest/daily_gift.dart';

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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Handle app lifecycle changes
    if (state == AppLifecycleState.inactive) {
      printMessage("App is inactive.");
    } else if (state == AppLifecycleState.paused) {
      printMessage("App is in the background.");
    } else if (state == AppLifecycleState.resumed) {
      printMessage("App is back in the foreground.");
      addResume(context);
      checkDailygift(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}