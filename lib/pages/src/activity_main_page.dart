import 'dart:async';
import 'dart:isolate';

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:async/async.dart';
import 'package:resonance_chatroom/widgets/src/activity_buttons/host_buttons.dart';
import 'package:resonance_chatroom/widgets/src/confirm_buttons.dart';

import '../../widgets/src/public/quit_warning_dialog.dart';
import '../routes.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../../providers/providers.dart';
import '../../widgets/src/activity_card/activity_card.dart';
import '../../widgets/src/activity_buttons/user_buttons.dart';

class ActivityMainPageArguments {
  // final ;
  final String activityId;
  final bool isHost;

  ActivityMainPageArguments({required this.isHost, required this.activityId});
}

class ActivityMainPage extends StatefulWidget {
  const ActivityMainPage({super.key});

  static const routeName = "/activity_main_page";

  @override
  State<ActivityMainPage> createState() => _ActivityMainPageState();
}

class _ActivityMainPageState extends State<ActivityMainPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  final AsyncMemoizer _memoization = AsyncMemoizer<void>();

  late final ChatProvider chatProvider = context.read<ChatProvider>();
  late final AuthProvider authProvider = context.read<AuthProvider>();
  late final UserProvider userProvider = context.read<UserProvider>();
  late final ActivityProvider activityProvider =
      context.read<ActivityProvider>();

  late final args =
      ModalRoute.of(context)!.settings.arguments as ActivityMainPageArguments;
  late final _currentUser;
  late final _currentUserActivity;
  late final _image;
  late int _currentActivityPoints;

  FloatingActionButtonLocation buttonPosition =
      FloatingActionButtonLocation.centerFloat;

  String? _deletePointsString;

  double _height = 0;
  Timer? _timer;
  int timeShowUp = 0;


  // 到時候會從 activity_provider 那邊抓資料
  late final Activity _currentActivity;

  late final List<Tag> _currentActivityTags;
  late List<bool> _tagSelected;

  bool _enableTagWidget = false;
  bool _enableMatch = false;
  bool isStartMatching = false;
  bool initial = false;
  bool isTryChangingPoints = false;

  void _onTimerTick(Timer timer) {
    setState(() {
      // 每1秒更新一次計數器
      timeShowUp++;
    });
  }

  Future<String?> _matchingChecker() async {
    while (true) {
      if (await chatProvider.isWaiting(args.activityId)) {
        await Future.delayed(const Duration(seconds: 1));
      } else {
        if (isStartMatching) {
          var peerId = await chatProvider.getChatToUserId(args.activityId);
          debugPrint("peerId:${peerId ?? "no"}, currentId:${_currentUser.uid}");
          return peerId;
        } else {
          return null; // 退出
        }
      }
    }
  }

  void matching() async {
    if (isStartMatching) {
      setState(() {
        _height = 0;
        timeShowUp = 0;
        _enableMatch = false;
        isStartMatching = false;
      });
      try {
        await chatProvider.cancelWaiting(args.activityId);
      } catch (e) {
        debugPrint("cancelWaitingError: $e");
      } finally {
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _enableMatch = true;
            _timer?.cancel();
          });
        });
      }
    } else {
      setState(() {
        _timer = Timer.periodic(const Duration(seconds: 1), _onTimerTick);
        _height = 20;
        _enableMatch = false;
      });
      String? peerId;
      try {
        peerId = await chatProvider.getChatToUserId(args.activityId);
      } catch (e) {
        debugPrint("$e");
      }
      if (peerId == null) {
        setState(() {
          _enableMatch = true;
          isStartMatching = true;
        });
        // 在等待
        peerId = await _matchingChecker();
        if (peerId != null) {
          _getIntRoom(peerId);
        }
        // peerId == null, 代表我可能主動退出了
      } else {
        _enableMatch = true;
        _getIntRoom(peerId);
      }
    }
  }

  void _getIntRoom(peerId) async {
    isStartMatching = false;
    timeShowUp = 0;
    _timer?.cancel();
    setState(() {
      _height = 0;
      Navigator.of(context).pushNamed(ChatPage.routeName,
          arguments: ChatPageArguments(
              activityId: _currentActivity.uid,
              peerId: peerId,
              isHistorical: false));
    });
  }

  void _goToHistoricalChatRoomPage() {
    Navigator.of(context).pushNamed(
      HistoricalChatRoomPage.routeName,
      arguments: HistoricalChatRoomPageArguments(
        activityId: _currentActivity.uid,
      ),
    );
  }

  Future<void> changeTagAndName(
      TextEditingController textEditingController, List<bool> tagTmp) async {
    _tagSelected = tagTmp;
    var newUserTags = <String>[];
    int cnt = 0;
    for (int i = 0; i < _tagSelected.length; i++) {
      if (_tagSelected[i]) {
        cnt++;
        newUserTags.add(_currentActivityTags[i].uid);
      }
    }
    _enableMatch = false;
    var newName = textEditingController.text;
    if (newName != _currentUser.displayName && newName.isNotEmpty) {
      _currentUser.displayName = textEditingController.text;
      await userProvider.updateUser(_currentUser);
    }
    await userProvider.updateUserTag(args.activityId, newUserTags);
    if (cnt > 0) {
      _enableMatch = true;
    }
    setState(() {});
  }

  String _formatTime() {
    int minutes = timeShowUp ~/ 60;
    int remainingSeconds = timeShowUp % 60;

    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget? _subTitle() {
    if (!isStartMatching) {
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

  /// 初始化
  /// fetch 使用者標籤，並使用 List<bool> 來記錄使用者之前所勾選的標籤
  void _initSetTag() {
    int cnt = 0;
    Map<String, bool> map = {
      for (var item in _currentActivityTags) item.uid: false
    };
    for (var i in _currentUserActivity.tagIds) {
      cnt++;
      map[i] = true;
    }
    if (cnt == 0) {
      _enableMatch = false;
    } else {
      _enableMatch = true;
    }
    _tagSelected = List.generate(_currentActivityTags.length, (index) => false);
    int i = 0;
    map.forEach((key, value) {
      _tagSelected[i++] = value;
    });
  }

  void _initImage() {
    _image = Image.memory(base64ToImage(_currentActivity.activityPhoto));
  }

  Future<void> _initActivityContent() async {
    // set _description
    // set _appBarTitle
    // set _currentUser
    // set _currentUserActivity

    _currentUser = await authProvider.currentUser;
    _currentUserActivity = await userProvider.getUserActivity(args.activityId,
        isManager: args.isHost);
    var getActivity = await activityProvider.getActivity(args.activityId);

    if (getActivity != null) {
      _currentActivity = getActivity;
    } else {
      Navigator.of(context).pop();
    }

    var getTags = await activityProvider.getAllTags(args.activityId);

    if (getTags != null) {
      _enableTagWidget = true;
      _currentActivityTags = getTags;
    }
  }

  Future<void> _initPoints() async {
    try{
      _currentActivityPoints = await userProvider.getUserActivityPoint(args.activityId);
    } catch (e) {
      debugPrint("_initPointsError: $e");
      _currentActivityPoints = 0;
    }
  }

  Future<void> _init() async {
    if (!initial) {
      await _initActivityContent();
      _initSetTag();
      _initImage();
      if(!args.isHost) await _initPoints();
      initial = true;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _memoization.runOnce(_init),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 如果 Future 還在執行中，返回 loading UI
            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.background,
              body: Center(
                  child: Container(
                      width: 100,
                      height: 100,
                      child: const CircularProgressIndicator())),
            );
          } else if (snapshot.hasError) {
            // 如果 Future 發生錯誤，返回錯誤 UI
            return Text('Error: ${snapshot.error}');
          } else {
            // 如果 Future 完成，返回數據 UI
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
                        Container(
                          height: kToolbarHeight,
                          child: Stack(
                            alignment: AlignmentDirectional.centerStart,
                            children: [
                              BackButton(
                                onPressed: () async {
                                  if (isStartMatching) {
                                    await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return QuitWarningDialog(
                                            action: () async {
                                              isStartMatching = false;
                                              // _height = 0;
                                              try {
                                                await chatProvider
                                                    .cancelWaiting(
                                                        args.activityId);
                                              } catch (e) {
                                                debugPrint(
                                                    "cancelWaitingError: $e");
                                              }
                                              setState(() {
                                                Navigator.of(context).popUntil(
                                                    ModalRoute.withName(
                                                        MainPage.routeName));
                                              });
                                            },
                                          );
                                        });
                                  } else {
                                    setState(() {
                                      Navigator.of(context).popUntil(
                                          ModalRoute.withName(
                                              MainPage.routeName));
                                    });
                                  }
                                },
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2, horizontal: 20.0),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.2),
                                            offset: const Offset(2, 2),
                                            blurRadius: 2,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Text(_currentActivity.activityName.length > 10 ?
                                      _currentActivity.activityName.substring(0, 8) + "..." : _currentActivity.activityName,
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
                              // const SizedBox(width: 50),
                              args.isHost
                                  ? Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10.0),
                                        child: IconButton(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            iconSize: 30,
                                            icon: const Icon(
                                              Icons.person,
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pushNamed(
                                                  ManagerPage.routeName,
                                                  arguments: ManagerArguments(
                                                      activityId:
                                                          args.activityId));
                                            }),
                                      ),
                                    )
                                  : Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 20.0),
                                          child: Container(
                                            padding: EdgeInsets.only(left: 8, top: 2, bottom: 2, right: 12),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.8),
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.2),
                                                  offset: const Offset(2, 2),
                                                  blurRadius: 2,
                                                  spreadRadius: 1,
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.currency_bitcoin,
                                                color: Color(0xffffb300),),
                                                Text(_currentActivityPoints.toString(), style: TextStyle(
                                                  color: Colors.yellow,
                                                )),
                                              ],
                                            ),
                                          ),
                                        ),
                                        onTap: (){
                                          showDialog(context: context, builder: (BuildContext context){
                                            return AlertDialog(
                                              title: Text("要扣多少點數？"),
                                              content: TextField(
                                                controller: TextEditingController(),
                                                onChanged: (value){
                                                  _deletePointsString = value;
                                                },
                                              ),
                                              actions: confirmButtons(context,
                                                  action:() async {
                                                    if(!isTryChangingPoints) {
                                                      isTryChangingPoints = true;
                                                      int deletePoints = 0;
                                                      try {
                                                        deletePoints = int.parse(_deletePointsString!);
                                                        await userProvider.minusUserActivityPoint(args.activityId, deletePoints);
                                                        _currentActivityPoints -= deletePoints;
                                                        setState(() {
                                                          Navigator.of(context).pop();
                                                        });
                                                      } catch (e) {
                                                        debugPrint("_changePointsError $e");
                                                        Fluttertoast.showToast(msg: "無效輸入");
                                                      }
                                                      isTryChangingPoints = false;
                                                    }
                                                },
                                                  cancel: (){
                                                Navigator.of(context).pop();
                                              })
                                            );
                                          });
                                        },
                                      ),
                                    ),
                            ],
                          ),
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
                            startDate: _currentActivity.startDate.toEpochTime(),
                            endDate: _currentActivity.endDate.toEpochTime(),
                            image: _image),
                        ActivityDescription(
                          description:
                              _currentActivity.activityInfo, // 這邊會給過是最前面檢查過
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
              floatingActionButton: args.isHost
                  ? HostButtons(
                      enableStopActivity: true,
                      enableStatistic: true,
                      enableUpdateActivity: true,
                      activityId: args.activityId,
                      isEnableActivity: _currentActivity.isEnabled,
                    )
                  : UserButtons(
                      enableTagWidget: _enableTagWidget,
                      enableHistoricalChatRoom: true,
                      enableMatch: _enableMatch,
                      matching: matching,
                      goToHistoricalChatRoomPage: _goToHistoricalChatRoomPage,
                      startMatching: isStartMatching,
                      tagSelected: _tagSelected,
                      currentActivityTags: _currentActivityTags,
                      changeTagAndName: changeTagAndName,
                      currentUserName: _currentUser.displayName,
                    ),
              backgroundColor: Theme.of(context).colorScheme.background,
              // floatingActionButtonLocation: buttonPosition,
            );
          }
        });
  }
}
