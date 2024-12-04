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
  final TextEditingController _rePasswordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? errorMessage = '';

  String? validateEmail(String? email) {
    RegExp emailRegExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    final isEmailValid = emailRegExp.hasMatch(email ?? '');
    if (!isEmailValid) {
      return 'Adj meg valós email ciémet!';
    }
    return null;
  }

  Future<void> signUpWithEmailAndPassword() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: AppColors.secondary,
          ),
        ),
      );
      try {
        await Auth().createUserWithEmailAndPassword(
          username: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
      } on FirebaseAuthException catch (e) {
        print("Hiba a FIREBASE-ben: ${e.message}");
        setState(() {
          errorMessage = e.message;
        });
      } finally {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Regisztrálás")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _usernameController,
                      cursorColor: Theme.of(context).colorScheme.onPrimary,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        hintText: "Felhasználónév", // Hint text only
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nem adott meg felhasználónevet!';
                        }
                        return null;
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _emailController,
                    cursorColor: Theme.of(context).colorScheme.onPrimary,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      hintText: "Email",
                    ),
                    validator: validateEmail,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _passwordController,
                    cursorColor: Theme.of(context).colorScheme.onPrimary,
                    obscureText: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.key),
                      hintText: "Jelszó",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nem adott meg jelszót!';
                      } else if (value != _rePasswordController.text) {
                        return 'Jelszavak nem egyeznek meg!';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _rePasswordController,
                    cursorColor: Theme.of(context).colorScheme.onPrimary,
                    obscureText: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.key),
                      hintText: "Jelszó megerősítése",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nem adott meg jelszót!';
                      } else if (value != _passwordController.text) {
                        return 'Jelszavak nem egyeznek meg!';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondary,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
