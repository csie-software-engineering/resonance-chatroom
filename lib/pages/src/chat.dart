import 'dart:ui';
import 'package:async/async.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:resonance_chatroom/models/models.dart';
import 'package:resonance_chatroom/pages/src/user_activity_main_page.dart';
import 'package:resonance_chatroom/widgets/widgets.dart';
import 'package:resonance_chatroom/providers/providers.dart';

import '../../constants/src/firestore_constants.dart';

class ChatPageArguments {
  final String peerId;
  final String activityId;

  ChatPageArguments({required this.activityId, required this.peerId});
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

  late final ChatProvider chatProvider = context.read<ChatProvider>();
  late final AuthProvider authProvider = context.read<AuthProvider>();
  late final UserProvider userProvider = context.read<UserProvider>();
  late final ActivityProvider activityProvider =
      context.read<ActivityProvider>();
  late final QuestionProvider questionProvider =
      context.read<QuestionProvider>();

  final AsyncMemoizer _memoization = AsyncMemoizer<void>();
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController reportTextController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  int _limit = 20;
  int _limitIncrement = 20;
  double _height = 0;

  bool isOn = true;
  bool isLoading = false;
  bool isShowSticker = false;
  bool _showTopic = false;
  bool initial = false;
  bool _isAlreadyReport = false;

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
        // todo 因為沒有辦法分辨錯誤，所以只能抓所有看看
        Fluttertoast.showToast(
            msg: '對方已離開，無法傳送訊息',
            backgroundColor: Theme.of(context).colorScheme.onSurface,
            textColor: Theme.of(context).colorScheme.onInverseSurface);
      }
    } else {
      // 當沒有文字的時候
      Fluttertoast.showToast(
          msg: 'Nothing to send',
          backgroundColor: Theme.of(context).colorScheme.onSurface,
          textColor: Theme.of(context).colorScheme.onInverseSurface);
    }
  }

  Widget? _subTitle() {
    if (!_showTopic) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: Theme.of(context).colorScheme.inversePrimary,
        child: AnimatedOpacity(
          opacity: 0,
          duration: const Duration(milliseconds: 1000),
        ),
      );
    } else {
      return AnimatedContainer(
        curve: Curves.easeIn,
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 2,
              offset: const Offset(0, 5), // 阴影位置，可以调整阴影的方向
            ),
          ],
        ),
        child: AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 1000),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              Center(
                child: Text(
                  "人工智慧在醫療的發展？",
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      _height = 0;
                      _showTopic = false;
                    });
                  },
                  icon: Icon(
                    Icons.arrow_drop_up_outlined,
                    size: 30,
                    color: Theme.of(context).colorScheme.secondary,
                  )),
            ],
          ),
        ),
      );
    }
  }

  void updateHeight() {
    setState(() {
      _height = 50;
      _showTopic = true;
    });
  }

  Future<List<UserSocialMedia>?> _getPeerSocialMedia() async {
    if (await chatProvider.getIsAgreeShareSocialMedia(
        args.activityId, args.peerId)) {
      return await chatProvider.getOtherSocialMedium(
          args.activityId, args.peerId);
    }
    return null;
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

  void _init() async {
    if (!initial) {
      peerUser = await userProvider.getUser(
          userId: args.peerId); // todo 我可以直接載入對方的 social media?
      room = await chatProvider.getRoom(args.activityId, args.peerId);
      currentUser = await authProvider.currentUser;
      _tagName =
          (await activityProvider.getTag(args.activityId, room.tag)).tagName;
      chatProvider.agreeShareSocialMedia(
          args.activityId, args.peerId); // todo 假裝同意
      initial = true;
    }
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
                                                  peerUser.photoUrl ??
                                                      "空照片", // 會是一個 url 載入使用者的頭貼
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
                                                          .onPrimary,
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
                                                                          args.activityId,
                                                                          args.peerId,
                                                                          "惡意言論",
                                                                          reportTextController
                                                                              .text);
                                                                      reportTextController
                                                                          .clear();
                                                                      setState(
                                                                          () {
                                                                            _isAlreadyReport = true;
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
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text("社群媒體連結",
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
                                                                              () {
                                                                            // todo launch;
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
                            color: Theme.of(context).colorScheme.onPrimary,
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
        future: _memoization.runOnce(_init),
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
            return Scaffold(
              body: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top),
                  Container(
                    height: kToolbarHeight,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: Offset(0, 2), // 阴影位置，可以调整阴影的方向
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
                                      .withOpacity(0.8),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(16)),
                                ),
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
                                    return AlertDialog(
                                      title: Text("確定要退出？"),
                                      actions: [
                                        TextButton(
                                          child: Text("確定"),
                                          onPressed: () {
                                            chatProvider.leaveRoom(
                                                args.activityId,
                                                args.peerId); // todo 如果對方已經離開則這個就會 assert
                                            setState(() {
                                              Navigator.popUntil(
                                                  context,
                                                  ModalRoute.withName(
                                                      UserActivityMainPage
                                                          .routeName));
                                            });
                                          },
                                        )
                                      ],
                                    );
                                  });
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            child: IconButton(
                              padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                              icon: Icon(isOn
                                  ? Icons.lightbulb
                                  : Icons.lightbulb_outline),
                              color: isOn ? Colors.amber : Colors.white,
                              onPressed: () {
                                setState(() {
                                  isOn = !isOn;
                                });
                              },
                            ),
                          ),
                        )
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
                    child: Stack(
                      children: [
                        Container(
                          color: Theme.of(context).colorScheme.background,
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
                              Input(
                                onSendPressed: onSendMessage,
                                callback: updateHeight,
                              )
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
