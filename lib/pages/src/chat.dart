import 'dart:ui';
import 'package:async/async.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:resonance_chatroom/models/models.dart';
import 'package:resonance_chatroom/pages/src/activity_main_page.dart';
import 'package:resonance_chatroom/widgets/src/public/quit_warning_dialog.dart';
import 'package:resonance_chatroom/widgets/widgets.dart';
import 'package:resonance_chatroom/providers/providers.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/src/chat_components/questionDialog.dart';
import '../../constants/src/firestore_constants.dart';
import '../../widgets/src/input/widgets.dart';

class ChatPageArguments {
  final String peerId;
  final String activityId;
  final bool isHistorical;

  ChatPageArguments(
      {required this.isHistorical,
      required this.activityId,
      required this.peerId});
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  // get inputOptions => null;
  static const routeName = '/chat';

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatPageArguments args =
      ModalRoute.of(context)!.settings.arguments as ChatPageArguments;
  late final User currentUser;
  late final User peerUser;
  late final Room room;
  late final String _tagName;
  late bool _isEnableSocialMedial = false;
  late final Map<String, String> _allTopics;

  late final ChatProvider chatProvider = context.read<ChatProvider>();
  late final AuthProvider authProvider = context.read<AuthProvider>();
  late final UserProvider userProvider = context.read<UserProvider>();
  late final ActivityProvider activityProvider =
      context.read<ActivityProvider>();
  late final QuestionProvider questionProvider =
      context.read<QuestionProvider>();

  final AsyncMemoizer _initalPageMemoization = AsyncMemoizer<void>();

  // final AsyncMemoizer _socialMedialMemoization = AsyncMemoizer<void>();
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController reportTextController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  int _limit = 20;
  final int _limitIncrement = 20;
  double _height = 0;
  String _currentTopicId = "";
  String _previousTopicId = "";
  Question? _currentQuestion;
  List<bool>? _questionAnswers;

  bool isOn = false;
  bool isLoading = false;
  bool isShowSticker = false;
  bool initial = false;
  bool _isAlreadyReport = false;
  bool _enableShowTopic = true;
  List<bool>? isTryLaunchUrl;

  List<QueryDocumentSnapshot> _chatMessages = [];

  Future<void> onSendMessage(String content, MessageType type) async {
    if (content.trim().isNotEmpty) {
      try {
        await chatProvider.sendMessage(
            args.activityId, args.peerId, content, type);
        textEditingController.clear();
        if (listScrollController.hasClients) {
          listScrollController.animateTo(0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
        }
      } catch (e) {

        if(e is FormatException){
          debugPrint("_onSendMessageFormatException: $e");
          Fluttertoast.showToast(
              msg: '對方已離開，無法傳送訊息',
              backgroundColor: Theme.of(context).colorScheme.onSurface,
              textColor: Theme.of(context).colorScheme.onInverseSurface);
        } else {
          debugPrint("_onSendMessageError: $e");
        }

      }
    } else {
      // 當沒有文字的時候
      Fluttertoast.showToast(
          msg: 'Nothing to send',
          backgroundColor: Theme.of(context).colorScheme.onSurface,
          textColor: Theme.of(context).colorScheme.onInverseSurface);
    }
  }

  // Widget? _subTitle() {
  //
  // }

  Future<void> nextTopic() async {
    await chatProvider.updateRandomTopic(args.activityId, args.peerId);
  }

  Future<void> enableSocialMedia() async {
    // 我覺得可以直接寫在 input 那邊
    if (_isEnableSocialMedial) {
      Fluttertoast.showToast(msg: "已分享");
    } else {
      _isEnableSocialMedial = true;
      try {
        await chatProvider.agreeShareSocialMedia(args.activityId, args.peerId);
      } catch (e) {
        // todo 應該要抓對應錯誤
        debugPrint("$e");
      }
    }
  }

  void _newQuestion() async {
    // todo 抓錯誤
    try {
      _currentQuestion = await activityProvider.getQuestionByTopic(
          args.activityId, _previousTopicId);
      setState(() {
        isOn = true;
      });
    } catch (e) {
      debugPrint("getNewQuestionError:$e");
    }
  }

  Future<List<UserSocialMedia>?> _getPeerSocialMedia() async {
    List<UserSocialMedia>? peerSocialMedia;
    try {
      peerSocialMedia =
          await chatProvider.getOtherSocialMedium(args.activityId, args.peerId);
    } catch (e) {
      // todo 應該要抓對應錯誤，如果是這樣代表對方沒有同意
      peerSocialMedia = null;
    } finally {
      return peerSocialMedia;
    }
  }

  // void _launchURL(String url) async {
  //   if (await launchUrl(url)) {
  //     await launch(url);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
  }

  Future<void> _init() async {
    if (!initial) {
      // await chatProvider.disagreeShareSocialMedia(args.activityId, args.peerId);
      try {
        _isEnableSocialMedial = await chatProvider.getIsAgreeShareSocialMedia(
            args.activityId, args.peerId);
      } catch (e) {
        debugPrint("_initgetIsAgreeShareSocialMediaError: $e");
      }

      peerUser = await userProvider.getUser(
          userId: args.peerId);

      room = await chatProvider.getRoom(args.activityId, args.peerId);
      currentUser = await authProvider.currentUser;
      _tagName =
          (await activityProvider.getTag(args.activityId, room.tagId)).tagName;
      debugPrint("tagName:$_tagName");
      List<Topic> topics =
          await activityProvider.getTopicsByTag(args.activityId, room.tagId);
      _allTopics = <String, String>{};
      topics.forEach((element) {
        _allTopics[element.uid] = element.topicName;
      });
      _currentTopicId = room.topicId ?? "";
      if (_currentTopicId == "") {
        _enableShowTopic = false;
      }
      initial = true;
    }
    debugPrint("init_over");
  }

  _scrollListener() {
    if (!listScrollController.hasClients) return;
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange &&
        _limit <= _chatMessages.length) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  Widget buildItem(int index, DocumentSnapshot? document) {
    if (document != null) {
      ChatMessage messageChat = ChatMessage.fromDocument(document);
      if (messageChat.fromId == currentUser.uid) {
        // Right (my message)
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            messageChat.type == MessageType.text
                // Text
                ? Container(
                    padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                    constraints: const BoxConstraints(maxWidth: 200),
                    // width: messageChat.content.length,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        borderRadius: BorderRadius.circular(20)),
                    margin: const EdgeInsets.only(
                        // bottom: isLastMessageRight(index) ? 20 : 10, right: 10),
                        bottom: 10,
                        right: 10),
                    child: Text(
                      messageChat.content,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ))
                // Sticker
                : Container(
                    margin: EdgeInsets.only(bottom: 10, right: 10),
                    child: Image.asset(
                      'images/${messageChat.content}.gif',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
          ],
        );
      } else {
        // Left (peer message)
        return Container(
          // margin: EdgeInsets.only(bottom: 10),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Material(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(18),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          enableDrag: false,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30))),
                          // backgroundColor: Colors.red.withOpacity(0),

                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 20),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                        border: Border(
                                      bottom: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.1),
                                        width: 2,
                                      ),
                                    )),
                                    child: Row(
                                      children: [
                                        ClipOval(
                                          child: Container(
                                              height: 80,
                                              width: 80,
                                              child: CircleAvatar(
                                                child: Image.network(
                                                  peerUser.photoUrl ?? "空照片",
                                                  // 會是一個 url 載入使用者的頭貼
                                                  loadingBuilder:
                                                      (BuildContext context,
                                                          Widget child,
                                                          ImageChunkEvent?
                                                              loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                      value: loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              loadingProgress
                                                                  .expectedTotalBytes!
                                                          : null,
                                                    ));
                                                  },
                                                  errorBuilder: (context,
                                                      object, stackTrace) {
                                                    // 當圖片無法加載就會顯示預設圖片
                                                    return Icon(
                                                      Icons.account_circle,
                                                      size: 35,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                    );
                                                  },
                                                  fit: BoxFit.cover,
                                                ),
                                              )),
                                        ),
                                        Container(
                                          width: 220,
                                          padding: EdgeInsets.only(left: 20),
                                          child: Text(peerUser.displayName,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              )),
                                        ),
                                        Expanded(
                                          child: Align(
                                              alignment: Alignment.centerRight,
                                              child: !_isAlreadyReport
                                                  ? IconButton(
                                                      iconSize: 30,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .error
                                                          .withOpacity(0.5),
                                                      icon: Icon(Icons
                                                          .warning_rounded),
                                                      onPressed: () {
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                    '請輸入原因'),
                                                                content:
                                                                    TextField(
                                                                  controller:
                                                                      reportTextController,
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      chatProvider.report(
                                                                          args
                                                                              .activityId,
                                                                          args
                                                                              .peerId,
                                                                          "惡意言論",
                                                                          reportTextController
                                                                              .text);
                                                                      reportTextController
                                                                          .clear();
                                                                      setState(
                                                                          () {
                                                                        _isAlreadyReport =
                                                                            true;
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      }); // 关闭对话框
                                                                    },
                                                                    child: Text(
                                                                        '确定'),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      // 串接舉報按鈕
                                                                      setState(
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      }); // 关闭对话框
                                                                    },
                                                                    child: Text(
                                                                        '取消'),
                                                                  ),
                                                                ],
                                                              );
                                                            });
                                                      },
                                                    )
                                                  : IconButton(
                                                      onPressed: () {
                                                        Fluttertoast.showToast(
                                                            msg: "已舉報",
                                                            backgroundColor:
                                                                Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onSurface,
                                                            textColor: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onInverseSurface);
                                                      },
                                                      icon: Icon(Icons
                                                          .disabled_by_default),
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface
                                                          .withOpacity(0.5),
                                                    )),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(top: 20, bottom: 10),
                                      child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Text("社群媒體連結",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ))),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: FutureBuilder(
                                        future: _getPeerSocialMedia(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            // 如果 Future 還在執行中，返回 loading UI
                                            return Scaffold(
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .background,
                                              body: Center(
                                                  child: Container(
                                                      width: 100,
                                                      height: 100,
                                                      child:
                                                          const CircularProgressIndicator())),
                                            );
                                          } else if (snapshot.hasError) {
                                            // 如果 Future 發生錯誤，返回錯誤 UI
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else {
                                            if(snapshot.data != null){
                                              isTryLaunchUrl = List.generate(snapshot.data!.length, (index) => false);
                                            }
                                            return snapshot.data != null
                                                ? Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .inversePrimary
                                                                .withOpacity(
                                                                    0.5),
                                                            borderRadius: const BorderRadius
                                                                .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        10)),
                                                          ),
                                                          child: Center(
                                                              child: Text(
                                                                  "對方已公開")),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Container(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .onInverseSurface,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10.0),
                                                            child: ListView
                                                                .builder(
                                                              itemCount:
                                                                  snapshot.data!
                                                                      .length,
                                                              itemBuilder:
                                                                  (BuildContext
                                                                          context,
                                                                      int index) {
                                                                return Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              10),
                                                                  child: Row(
                                                                    children: [
                                                                      IconButton(
                                                                          icon: const Icon(Icons
                                                                              .add_circle_rounded),
                                                                          iconSize:
                                                                              30,
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .error
                                                                              .withOpacity(
                                                                                  0.3),
                                                                          onPressed:
                                                                              () async {
                                                                            // todo launch;
                                                                                if(!isTryLaunchUrl![index]) {
                                                                                  isTryLaunchUrl![index] = true;
                                                                                    try {
                                                                                      snapshot.data![index].linkUrl;
                                                                                      Uri url = Uri.parse(snapshot.data![index].linkUrl);
                                                                                      if (!await launchUrl(url)) {
                                                                                        throw Exception('Could not launch $url');
                                                                                        }
                                                                                    } catch (e) {
                                                                                      debugPrint("_launchSocialMedialError: $e");
                                                                                      Fluttertoast.showToast(msg: "連結有誤無法點開");
                                                                                    }
                                                                                    isTryLaunchUrl![index] = false;
                                                                                }
                                                                          }),
                                                                      Container(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                15,
                                                                            vertical:
                                                                                8),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .error
                                                                              .withOpacity(0.3),
                                                                          borderRadius:
                                                                              BorderRadius.circular(20),
                                                                        ),
                                                                        child: Text(
                                                                            snapshot.data![index].displayName,
                                                                            style: const TextStyle(
                                                                              fontWeight: FontWeight.w700,
                                                                              fontSize: 15,
                                                                            )),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Container(
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface
                                                          .withOpacity(0.05),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Center(
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 20),
                                                        child: Text(
                                                          "尚未公開",
                                                          style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSurface
                                                                .withOpacity(
                                                                    0.5),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                          }
                                        }),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Image.network(
                        peerUser.photoUrl ?? "空照片", // 會是一個 url 載入使用者的頭貼
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                              child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ));
                        },
                        errorBuilder: (context, object, stackTrace) {
                          // 當圖片無法加載就會顯示預設圖片
                          return Icon(
                            Icons.account_circle,
                            size: 35,
                            color: Theme.of(context).colorScheme.primary,
                          );
                        },
                        width: 35,
                        height: 35,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  messageChat.type == MessageType.text
                      ? Container(
                          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                          constraints: const BoxConstraints(maxWidth: 200),
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .inverseSurface
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20)),
                          margin: EdgeInsets.only(bottom: 10, left: 10),
                          child: Text(
                            messageChat.content,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface),
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.only(
                              // bottom: isLastMessageRight(index) ? 20 : 10,
                              bottom: 10,
                              right: 10),
                          child: const Icon(Icons.not_accessible)),
                ],
              ),
            ],
          ),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initalPageMemoization.runOnce(_init),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 如果 Future 還在執行中，返回 loading UI
            return Center(
                child: Container(
                    width: 100,
                    height: 100,
                    child: const CircularProgressIndicator()));
          } else if (snapshot.hasError) {
            // 如果 Future 發生錯誤，返回錯誤 UI
            return Text('Error: ${snapshot.error}');
          } else {
            debugPrint("all topics:${_allTopics.length}");
            return Scaffold(
              body: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top),
                  Container(
                    height: kToolbarHeight,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.9),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(0, 2), // 阴影位置，可以调整阴影的方向
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            color: Theme.of(context)
                                .colorScheme
                                .surface
                                .withOpacity(0.5),
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.7),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(16)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.2),
                                        offset: const Offset(2, 2),
                                        blurRadius: 2,
                                        spreadRadius: 1,
                                      )
                                    ]),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 3, horizontal: 20.0),
                                child: Text(_tagName,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onInverseSurface,
                                    )),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: BackButton(
                            color: Theme.of(context).colorScheme.onSurface,
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return QuitWarningDialog(action: () async {
                                      // todo 抓錯誤
                                      try {
                                        await chatProvider.leaveRoom(
                                            args.activityId, args.peerId);
                                      } catch (e) {
                                        if(e is! FormatException) {
                                          debugPrint("leaveRoomError:$e");
                                        }
                                      } finally {
                                        setState(() {
                                          Navigator.popUntil(
                                              context,
                                              ModalRoute.withName(
                                                  ActivityMainPage.routeName));
                                        });
                                      }
                                    });
                                  });
                            },
                          ),
                        ),
                        args.isHistorical
                            ? const SizedBox()
                            : Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.2),
                                          offset: const Offset(2, 2),
                                          blurRadius: 2,
                                          spreadRadius: 1,
                                        )
                                      ],
                                    ),
                                    child: IconButton(
                                      iconSize: 25,
                                      icon: Icon(isOn
                                          ? Icons.lightbulb
                                          : Icons.lightbulb_outline),
                                      color: isOn
                                          ? Colors.amber
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                      onPressed: () {
                                        if (isOn && _currentQuestion != null) {
                                          setState(() {
                                            isOn = false;
                                          });
                                          showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (BuildContext context) {
                                              _questionAnswers = List.generate(
                                                  _currentQuestion!
                                                      .choices.length,
                                                  (index) => false);
                                              return AlertDialog(
                                                  title: Text(_currentQuestion!
                                                      .questionName),
                                                  content: Container(
                                                    width: 230,
                                                    height: 200,
                                                    child: QuestionDialog(
                                                      questionAnswers:
                                                          _questionAnswers!,
                                                      currentQuestion:
                                                          _currentQuestion!,
                                                    ),
                                                  ),
                                                  actions:
                                                      confirmButtons(context,
                                                          action: () async {
                                                    Navigator.of(context).pop();
                                                    // todo 不知道 choice 要傳什麼
                                                    String? choice = "";

                                                    for (int i = 0;
                                                        i <
                                                            _questionAnswers!
                                                                .length;
                                                        i++) {
                                                      if (_questionAnswers![i]) {
                                                        choice =
                                                            _currentQuestion!
                                                                .choices[i];
                                                      }
                                                    }

                                                    // todo 抓錯誤
                                                    try {
                                                      debugPrint(
                                                          "choice: ${choice}");
                                                      await questionProvider
                                                          .userAnswer(
                                                              args.activityId,
                                                              _currentQuestion!
                                                                  .uid,
                                                              choice!);
                                                    } catch (e) {
                                                      debugPrint(
                                                          "answerQuesitonError:$e");
                                                    }
                                                  }, cancel: () {
                                                    Navigator.of(context).pop();
                                                  })
                                                  );
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              )
                      ],
                    ),
                  ),
                  _allTopics.isEmpty || args.isHistorical
                      ? const SizedBox()
                      : StreamBuilder<DocumentSnapshot>(
                          stream: chatProvider.getRoomStream(
                              args.activityId, args.peerId),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            Map<String, dynamic>? room =
                                snapshot.data?.data() as Map<String, dynamic>?;
                            // debugPrint("topic: ${_allTopics[room!["topicId"]]}");
                            if (room != null &&
                                room.isNotEmpty &&
                                room["topicId"] != _currentTopicId) {
                              _enableShowTopic = true;
                              _previousTopicId = _currentTopicId;
                              _currentTopicId = room["topicId"];
                              _height = 50;
                              _newQuestion();
                            } else {
                              if (_enableShowTopic) {
                                _height = 50;
                              } else {
                                _height = 20;
                              }
                            }
                            return GestureDetector(
                              onTap: () {
                                if (!_enableShowTopic) {
                                  setState(() {
                                    _enableShowTopic = true;
                                  });
                                }
                              },
                              child: AnimatedContainer(
                                curve: Curves.easeIn,
                                height: _height,
                                duration: const Duration(milliseconds: 500),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onInverseSurface,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 2,
                                      blurRadius: 2,
                                      offset:
                                          const Offset(0, 5), // 阴影位置，可以调整阴影的方向
                                    ),
                                  ],
                                ),
                                child: AnimatedOpacity(
                                  opacity: 1,
                                  duration: const Duration(milliseconds: 1000),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: AnimatedSwitcher(
                                          duration: Duration(milliseconds: 500),
                                          child: Text(
                                            key: UniqueKey(),
                                            _enableShowTopic
                                                ? _allTopics[_currentTopicId] ?? "自由聊天吧!"
                                                : "自由聊天吧!",
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: _enableShowTopic
                                            ? Alignment.centerRight
                                            : Alignment.center,
                                        child: _enableShowTopic
                                            ? IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _enableShowTopic = false;
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.arrow_drop_up_outlined,
                                                  size: 30,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                ))
                                            : Icon(
                                                Icons.arrow_drop_down_outlined,
                                                size: 20,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          color: Theme.of(context)
                              .colorScheme
                              .background
                              .withOpacity(0.5),
                          child: Column(
                            children: [
                              Flexible(
                                child: GestureDetector(
                                  onTap: () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    // widget.onBackgroundTap?.call();
                                  },
                                  child: LayoutBuilder(
                                    builder: (
                                      BuildContext context,
                                      BoxConstraints constraints,
                                    ) =>
                                        args.activityId.isNotEmpty
                                            ? StreamBuilder<QuerySnapshot>(
                                                stream:
                                                    chatProvider.getChatStream(
                                                        args.activityId,
                                                        args.peerId,
                                                        limit: _limit),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot<QuerySnapshot>
                                                        snapshot) {
                                                  if (snapshot.hasData) {
                                                    _chatMessages =
                                                        snapshot.data!.docs;
                                                    if (_chatMessages
                                                        .isNotEmpty) {
                                                      return ListView.builder(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        itemBuilder: (context,
                                                                index) =>
                                                            buildItem(
                                                                index,
                                                                snapshot.data
                                                                        ?.docs[
                                                                    index]),
                                                        itemCount: snapshot
                                                            .data?.docs.length,
                                                        reverse: true,
                                                        controller:
                                                            listScrollController,
                                                      );
                                                    } else {
                                                      return const Center(
                                                          child: const Text(
                                                              "No message here yet..."));
                                                    }
                                                  } else {
                                                    return Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary,
                                                      ),
                                                    );
                                                  }
                                                },
                                              )
                                            : Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .background,
                                                ),
                                              ),
                                  ),
                                ),
                              ),
                              !args.isHistorical
                                  ? Input(
                                      activityId: args.activityId,
                                      peerId: args.peerId,
                                      onSendPressed: onSendMessage,
                                      enableSocialMedia: enableSocialMedia,
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }
}
