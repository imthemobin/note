import 'package:flutter/material.dart';

Future<void> showErrorDialg(
  BuildContext context,
  String text,
) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("An Error Ouccerd!"),
          content: Text(text),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"))
          ],
        );
      });
}