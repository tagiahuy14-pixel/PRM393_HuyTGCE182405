import 'package:flutter/material.dart';

Future<void> showFeedback(
  BuildContext context,
  String message, {
  bool error = false,
}) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(error ? 'Error' : 'Success'),
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('OK'),
      ),
    ],
  ),
);
