import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:habiquest/pages/register_page.dart';
import 'package:habiquest/utils/theme/AppColors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habiquest/auth.dart';
import 'package:toastification/toastification.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? validateEmail(String? email) {
    RegExp emailRegExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    final isEmailValid = emailRegExp.hasMatch(email ?? '');
    if (!isEmailValid) {
      return 'Adj meg valós email címet!';
    }
    return null;
  }

  Future<void> signInWithEmailAndPassword() async {
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
        await Auth().signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } on FirebaseAuthException catch (e) {
        toastification.show(
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          context: context, // optional if you use ToastificationWrapper
          title: Text(e.message!),
          autoCloseDuration: const Duration(seconds: 5),
        );
      } finally {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("HabiQuest"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                validator: validateEmail,
                keyboardType: TextInputType.emailAddress,
                cursorColor: AppColors.white,
                controller: _emailController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  hintText: "Email",
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nem adott meg jelszót!';
                  }
                  return null;
                },
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
                  minimumSize: const Size(double.infinity, 48.0),
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
                onPressed: () => Auth().signInWithGoogle(),
                icon: SvgPicture.asset(
                  "lib/assets/icons/google-brands-solid.svg",
                  semanticsLabel: 'Google logo',
                  height: 20.0,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48.0),
                  foregroundColor: theme.colorScheme.onSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                label: const Text("Bejelentkezés Google fiókkal"),
              ),
              const SizedBox(height: 16.0),
              TextButton.icon(
                icon: const Icon(Icons.chevron_right),
                iconAlignment: IconAlignment.end,
                label: const Text("Ugrás a regisztrálás oldalra"),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.tertiary,
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
