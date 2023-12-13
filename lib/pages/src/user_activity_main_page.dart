import 'dart:async';
// import 'dart:html';

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/src/user.dart';
import '../../providers/providers.dart';
import '../routes.dart';
import '../../widgets/src/activity_card/activity_card.dart';

class UserActivityMainPage extends StatefulWidget {
  const UserActivityMainPage({super.key});

  @override
  State<UserActivityMainPage> createState() => _UserActivityMainPageState();
}

class _UserActivityMainPageState extends State<UserActivityMainPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  late final ChatProvider chatProvider = context.read<ChatProvider>();
  late final AuthProviders authProvider = context.read<AuthProviders>();
  late final UserProvider userProvider = context.read<UserProvider>();

  late final Map<String, dynamic> args;

  FloatingActionButtonLocation buttonPosition =
      FloatingActionButtonLocation.centerFloat;

  bool _startMatching = false;

  late double _buttonPositionTop;
  late double _buttonPositionLeft;

  double _height = 0;
  Timer? _timer;
  int timeShowUp = 0;

  // 到時候會從 firebase 那邊抓資料
  late final String _appBarTitle = "人工智慧大爆炸";
  late final String _description = _test;
  late final String _imageUrl = _fakeUrl;

  late List<bool> tagSelected;

  bool toggle = true;
  late double top1;
  late double left1;
  late double top2;
  late double left2;
  late double top3;
  late double left3;

  bool _enable = false;

  double size1 = 20;
  double size2 = 20;
  double size3 = 20;

  bool Initial = false;

  Widget? _subTitle() {
    if (!_startMatching) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: Theme.of(context).colorScheme.surface,
        child: AnimatedOpacity(
          opacity: 0,
          duration: const Duration(milliseconds: 1000),
          child: Center(
            child: Text(_formatTime()),
          ),
        ),
      );
    } else {
      return AnimatedContainer(
        curve: Curves.easeIn,
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 2,
              offset: const Offset(0, 5), // 阴影位置，可以调整阴影的方向
            ),
          ],
        ),
        child: AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 1000),
          child: Center(
            child: Text(
              _formatTime(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            ),
          ),
        ),
      );
    }
  }

  void _onTimerTick(Timer timer) {
    setState(() {
      // 每1秒更新一次計數器
      timeShowUp++;
    });
  }

  String _formatTime() {
    int minutes = timeShowUp ~/ 60;
    int remainingSeconds = timeShowUp % 60;

    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// 初始化
  /// fetch 使用者標籤，並使用 List<bool> 來記錄使用者之前所勾選的標籤
  void _initSetTag() {
      Map<String, bool> map = { for (var item in args["actTags"]) item.id : false };
      for(var i in args["userActMeta"].tags) {
        // assert(!tagSelected.containsKey(i.id), "no tag with id:<${i.id}> ( displayName:<${i.displayName}>");
        map[i.id] = true;
      }
      tagSelected = List.generate(args["actTags"].length, (index) => false);
      int i = 0;
      map.forEach((key, value) {
        tagSelected[i++] = value;
      });
  }

  void _init(height, width) async {
    if (!Initial) {
      _buttonPositionTop = height - 70;
      _buttonPositionLeft = width - 100;
      args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _initSetTag();
      Initial = true;
    }
    if (!_enable) {
      top1 = top2 = top3 = _buttonPositionTop + 10;
      left1 = left2 = left3 = _buttonPositionLeft + 10;
      _enable = true;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350),
      reverseDuration: Duration(milliseconds: 275),
    );

    _animation = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn);

    _controller.addListener(() {
      setState(() {});
    });

    // userProvider.
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _init(
        MediaQuery.of(context).size.height, MediaQuery.of(context).size.width);
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: Offset(0, 2), // 阴影位置，可以调整阴影的方向
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top),
                Row(
                  children: [
                    const BackButton(),
                    Expanded(
                      child: Container(
                        height: kToolbarHeight,
                        child: Center(
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(16)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 20.0),
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.8),
                              child: Text(_appBarTitle,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onInverseSurface)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 50),
                  ],
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 1000),
            curve: Curves.easeOutQuint,
            height: _height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            child: _subTitle(),
          ),
          Expanded(
            child: ListView(
              children: [
                ActivityMainContent(
                  imageUrl: _imageUrl,
                  date: '',
                ),
                ActivityDescription(
                  description: _description,
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
          // height: 250.0,
          // width: 250.0,
          child: Stack(
        children: [
          _enable
              ? AnimatedPositioned(
                  duration: toggle
                      ? Duration(milliseconds: 275)
                      : Duration(milliseconds: 875),
                  top: top1,
                  left: left1,
                  curve: toggle ? Curves.easeIn : Curves.elasticOut,
                  child: AnimatedContainer(
                    duration: toggle
                        ? Duration(milliseconds: 275)
                        : Duration(milliseconds: 875),
                    curve: toggle ? Curves.easeIn : Curves.elasticOut,
                    height: size1,
                    width: size1,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withRed(200),
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: Icon(Icons.message,
                        color: Theme.of(context).colorScheme.onInverseSurface),
                  ),
                )
              : SizedBox(),
          _enable
              ? AnimatedPositioned(
                  top: top2,
                  left: left2,
                  duration: toggle
                      ? Duration(milliseconds: 275)
                      : Duration(milliseconds: 875),
                  curve: toggle ? Curves.easeIn : Curves.elasticOut,
                  child: AnimatedContainer(
                    duration: toggle
                        ? Duration(milliseconds: 275)
                        : Duration(milliseconds: 875),
                    curve: toggle ? Curves.easeIn : Curves.elasticOut,
                    height: size2,
                    width: size2,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withRed(200),
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: IconButton(
                      icon: _startMatching
                          ? Text("取消",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onInverseSurface,
                              ))
                          : Text("配對",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onInverseSurface,
                              )),
                      onPressed: () async {
                        if (_startMatching) {
                          setState(() {
                            _startMatching = false;
                            _height = 0;
                            timeShowUp = 0;
                            _timer?.cancel();
                          });
                        } else {
                          setState(() {
                            _startMatching = true;
                            _height = 20;
                            _timer = Timer.periodic(
                                const Duration(seconds: 1), _onTimerTick);
                          });

                          String id = authProvider.getUserId() as String;

                          debugPrint("getUserId2: ${id}");

                          // var re1 = await chatProvider.pairOrWait(
                          //     "asdfghjkl",
                          //     id,
                          //     da!.tags.map((e) {
                          //       return e.id;
                          //     }).toList());


                          setState(() {
                            _height = 0;
                            Navigator.of(context)
                                .pushNamed(Routes.chatPage.value, arguments: {
                              "a": 1,
                            });
                          });
                        }
                      },
                    ),
                  ),
                )
              : SizedBox(),
          _enable
              ? AnimatedPositioned(
                  top: top3,
                  left: left3,
                  duration: toggle
                      ? Duration(milliseconds: 275)
                      : Duration(milliseconds: 875),
                  curve: toggle ? Curves.easeIn : Curves.elasticOut,
                  child: AnimatedContainer(
                    duration: toggle
                        ? Duration(milliseconds: 275)
                        : Duration(milliseconds: 875),
                    curve: toggle ? Curves.easeIn : Curves.elasticOut,
                    height: size3,
                    width: size3,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withRed(200),
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: IconButton(
                      icon: Text("標籤",
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onInverseSurface,
                          )),
                      onPressed: (){
                        var height = context.size!.height * 0.5;
                        var width = context.size!.width * 0.8;

                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              List<bool> tagTmp = List.generate(args["actTags"].length, (index) => false);
                              for(int i = 0; i < tagSelected.length; i++) {
                                  tagTmp[i] = tagSelected[i];
                              }
                              return AlertDialog(
                                insetPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 40.0),
                                actionsPadding: const EdgeInsets.only(top: 0),
                                scrollable: true,
                                title: Column(
                                  // alignment: AlignmentDirectional.topStart,
                                  children: [
                                    Text("匹配設定"),
                                    SizedBox(height: 20),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        padding: EdgeInsets.all(14),
                                        height: 70,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(right: 10),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                    "暱稱",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                                width: width * 0.5,
                                                child: TextField(
                                                  decoration: InputDecoration(
                                                    isCollapsed: true,
                                                    hintText: "冰機靈"
                                                  ),
                                                  maxLines: 1,
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                content: Container(
                                    padding: EdgeInsets.all(14),
                                    height: 300,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Text(
                                              "標籤",
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                       const SizedBox(height: 10),
                                        Container(
                                          height: 230,
                                          width: width,
                                          child: Tags(tagList: args["actTags"], tagSelectedTmp: tagTmp),
                                        )
                                      ],
                                    ),
                                  ),

                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      tagSelected = tagTmp;
                                      var newTags = <UserTag>[];
                                      for(int i = 0; i < tagSelected.length; i++) {
                                        if(tagSelected[i]) {
                                          newTags.add(args["actTags"][i]);
                                          // debugPrint("args:${authProvider.getUserId()}");
                                        }
                                      }
                                      Navigator.of(context).pop();
                                      await userProvider.removeUserActivity(authProvider.getUserId() as String, args["userActMeta"].id);
                                      var newUserAct = UserActivity(id: args["userActMeta"].id, displayName: args["userActMeta"].displayName,
                                      tags: newTags);
                                      await userProvider.addUserActivity(authProvider.getUserId() as String, newUserAct, addTag: true);
                                      // await userProvider.updateUserActivity(authProvider.getUserId() as String
                                      //     , newUserAct, updateTag: true);
                                    },
                                    child: Text('確定'),
                                  ),
                                ],
                              );
                            });
                      },
                    ),
                  ),
                )
              : SizedBox(),
          _enable
              ? Positioned(
                  top: _buttonPositionTop,
                  left: _buttonPositionLeft,
                  child: Transform.rotate(
                    angle: _animation.value * 3.14159 * (3 / 4),
                    child: AnimatedContainer(
                        duration: Duration(milliseconds: 375),
                        curve: Curves.easeOut,
                        height: toggle ? 70.0 : 60.0,
                        width: toggle ? 70.0 : 60.0,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(60.0),
                        ),
                        child: Material(
                            color: Colors.transparent,
                            child: IconButton(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface,
                              splashColor: Colors.black54,
                              onPressed: () {
                                setState(() {
                                  if (toggle) {
                                    toggle = !toggle;
                                    _controller.forward();
                                    Future.delayed(Duration(milliseconds: 10),
                                        () {
                                      top1;
                                      left1 = left1 - 100;
                                      size1 = 50;
                                    });
                                    Future.delayed(Duration(milliseconds: 100),
                                        () {
                                      top2 = top2 - 70;
                                      left2 = left2 - 70;
                                      size2 = 50;
                                    });
                                    Future.delayed(Duration(milliseconds: 200),
                                        () {
                                      left3;
                                      top3 = top3 - 100;
                                      size3 = 50;
                                    });
                                  } else {
                                    toggle = !toggle;
                                    _controller.reverse();
                                    top1 =
                                        top2 = top3 = _buttonPositionTop + 10;
                                    left1 = left2 =
                                        left3 = _buttonPositionLeft + 10;
                                    size1 = size2 = size3 = 20.0;
                                  }
                                });
                              },
                              icon: const Icon(
                                Icons.add,
                                size: 30,
                              ),
                            ))),
                  ),
                )
              : SizedBox(),
        ],
      )),
      backgroundColor: Theme.of(context).colorScheme.background,
      floatingActionButtonLocation: buttonPosition,
    );
  }
}





class CardExample extends StatelessWidget {
  const CardExample({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          clipBehavior: Clip.hardEdge,
          elevation: 2,
          child: InkWell(
            onTap: () {},
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.album),
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle:
                      Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      child: const Text('BUY TICKETS'),
                      onPressed: () {/* ... */},
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      child: const Text('LISTEN'),
                      onPressed: () {/* ... */},
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _test =
    """近年來，社會變遷迅速，文化交流日益頻繁，為了促進不同文化之間的對話與理解，我們特別舉辦了一場名為「兩日文化革命」的活動。這個活動將在兩天內展開，帶領參與者探索世界各地的文化風情，促進跨文化的交流合作。

第一天的活動將以講座、工作坊和文化展覽為主，邀請了一系列來自不同文化背景的專家學者，分享他們在文學、藝術、音樂等領域的經驗和見解。透過這些專業的分享，參與者將能夠深入了解各種文化的核心價值和特色，擴展他們的文化視野。

而第二天的活動將更加實踐，我們將進行一場文化體驗之旅。這包括品嚐不同國家的美食、參與傳統手工藝製作、學習民族舞蹈等活動。這將是一個身歷其境的機會，讓參與者親身感受到不同文化的豐富多彩之處。

這場「兩日文化革命」的活動旨在打破文化的藩籬，讓參與者能夠更深入地理解和尊重不同文化，並在交流中找到共通之處。透過這樣的活動，我們期望能夠在社區中建立起更加開放、包容的文化氛圍，促進多元文化的共融發展。無論你是對外交往的專業人士，還是對不同文化充滿好奇心的普通人，都歡迎加入我們，一同參與這場跨足文化的盛宴。""";

String _fakeUrl =
    "https://s.yimg.com/ny/api/res/1.2/_MfVJS26UE1K4xTw7n7t3Q--/YXBwaWQ9aGlnaGxhbmRlcjt3PTY0MDtoPTQyOA--/https://media.zenfs.com/en/news_direct/b33229057cf5c4428dbe4101c9a621fc";
