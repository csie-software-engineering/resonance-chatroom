import 'package:flutter/material.dart';

List<Widget> confirmButtons(
  BuildContext context, {
  void Function()? action,
  void Function()? cancel,
}) =>
    [
      FilledButton.tonal(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            Theme.of(context).colorScheme.errorContainer,
          ),
        ),
        onPressed: () {
          if(cancel != null) cancel();
        },
        child: Text(
          '取消',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
      FilledButton.tonal(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            Theme.of(context).colorScheme.primaryContainer,
          ),
        ),
        onPressed: () {
          if(action != null) action();
        },
        child: Text(
          '確定',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    ];
