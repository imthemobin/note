import 'package:flutter/material.dart';
import 'package:mynote/constants/route.dart';
import 'package:mynote/services/auth/auth_exceptions.dart';
import 'package:mynote/services/auth/auth_services.dart';
import 'package:mynote/utilities/show_errorDialog.dart';

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
      body: Column(
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
                          await AuthServices.firebase()
                              .createUser(email: email, password: password);
                          AuthServices.firebase().sendEmailVerification();
                          Navigator.of(context).pushNamed(verifidPage);
                        } on WeakPasswordAuthException {
                          await showErrorDialg(
                            context,
                            "weak password",
                          );
                        } on InvaildEmailAuthException {
                          await showErrorDialg(
                            context,
                            "invalid email",
                          );
                        } on EmailAlreadyInUseAuthException{
                          await showErrorDialg(
                            context,
                            "Email Already In Use",
                          );
                        }
                         on GenericAuthException {
                          await showErrorDialg(
                            context,
                            'Feaild register',
                          );
                        }
                      },
                      child: const Text("Register")),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            loginPage, (route) => false);
                      },
                      child: const Text("Login your account"))
                ],
              ),
    );
  }
}
