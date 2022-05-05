import 'package:flutter/material.dart';
import 'package:mynote/constants/route.dart';
import 'package:mynote/services/auth/auth_exceptions.dart';
import 'package:mynote/services/auth/auth_services.dart';

import '../utilities/show_errorDialog.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
        title: const Text("Login"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            enableSuggestions: false,
            autocorrect: false,
            decoration:
                const InputDecoration(hintText: "Enter your email here"),
          ),
          TextField(
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            controller: _password,
            decoration:
                const InputDecoration(hintText: "Enter your email here"),
          ),
          TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                try {
                  await AuthServices.firebase()
                      .logIn(email: email, password: password);
                  final user = AuthServices.firebase().currentUser;
                  if (user?.isEmailVerified ?? false) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(mainPage, (route) => false);
                  } else {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(verifidPage, (route) => false);
                  }
                } on UserNotFoundAuthException {
                  await showErrorDialg(
                    context,
                    "user not found",
                  );
                } on WrongPasswordAuthException {
                  await showErrorDialg(
                    context,
                    "wrong password",
                  );
                } on GenericAuthException {
                  await showErrorDialg(
                    context,
                    'Error in logged in',
                  );
                }
              },
              child: const Text("Login")),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerPage, (route) => false);
              },
              child: const Text("Register your account"))
        ],
      ),
    );
  }
}
