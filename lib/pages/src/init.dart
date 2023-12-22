import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/utils.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../routes.dart';

class InitPageArguments {
  final String title;

  InitPageArguments({required this.title});
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
  late final ActivityProvider activityProvider =
      context.read<ActivityProvider>();
  late final QuestionProvider questionProvider =
      context.read<QuestionProvider>();

  late final InitPageArguments args =
      ModalRoute.of(context)!.settings.arguments as InitPageArguments;

  Future<void> _incrementCounter() async {
    // final image = (await pickImageToBase64())!;
    // final acts = [
    //   Activity(
    //     activityName: '城市規劃',
    //     activityInfo: '城市大規劃',
    //     startDate: DateTime(2024, 1, 1).toEpochString(),
    //     endDate: DateTime(2024, 1, 15).toEpochString(),
    //     activityPhoto: image,
    //   ),
    //   Activity(
    //     activityName: '城市比賽',
    //     activityInfo: '城市大比賽',
    //     startDate: DateTime(2024, 1, 1).toEpochString(),
    //     endDate: DateTime(2024, 2, 15).toEpochString(),
    //     activityPhoto: image,
    //   ),
    //   Activity(
    //     activityName: '程式比賽',
    //     activityInfo: '程式大比賽',
    //     startDate: DateTime(2024, 12, 1).toEpochString(),
    //     endDate: DateTime(2024, 12, 20).toEpochString(),
    //     activityPhoto: image,
    //   ),
    // ];

    // final acts = [
    //   UserActivity(uid: "20231218-1554-8234-8689-194348ce6093", isManager: false),
    //   UserActivity(uid: "20231218-1554-8a34-9635-ed255f5df37a", isManager: false),
    //   UserActivity(uid: "20231218-1554-8f34-b658-2c026462fb1d", isManager: false),
    // ];

    // await Future.wait(acts.map((act) async {
    //   await activityProvider.setNewActivity(act);
    //   // await userProvider.addUserActivity(act);
    // }));

    setState(() {
      _counter++;
      Navigator.of(context).pushNamed(MainPage.routeName,
          arguments: MainPageArguments(isHost: false));
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
    // //
    // await userProvider.addUserActivity(act);
    // await userProvider.addUserSocialMedia(UserSocialMedia(displayName: "Discord", linkUrl: "Discord:123"));
    // await userProvider.addUserSocialMedia(UserSocialMedia(displayName: "wechat", linkUrl: "wechat:123"));
    // await userProvider.addUserSocialMedia(UserSocialMedia(displayName: "Thread", linkUrl: "Thread:123"));
    // //
    // await activityProvider.addNewTag(activityId, "好");
    // await activityProvider.addNewTag(activityId, "很好");
    // await activityProvider.addNewTag(activityId, "非常好");
    // await activityProvider.addNewTag(activityId, "很好非常好");

    // var tagId = "20231218-0118-8d40-b813-9888d47a10a3";
    // var activityId = "20231218-0118-8038-a440-9cfda5307c72";
    // var topicId = "20231220-0610-8715-b315-968b7f782f3f";
    //
    // await activityProvider.addNewTopic(activityId, Topic(activityId: activityId, tagId: tagId, topicName: "早上好台灣，你有冰淇林嗎?"));
    // await activityProvider.addNewTopic(activityId, Topic(activityId: activityId, tagId: tagId, topicName: "你會去看素肚與雞琴酒嗎?"));
    // await activityProvider.addNewTopic(activityId, Topic(activityId: activityId, tagId: tagId, topicName: "你知兩個禮拜以後有什麼嗎?"));
    //

    // await activityProvider.addNewQuestion(
    //     activityId,
    //     Question(
    //         activityId: activityId,
    //         tagId: tagId,
    //         topicId: topicId,
    //         questionName: "你喜歡哪一種冰期零",
    //         choices: <String>["草莓", "巧克力", "香草", "素肚"]));

    setState(() {
      _counter++;
      Navigator.of(context).pushNamed(UserActivityMainPage.routeName,
          arguments: UserActivityMainPageArguments(
              activityId: "20231218-0118-8038-a440-9cfda5307c72"));
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
            // Text(
            //     "displayName: ${args["activities"][0].displayName}"
            // ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _incrementCounter();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
