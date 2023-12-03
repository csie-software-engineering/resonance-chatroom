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

    chatProvider.pairOrWait("Activity 2", "Daniel", <String>["Robot_2"]);
    chatProvider.pairOrWait("Activity 2", "Jason", <String>["Robot_2"]);

    setState(() {
      _counter++;
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatPage(
                  arguments: ChatPageArguments(
                    "data:image/jpeg;base64,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",
                    "Activity 2",// Test
                    peerId: "Daniel",
                    peerNickname: "bbbbbbbbbbb",
                  ),
                  title: 'Robot_2',
                )),
      );
    });
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
