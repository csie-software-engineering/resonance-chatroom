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
  late final ActivityProvider setActivityProvider = context.read<ActivityProvider>();
  late final QuestionProvider questionProvider = context.read<QuestionProvider>();

  late final InitPageArguments args =
      ModalRoute.of(context)!.settings.arguments as InitPageArguments;

  late Map<String, dynamic> args;

  Future<void> _incrementCounter() async {

    String id = authProvider.getUserId() as String;

    var da = await userProvider
        .getUserActivity(authProvider.getUserId() as String, "asdfghjkl", loadTag: true);

    // var ja = await userProvider.getUserActivity("15", "asdfghjkl", loadTag: true);

    // 這邊的邏輯應該是點選哪一個活動就獲得哪一個 id, displayname

    var targetTags = <UserTag>[];
    // 假裝
    targetTags.add(UserTag(id: "111", displayName: "apple"));
    targetTags.add(UserTag(id: "222", displayName: "banana"));
    targetTags.add(UserTag(id: "333", displayName: "cinnamon"));
    targetTags.add(UserTag(id: "444", displayName: "durian"));

    setState(() {
      _counter++;
    });


  }

  @override
  void initState() {
    super.initState();
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
            Text(
                "displayName: ${args["activities"][0].displayName}"
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
          _incrementCounter();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
