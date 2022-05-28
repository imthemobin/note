import 'package:flutter/material.dart';
import 'package:mynote/constants/enums.dart';
import 'package:mynote/constants/route.dart';
import 'package:mynote/services/auth/auth_services.dart';
import 'package:mynote/services/crud/notes_service.dart';

class NotePage extends StatefulWidget {
  const NotePage({Key? key}) : super(key: key);

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  late final NotesService _noteService;
  String get useremail => AuthServices.firebase().currentUser!.email!;

  @override
  void initState() {
    _noteService = NotesService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Notes"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(newNotes);
            },
            icon: const Icon(Icons.add),
          ),
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
      body: FutureBuilder(
        future: _noteService.getOrCreateUser(email: useremail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                  stream: _noteService.allNotes,
                  builder: ((context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        if (snapshot.hasData) {
                          final allNotes = snapshot.data as List<DatabaseNote>;
                          return ListView.builder(
                              itemCount: allNotes.length,
                              itemBuilder: (context, index) {
                                final note = allNotes[index];
                                print(allNotes[index]);
                                return ListTile(
                                  title: Text(
                                    note.text,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    maxLines: 1,
                                  ),
                                );
                              });
                        } else {
                          return const CircularProgressIndicator();
                        }
                      default:
                        return const CircularProgressIndicator();
                    }
                  }));
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
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
