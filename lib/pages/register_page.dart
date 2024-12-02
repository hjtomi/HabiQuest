import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:habiquest/utils/theme/AppColors.dart';
import 'package:habiquest/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? errorMessage = '';

  Future<void> signUpWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _usernameController.text,
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
    return Scaffold(
      appBar: AppBar(title: const Text("Regisztrálás")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: _usernameController,
                  cursorColor: Theme.of(context).colorScheme.onPrimary,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    hintText: "Felhasználónév", // Hint text only
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: _emailController,
                  cursorColor: Theme.of(context).colorScheme.onPrimary,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    hintText: "Email",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: _passwordController,
                  cursorColor: Theme.of(context).colorScheme.onPrimary,
                  obscureText: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.key),
                    hintText: "Jelszó",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  cursorColor: Theme.of(context).colorScheme.onPrimary,
                  obscureText: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.key),
                    hintText: "Jelszó megerősítése",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    minimumSize: const Size(double.infinity, 48.0),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () => signUpWithEmailAndPassword(),
                  child: const Text("Regisztrálás"),
                ),
              ),
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
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () => {},
                label: const Text("Regisztrálás Google fiókkal"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
