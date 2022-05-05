import 'package:flutter/material.dart';
import 'package:mynote/constants/route.dart';
import 'package:mynote/services/auth/auth_services.dart';

class VerificationEmail extends StatefulWidget {
  const VerificationEmail({Key? key}) : super(key: key);

  @override
  State<VerificationEmail> createState() => _VerificationEmailState();
}

class _VerificationEmailState extends State<VerificationEmail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verification")),
      body: Column(
        children: [
          const Text("if you dont recive email verifid click button"),
          TextButton(
              onPressed: () async {
                await AuthServices.firebase().sendEmailVerification();
              },
              child: const Text("Send verifie email")),
          TextButton(
              onPressed: () async {
                await AuthServices.firebase().logOut();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginPage, (route) => false);
              },
              child: const Text("Restart")),
        ],
      ),
    );
  }
}
