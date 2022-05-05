import 'package:flutter/material.dart';
import 'package:mynote/constants/route.dart';
import 'package:mynote/services/auth/auth_services.dart';
import 'package:mynote/views/login.dart';
import 'package:mynote/views/note_views.dart';
import 'package:mynote/views/register.dart';
import 'package:mynote/views/verificaton_email_page.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const MyHomePage(),
    routes: {
      loginPage: (context) => const Login(),
      registerPage: (context) => const Register(),
      mainPage: (context) => const NotePage(),
      verifidPage:(context) => const VerificationEmail(),
    },
  ));
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthServices.firebase().initializ(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthServices.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const NotePage();
              } else {
                return const VerificationEmail();
              }
            } else {
              return const Login();
            }

          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}




