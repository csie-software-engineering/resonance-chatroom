import 'package:flutter/material.dart';

import 'pages.dart';

enum Routes {
  initPage,
  hostActivitySetPage;

  String get value {
    switch (this) {
      case Routes.initPage:
        return '/init';
      case Routes.hostActivitySetPage:
        return '/hostActivitySet';
      default:
        throw Exception("Not found value for Router");
    }
  }
}

Map<String, Widget Function(BuildContext)> routes = {
  Routes.initPage.value: (_) => const InitPage(title: '',),
  Routes.hostActivitySetPage.value: (_) => const HostActivitySetPage(title: '',),
};