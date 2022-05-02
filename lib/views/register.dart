import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynote/constants/route.dart';
import 'package:mynote/utilities/show_errorDialog.dart';
import 'dart:developer' as devtools show log;
import '../firebase_options.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Page"),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Column(
                children: [
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                        hintText: "Enter your email here"),
                  ),
                  TextField(
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    controller: _password,
                    decoration: const InputDecoration(
                        hintText: "Enter your email here"),
                  ),
                  TextButton(
                      onPressed: () async {
                        final email = _email.text;
                        final password = _password.text;
                        try {
                          await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                  email: email, password: password);
                          final user = FirebaseAuth.instance.currentUser;
                          await user?.sendEmailVerification();
                          Navigator.of(context).pushNamed(verifidPage);
                        } on FirebaseAuthException catch (e) {
                          if (e.code == "weak-password") {
                            await showErrorDialg(
                              context,
                              "weak password",
                            );
                          } else if (e.code == "email-already-in-use") {
                            await showErrorDialg(
                              context,
                              "email alread in use",
                            );
                          } else if (e.code == "invalid-email") {
                            await showErrorDialg(
                              context,
                              "invalid email",
                            );
                          } else {
                            await showErrorDialg(
                              context,
                              "Erroe: ${e.code}",
                            );
                          }
                        } catch (e) {
                          await showErrorDialg(
                            context,
                            e.toString(),
                          );
                        }
                      },
                      child: const Text("Register")),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/Login/', (route) => false);
                      },
                      child: const Text("Login your account"))
                ],
              );
            default:
              return const Text("Loading...");
          }
        },
      ),
    );
  }
}
