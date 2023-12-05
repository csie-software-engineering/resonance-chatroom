import 'dart:async';
import 'package:flutter/material.dart';

class UserActivityMainPage extends StatefulWidget {
  const UserActivityMainPage({super.key});

  @override
  State<UserActivityMainPage> createState() => _UserActivityMainPageState();
}

class _UserActivityMainPageState extends State<UserActivityMainPage> {
  FloatingActionButtonLocation buttonPosition =
      FloatingActionButtonLocation.centerFloat;

  Color buttonColor = Colors.yellow;
  bool _startMatching = false;

  late double _buttonPositionTop;
  late double _buttonPositionLeft;

  double _height = 0;
  Timer? _timer;
  int timeShowUp = 0;

  late String appBarTitle = "三峽科技人 CTW";

  bool bottomInitial = false;

  Widget? _subTitle() {
    if (!_startMatching) {
      return AnimatedContainer(
        duration: Duration(milliseconds: 500),
        color: Theme.of(context).colorScheme.surface,
        child: AnimatedOpacity(
          opacity: 0,
          duration: Duration(milliseconds: 1000),
          child: Center(
            child: Text(_formatTime()),
          ),
        ),
      );
    } else {
      return AnimatedContainer(
        curve: Curves.easeIn,
        duration: Duration(milliseconds: 500),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 2,
              offset: Offset(0, 5), // 阴影位置，可以调整阴影的方向
            ),
          ],
        ),
        child: AnimatedOpacity(
          opacity: 1,
          duration: Duration(milliseconds: 1000),
          child: Center(
            child: Text(_formatTime()),
          ),
        ),
      );
    }
  }

  void _snapToEdges() {
    // 可以根據需要調整邊界的距離
    double threshold = 20.0;

    // 獲取屏幕的尺寸
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // 計算最近的邊
    double bottomEdge = screenHeight - _buttonPositionTop;
    double leftEdge = _buttonPositionLeft;
    double rightEdge = screenWidth - _buttonPositionLeft;

    // 根據距離最近的邊自動調整按鈕位置
    double minVerticalDistance = bottomEdge;
    double minHorizontalDistance = leftEdge < rightEdge ? leftEdge : rightEdge;

    if (minVerticalDistance < minHorizontalDistance) {
      _buttonPositionTop = screenHeight - threshold - 50;
    } else {
      _buttonPositionLeft =
          leftEdge < rightEdge ? 0 + threshold : screenWidth - threshold - 50;
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
  }

  @override
  void initState() {
    super.initState();
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
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    height: kToolbarHeight,
                    child: Center(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(16)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 20.0),
                          color: Theme.of(context).colorScheme.background,
                          child: Text(
                              appBarTitle,
                            style: TextStyle(fontSize: 20)
                          ),
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
                ActivityMainContent(title: "人工智畫大爆炸"),
                ActivityDiscreption(title: "日程"),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            top: _buttonPositionTop,
            left: _buttonPositionLeft,
            child: Draggable(
              onDraggableCanceled: (velocity, offset) {
                // 當手指釋放時，計算最近的邊，自動貼到邊上
                setState(() {
                  _buttonPositionTop = offset.dy;
                  _buttonPositionLeft = offset.dx;
                  _snapToEdges();
                });
              },
              childWhenDragging: Container(),
              feedback: FloatingActionButton(
                onPressed: () {},
                child: Icon(Icons.add),
              ),
              child: FloatingActionButton(
                backgroundColor: buttonColor,
                onPressed: () {
                  setState(() {
                    if (!_startMatching) {
                      _startMatching = true;
                      _height = 20;
                      buttonColor = Theme.of(context).colorScheme.primary;
                      _timer =
                          Timer.periodic(Duration(seconds: 1), _onTimerTick);
                    } else {
                      _startMatching = false;
                      _height = 0;
                      buttonColor = Theme.of(context).colorScheme.secondary;
                      timeShowUp = 0;
                      _timer?.cancel();
                    }
                  });
                },
                child: Text(
                  "配對",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      floatingActionButtonLocation: buttonPosition,
    );
  }
}

class ActivityMainContent extends StatelessWidget {
  const ActivityMainContent({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          clipBehavior: Clip.hardEdge,
          elevation: 10,
          shadowColor: Theme.of(context).colorScheme.primary,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 0, 5),
                child: Text(
                  title,
                  style: TextStyle(
                    color: Color(0xFF095344),
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 0, 10),
                child: Text(
                  "1/10 ~ 1/12",
                  style: TextStyle(
                    color: Color(0xFF095344),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                child: Image.network(
                    "https://s.yimg.com/ny/api/res/1.2/_MfVJS26UE1K4xTw7n7t3Q--/YXBwaWQ9aGlnaGxhbmRlcjt3PTY0MDtoPTQyOA--/https://media.zenfs.com/en/news_direct/b33229057cf5c4428dbe4101c9a621fc"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActivityDiscreption extends StatelessWidget {
  const ActivityDiscreption({super.key, required this.title});

  final String title;

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
                  test,
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
                  leading: Icon(Icons.album),
                  title: Text(
                    title,
                    style: TextStyle(
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

String test =
    """近年來，社會變遷迅速，文化交流日益頻繁，為了促進不同文化之間的對話與理解，我們特別舉辦了一場名為「兩日文化革命」的活動。這個活動將在兩天內展開，帶領參與者探索世界各地的文化風情，促進跨文化的交流合作。

第一天的活動將以講座、工作坊和文化展覽為主，邀請了一系列來自不同文化背景的專家學者，分享他們在文學、藝術、音樂等領域的經驗和見解。透過這些專業的分享，參與者將能夠深入了解各種文化的核心價值和特色，擴展他們的文化視野。

而第二天的活動將更加實踐，我們將進行一場文化體驗之旅。這包括品嚐不同國家的美食、參與傳統手工藝製作、學習民族舞蹈等活動。這將是一個身歷其境的機會，讓參與者親身感受到不同文化的豐富多彩之處。

這場「兩日文化革命」的活動旨在打破文化的藩籬，讓參與者能夠更深入地理解和尊重不同文化，並在交流中找到共通之處。透過這樣的活動，我們期望能夠在社區中建立起更加開放、包容的文化氛圍，促進多元文化的共融發展。無論你是對外交往的專業人士，還是對不同文化充滿好奇心的普通人，都歡迎加入我們，一同參與這場跨足文化的盛宴。""";
