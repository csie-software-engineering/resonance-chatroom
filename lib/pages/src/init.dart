import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/src/user.dart';
import '../../providers/providers.dart';
import '../pages.dart';

class InitPage extends StatefulWidget {
  const InitPage({super.key, required this.title});
  final String title;

  @override
  State<InitPage> createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  int _counter = 0;
  late final ChatProvider chatProvider = context.read<ChatProvider>();
  late final AuthProviders authProvider = context.read<AuthProviders>();
  late final UserProvider userProvider = context.read<UserProvider>();

  void _incrementCounter() {
    setState(() {
      _counter++;
      chatProvider.sendMessage(
        'Hello $_counter',
        MessageType.text,
        'groupChatId',
        'currentUserId',
        'peerId',
      );
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatPage(
                  arguments: ChatPageArguments(
                    "PeerAvatar", // Test
                    peerId: "123",
                    peerNickname: "Daniel",
                  ),
                  title: 'test',
                )),
      );
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HostActivitySetPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
