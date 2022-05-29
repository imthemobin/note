import 'package:flutter/material.dart';
import 'package:mynote/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialg(
  BuildContext context,
  String text,
) {
  return showGenericDialog(
    context: context,
    title: 'An Erroe occurred',
    content: text,
    optionBuilder: () => {'OK': null},
  );
}
