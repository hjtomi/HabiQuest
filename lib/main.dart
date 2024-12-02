import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:habiquest/firebase_options.dart';
import 'package:habiquest/utils/theme/AppTheme.dart';
import 'package:habiquest/widget_tree.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Themed App',
      theme: AppTheme.lightTheme, // Light theme
      darkTheme: AppTheme.darkTheme, // Dark theme
      themeMode: ThemeMode.dark, // Force dark theme
      home: const WidgetTree(),
    );
  }
}
