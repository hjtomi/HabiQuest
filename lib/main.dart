import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:habiquest/firebase/firebase_options.dart';
import 'package:habiquest/utils/theme/AppTheme.dart';
import 'package:habiquest/widget_tree.dart';
import 'package:toastification/toastification.dart';
import 'package:habiquest/lifecycle_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const LifecycleHandler(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Themed App',
        theme: AppTheme.lightTheme, // Light theme
        darkTheme: AppTheme.darkTheme, // Dark theme
        themeMode: ThemeMode.dark, // Force dark theme
        home: const WidgetTree(),
      ),
    );
  }
}
