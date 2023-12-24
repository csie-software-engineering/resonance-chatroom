import 'package:flutter/material.dart';

AppBar myAppBar(BuildContext context, {Widget? title, Widget? leading}) =>
    AppBar(
      toolbarHeight: 50 + MediaQuery.of(context).size.height * 0.03,
      title: title,
      centerTitle: true,
      titleSpacing: 5,
      titleTextStyle: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
      leading: leading,
      leadingWidth: 80,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
