import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resonance_chatroom/pages/routes.dart';
import 'package:resonance_chatroom/pages/pages.dart';

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
  late final ActivityProvider setActivityProvider = context.read<ActivityProvider>();
  late final QuestionProvider questionProvider = context.read<QuestionProvider>();

  late final InitPageArguments args =
      ModalRoute.of(context)!.settings.arguments as InitPageArguments;

  Future<void> _incrementCounter() async {
    final curUser = await authProvider.currentUser;
    Activity activity = Activity(
        activityName: 'activityname',
        activityInfo: "activityinfo",
        startDate: "startdate",
        endDate: "enddate",
        activityPhoto: "activitryphoto");
    await setActivityProvider.setNewActivity(activity);
    debugPrint(curUser.toString());
    setState(() {
      _counter++;
    });


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
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserActivityMainPage()),
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
