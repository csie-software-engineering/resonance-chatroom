import 'package:flutter/material.dart';

class QuitWarningDialog extends StatefulWidget {
  const QuitWarningDialog({super.key, required this.action});

  final Future<void> Function() action;

  @override
  State<QuitWarningDialog> createState() => _QuitWarningDialogState();
}

class _QuitWarningDialogState extends State<QuitWarningDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("確定要退出？"),
      actions: [
        TextButton(
          child: Text("確定"),
          onPressed: widget.action,
        )
      ],
    );
  }
}
