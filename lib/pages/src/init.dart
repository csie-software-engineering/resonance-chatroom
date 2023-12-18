
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:resonance_chatroom/pages/src/user_activity_main_page.dart';
import 'package:resonance_chatroom/utils/src/base64.dart';
import 'package:resonance_chatroom/utils/src/time.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../routes.dart';

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
  late final ActivityProvider activityProvider = context.read<ActivityProvider>();
  late final QuestionProvider questionProvider = context.read<QuestionProvider>();

  late final InitPageArguments args =
      ModalRoute.of(context)!.settings.arguments as InitPageArguments;

  Future<void> _incrementCounter() async {

    // 登入完抓資料
    // 這邊的邏輯應該是點選哪一個活動就獲得哪一個 id, displayname
    // final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    // Activity activitydata = Activity(
    //     activityPhoto: (await imagePathToBase64(image!.path))!,
    //     activityInfo: "我們誠摯邀請您參加我們舉辦的非常好活動！這次活動將提供豐富多彩的體驗，包括精彩演講、互動工作坊和令人振奮的社交時間。無論您是尋找知識的探索還是與志趣相投的人建立聯繫，這都是一個絕佳的機會。我們精心策劃了活動內容，以確保每位參與者都能獲得啟發和樂趣。別錯過這個難得的機會，與我們一同創造難忘的回憶！立即報名參加，讓我們共同享受這場精彩的盛會。",
    //     activityName: "非常好活動",
    //     startDate: DateTime(2023, 12, 25).toEpochString(),
    //     endDate: DateTime(2023, 12, 31).toEpochString());
    //
    // var activity = await activityProvider.setNewActivity(activitydata);
    // activityProvider.addManagers(activity.uid, "test123");
    // var activityId = activity.uid;
    // //
    // debugPrint("activityId: ${activityId}");
    // //
    // var act = UserActivity(
    //     uid: "20231218-0118-8038-a440-9cfda5307c72", isManager: false);
    //
    // await userProvider.addUserActivity(act);
    // //
    // await activityProvider.addNewTag(activityId, "好");
    // await activityProvider.addNewTag(activityId, "很好");
    // await activityProvider.addNewTag(activityId, "非常好");
    // await activityProvider.addNewTag(activityId, "很好非常好");
    //
    setState(() {
      _counter++;
      Navigator.of(context).pushNamed(UserActivityMainPage.routeName,
          arguments: UserActivityMainPageArguments(activityId: "20231218-0118-8038-a440-9cfda5307c72"));

    });
    // await activityProvider.DeleteActivity(
    //     "20231214-1925-8500-9785-21d5e8c0c78e", "ownerid");
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
            // Text(
            //     "displayName: ${args["activities"][0].displayName}"
            // ),
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
