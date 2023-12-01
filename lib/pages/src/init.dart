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
      // var user = const User(
      //   id: "123",
      //   displayName: "Gary",
      //   photoUrl: "asdfghjkl",
      //   email: "gary@gmail.com",
      //   activities: [
      //     UserActivity(
      //       id: "aaa",
      //       displayName: "AAA",
      //       tags: [
      //         UserTag(
      //           id: "tags1",
      //           displayName: "TAG!",
      //         ),
      //         UserTag(
      //           id: "tags2",
      //           displayName: "TAG@",
      //         ),
      //       ],
      //     ),
      //     UserActivity(
      //       id: "bbb",
      //       displayName: "BBB",
      //       tags: [
      //         UserTag(
      //           id: "tags3",
      //           displayName: "TAG#",
      //         ),
      //         UserTag(
      //           id: "tags4",
      //           displayName: "TAG%",
      //         ),
      //       ],
      //     ),
      //   ],
      // );

      // userProvider.setUser(user).then((value) => userProvider.getUser("123").then((value) => log(value!.toJson().toString())));
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HostActivitySetPage(title: 'test',)),
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
