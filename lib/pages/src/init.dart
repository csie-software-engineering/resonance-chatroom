import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';

class InitPageArguments {
  final String title;
  final User curUser;

  InitPageArguments({required this.title, required this.curUser});
}

class InitPage extends StatefulWidget {
  const InitPage({super.key});

  static const routeName = '/init';

  @override
  State<InitPage> createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  int _counter = 0;
  late final ChatProvider chatProvider = context.read<ChatProvider>();
  late final AuthProvider authProvider = context.read<AuthProvider>();
  late final UserProvider userProvider = context.read<UserProvider>();
  late final SetActivityProvider setActivityProvider =
      context.read<SetActivityProvider>();
  late final QuestionProvider questionProvider =
      context.read<QuestionProvider>();

  late final InitPageArguments args =
      ModalRoute.of(context)!.settings.arguments as InitPageArguments;

  Future<void> _incrementCounter() async {
    final curUser = await authProvider.currentUser;
    debugPrint(curUser.toString());
    setState(() {
      _counter++;
      // Navigator.of(context).pushNamed(Routes.hostActivitySetPage.value);
    });
    await setActivityProvider.DeleteActivity(
        "20231214-1925-8500-9785-21d5e8c0c78e", "ownerid");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(args.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '${args.curUser.uid} $_counter',
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
