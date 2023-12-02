import 'package:flutter/material.dart';


import 'pages.dart';

enum Routes {
  initPage,
  hostActivitySetPage,
  chatPage;

  String get value {
    switch (this) {
      case Routes.initPage:
        return '/init';
      case Routes.hostActivitySetPage:
        return '/hostActivitySet';
      case Routes.chatPage:
        return '/chatPage';
      default:
        throw Exception("Not found value for Router");
    }
  }
}

Map<String, Widget Function(BuildContext)> routes = {
  Routes.initPage.value: (_) => const InitPage(title: '',),
  Routes.hostActivitySetPage.value: (_) => const HostActivitySetPage(title: '',),
  Routes.chatPage.value: (_) => ChatPage(arguments: ChatPageArguments(
    "peerAvatar",
    "Robot",
    peerNickname: "peerNickname",
    peerId: 'Jason',
  ), title: "Router set"),
};