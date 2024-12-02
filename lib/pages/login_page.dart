import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:habiquest/pages/register_page.dart';
import 'package:habiquest/utils/theme/AppColors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habiquest/auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

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
                keyboardType: TextInputType.emailAddress,
                cursorColor: AppColors.white,
                controller: _emailController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  hintText: "Email", // Hint text only
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
                onPressed: () => signInWithEmailAndPassword(),
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
                onPressed: () => {},
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
