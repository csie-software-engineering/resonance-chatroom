import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/src/user.dart';
import '../../providers/providers.dart';
import '../routes.dart';

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

  Future<void> _incrementCounter() async {

    var tags1 = <UserTag>[];
    tags1.add(UserTag(id: "123", displayName: "apple"));
    tags1.add(UserTag(id: "456", displayName: "banana"));
    var tags2 = <UserTag>[];
    tags2.add(UserTag(id: "456", displayName: "banana"));
    await userProvider.addUser(
      User(
        id: "14",
        displayName: "Daniel",
        email: "daniel@gmail.com",
      )
    );
    var act = UserActivity(
      id: "asdfghjkl",
      displayName: "qwertyuiop",
      tags: tags1
    );
    await userProvider.addUserActivity("14", act, addTag: true);

    await userProvider.addUser(
        User(
          id: "15",
          displayName: "Jason",
          email: "jason@gmail.com",
        )
    );

    await userProvider.addUserActivity("15", act);
    for(var tag in tags2){
      await userProvider.addUserTag("15", "asdfghjkl", tag);
    }

    var Daniel = await userProvider.getUser("14", loadActivity: true);
    var jason = await userProvider.getUser("15", loadActivity: true);

    var da = await userProvider.getUserActivity("14", "asdfghjkl", loadTag: true);
    var ja = await userProvider.getUserActivity("15", "asdfghjkl", loadTag: true);

    var re1 = await chatProvider.pairOrWait("asdfghjkl", "14", da!.tags.map((e) {
      return e.id;
    }).toList());

    debugPrint(re1 ?? "no");

    var re2 = await chatProvider.pairOrWait("asdfghjkl", "15", ja!.tags.map((e) {
      return e.id;
    }).toList());

    debugPrint(re2 ?? "no");

    setState(() {
      _counter++;
      Navigator.of(context).pushNamed(Routes.chatPage.value);
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
