import 'package:flutter/material.dart';
import 'package:mynote/constants/enums.dart';
import 'package:mynote/constants/route.dart';

class NotePage extends StatefulWidget {
  const NotePage({Key? key}) : super(key: key);

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main UI"),
        actions: [
          PopupMenuButton<MenuAction>(onSelected: (value) async {
            switch (value) {
              case MenuAction.logout:
                final dialog = await showDialogs(context);
                // devtools.log(dialog.toString());
                if (dialog) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(loginPage, (route) => false);
                } else {
                  return;
                }
                break;
            }
          }, itemBuilder: ((context) {
            return const [
              PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                child: Text("LogOut"),
              ),
            ];
          }))
        ],
      ),
      body: const Text("hello world"),
    );
  }
}

Future<bool> showDialogs(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("LOGOUT"),
          content: const Text("Are you sure to log out?"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("Cancel")),
            TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(true);
                },
                child: const Text("Logout")),
          ],
        );
      }).then((value) => value ?? false);
}