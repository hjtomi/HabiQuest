import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:habiquest/register.dart';
import 'package:habiquest/skin.dart';
import 'package:habiquest/utils/theme/AppColors.dart';
import 'package:habiquest/utils/theme/AppTheme.dart';

void main() {
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
      home: const CharacterSelector(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("HabiQuest"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                cursorColor: AppColors.white,
                controller: _usernameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  hintText: "Felhasználónév", // Hint text only
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                cursorColor: AppColors.white,
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.key),
                  hintText: "Jelszó",
                ),
              ),
              const SizedBox(height: 16.0),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize:
                      const Size(double.infinity, 48.0), // Set the height here
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () => {print(_usernameController.text)},
                child: const Text("Bejelentkezés"),
              ),
              const SizedBox(height: 16.0),
              OutlinedButton.icon(
                icon: SvgPicture.asset(
                  "lib/icons/google-brands-solid.svg",
                  semanticsLabel: 'Google logo',
                  height: 20.0,
                  colorFilter:
                      const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                  theme: const SvgTheme(
                    currentColor: Colors.white, // Optional: Add a default color
                  ),
                ),
                style: FilledButton.styleFrom(
                  minimumSize:
                      const Size(double.infinity, 48.0), // Set the height here
                  foregroundColor: theme.colorScheme.onSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () => {print(_usernameController.text)},
                label: const Text("Bejelentkezés Google fiókkal"),
              ),
              const SizedBox(height: 16.0),
              TextButton.icon(
                icon: const Icon(Icons.chevron_right),
                iconAlignment: IconAlignment.end,
                label: const Text("Ugrás a regisztrálás oldalra"),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.surface,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
