import 'dart:async';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/src/user.dart';
import '../../providers/providers.dart';
import '../routes.dart';

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
  // late final AuthProviders authProvider = context.read<AuthProviders>();
  late final UserProvider userProvider = context.read<UserProvider>();

  FloatingActionButtonLocation buttonPosition =
      FloatingActionButtonLocation.centerFloat;

  Color buttonColor = Colors.yellow;
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

  bool bottomInitial = false;

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
            child: Text(_formatTime()),
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

  void _initBottomPosition(height, width) {
    if (!bottomInitial) {
      _buttonPositionTop = height - 70;
      _buttonPositionLeft = width - 100;
      bottomInitial = true;
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
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initBottomPosition(
        MediaQuery.of(context).size.height, MediaQuery.of(context).size.width);

    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: Offset(0, 2), // 阴影位置，可以调整阴影的方向
                ),
              ],
            ),
            child: Row(
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
                          color: Theme.of(context).colorScheme.background,
                          child: Text(_appBarTitle,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 50),
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
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: Icon(Icons.message, color: Colors.white),
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
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: IconButton(
                      icon: Text("配對"),
                      onPressed: () async {
                        setState(() {
                          if (!_startMatching) {
                            _startMatching = true;
                            _height = 20;
                            buttonColor = Theme.of(context).colorScheme.primary;
                            _timer = Timer.periodic(
                                const Duration(seconds: 1), _onTimerTick);

                          } else {
                            _startMatching = false;
                            _height = 0;
                            buttonColor =
                                Theme.of(context).colorScheme.secondary;
                            timeShowUp = 0;
                            _timer?.cancel();
                          }
                        });

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
                            ),
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

                        _startMatching = false;
                        _timer?.cancel();

                        setState(() {
                          Navigator.of(context).pushNamed(Routes.chatPage.value);
                        });
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
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: Icon(Icons.abc, color: Colors.white),
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
                          color: Colors.yellow[600],
                          borderRadius: BorderRadius.circular(60.0),
                        ),
                        child: Material(
                            color: Colors.transparent,
                            child: IconButton(
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
      // floatingActionButton: Stack(
      //   children: [
      //     Positioned(
      //       top: _buttonPositionTop,
      //       left: _buttonPositionLeft,
      //       child: Draggable(
      //         onDraggableCanceled: (velocity, offset) {
      //           // 當手指釋放時，計算最近的邊，自動貼到邊上
      //           setState(() {
      //             _buttonPositionTop = offset.dy;
      //             _buttonPositionLeft = offset.dx;
      //             _snapToEdges();
      //           });
      //         },
      //         childWhenDragging: Container(),
      //         feedback: FloatingActionButton(
      //           onPressed: () {},
      //           child: const Icon(Icons.add),
      //         ),
      //         child: FloatingActionButton(
      //           backgroundColor: buttonColor,
      //           onPressed: () {
      //             setState(() {
      //               if (!_startMatching) {
      //                 _startMatching = true;
      //                 _height = 20;
      //                 buttonColor = Theme.of(context).colorScheme.primary;
      //                 _timer = Timer.periodic(
      //                     const Duration(seconds: 1), _onTimerTick);
      //               } else {
      //                 _startMatching = false;
      //                 _height = 0;
      //                 buttonColor = Theme.of(context).colorScheme.secondary;
      //                 timeShowUp = 0;
      //                 _timer?.cancel();
      //               }
      //             });
      //           },
      //           child: Text(
      //             "配對",
      //             style: TextStyle(
      //               color: Theme.of(context).colorScheme.onPrimary,
      //             ),
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
      backgroundColor: Theme.of(context).colorScheme.background,
      floatingActionButtonLocation: buttonPosition,
    );
  }
}

class ActivityMainContent extends StatelessWidget {
  const ActivityMainContent(
      {super.key, required this.date, required this.imageUrl});

  final String imageUrl;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StartDateCard(date: "日期資料"),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.arrow_forward),
                      ),
                      EndDateCard(date: "日期資料"),
                    ],
                  ),
                )),
            Card(
              clipBehavior: Clip.hardEdge,
              elevation: 10,
              shadowColor: Theme.of(context).colorScheme.primary,
              child: Container(
                child: Image.network(
                  imageUrl,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityDescription extends StatelessWidget {
  const ActivityDescription({super.key, required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          color: Theme.of(context).colorScheme.surface,
          clipBehavior: Clip.hardEdge,
          elevation: 2,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StartDateCard extends StatelessWidget {
  const StartDateCard({super.key, required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
        color: const Color(0xFF8EA373),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "AUG",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 10),
          Text("31",
              style: TextStyle(
                fontSize: 30,
                // fontWeight: FontWeight.w600
                color: Theme.of(context).colorScheme.secondary,
              )),
          const SizedBox(width: 10),
          Text(
            "THU",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class EndDateCard extends StatelessWidget {
  const EndDateCard({super.key, required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
        color: const Color(0xFF8EA373),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "SEP",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 10),
          Text("02",
              style: TextStyle(
                fontSize: 30,
                // fontWeight: FontWeight.w600
                color: Theme.of(context).colorScheme.secondary,
              )),
          const SizedBox(width: 10),
          Text(
            "SAT",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
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
