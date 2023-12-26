import 'package:flutter/material.dart';

import '../../widgets.dart';

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
      title: const Text("確定要退出？"),
      actions: confirmButtons(
        context,
        action: () {
          widget.action();
          Navigator.of(context).pop();
        },
        cancel: () => Navigator.of(context).pop(),
      ),
    );
  }
}
