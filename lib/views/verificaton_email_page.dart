import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynote/constants/route.dart';

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
                final user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();
              },
              child: const Text("Send verifie email")),
          TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginPage, (route) => false);
              },
              child: const Text("Restart")),
        ],
      ),
    );
  }
}
