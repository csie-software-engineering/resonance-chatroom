import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resonance_chatroom/pages/pages.dart';
import 'package:resonance_chatroom/models/models.dart';
import 'package:resonance_chatroom/widgets/widgets.dart';
import 'package:resonance_chatroom/providers/providers.dart';

import '../../constants/src/firestore_constants.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.arguments, required this.title});
  final String title;
  final ChatPageArguments arguments;

  // get inputOptions => null;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isOn = true;
  int _limit = 20;
  int _limitIncrement = 20;

  double _height = 0;

  // File? imageFile;
  bool isLoading = false;
  bool isShowSticker = false;
  bool _showTopic = false;
  String imageUrl = "";

  List<QueryDocumentSnapshot> _chatMessages = [];

  final List<String> groupMembers = <String>[];
  late final String currentUserId;

  late final ChatProvider chatProvider = context.read<ChatProvider>();
  // late final AuthProviders authProvider = context.read<AuthProviders>();

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  void onSendMessage(String content, MessageType type) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      chatProvider.sendMessage(widget.arguments.activityId, currentUserId,
          widget.arguments.peerId, content, type);
      if (listScrollController.hasClients) {
        listScrollController.animateTo(0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    } else {
      // 當沒有文字的時候
      // Fluttertoast.showToast(msg: 'Nothing to send', backgroundColor: ColorConstants.greyColor);
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
              IconButton(onPressed: (){
                setState(() {
                  _height = 0;
                  _showTopic = false;
                });
              }, icon: Icon(
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

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
    readLocal();
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

  void readLocal() {
    // if (authProvider.getUserId()?.isNotEmpty == true) {
    //   currentUserId = authProvider.getUserId()!;
    // } else {
    //   Navigator.of(context).pushAndRemoveUntil(
    //     MaterialPageRoute(builder: (context) => const MyHomePage(title: "way back home")),
    //         (Route<dynamic> route) => false,
    //   );
    // }
    currentUserId = "15";
    String peerId = widget.arguments.peerId;

    groupMembers.add(currentUserId);
    groupMembers.add(peerId);
    // if (currentUserId.compareTo(peerId) > 0) {
    //   groupMembers = '$currentUserId-$peerId';
    // } else {
    //   groupMembers = '$peerId-$currentUserId';
    // }

    // chatProvider.updateDataFirestore(
    //   FirestoreConstants.userCollectionPath,
    //   currentUserId,
    //   {FirestoreConstants.chattingWith: peerId},
    // );
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            _chatMessages[index - 1].get(FirestoreConstants.id) ==
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            _chatMessages[index - 1].get(FirestoreConstants.id) !=
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Widget buildItem(int index, DocumentSnapshot? document) {
    if (document != null) {
      ChatMessage messageChat = ChatMessage.fromDocument(document);
      if (messageChat.fromId == currentUserId) {
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
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(
                        // bottom: isLastMessageRight(index) ? 20 : 10, right: 10),
                        bottom: 10,
                        right: 10),
                    child: Text(
                      messageChat.content,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
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
                    child: Image.network(
                      widget.arguments.peerAvatar, // 會是一個 url 載入使用者的頭貼
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
                          ),
                        );
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
                  messageChat.type == MessageType.text
                      ? Container(
                          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                          constraints: const BoxConstraints(maxWidth: 200),
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(12)),
                          margin: EdgeInsets.only(bottom: 10, left: 10),
                          child: Text(
                            messageChat.content,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary),
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
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                const Align(
                    child: const BackButton(),
                  alignment: Alignment.centerLeft,
                ),
                Align(
                  alignment: Alignment.center,
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
                          child: Text("Tag",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    child: IconButton(
                      padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                      icon: Icon(isOn ? Icons.lightbulb : Icons.lightbulb_outline),
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
                            FocusManager.instance.primaryFocus?.unfocus();
                            // widget.onBackgroundTap?.call();
                          },
                          child: LayoutBuilder(
                            builder: (
                              BuildContext context,
                              BoxConstraints constraints,
                            ) =>
                                widget.arguments.activityId.isNotEmpty
                                    ? StreamBuilder<QuerySnapshot>(
                                        stream: chatProvider.getChatStream(
                                            widget.arguments.activityId,
                                            groupMembers,
                                            _limit),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<QuerySnapshot>
                                                snapshot) {
                                          if (snapshot.hasData) {
                                            _chatMessages = snapshot.data!.docs;
                                            if (_chatMessages.isNotEmpty) {
                                              return ListView.builder(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                itemBuilder: (context, index) =>
                                                    buildItem(
                                                        index,
                                                        snapshot
                                                            .data?.docs[index]),
                                                itemCount:
                                                    snapshot.data?.docs.length,
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
                                              child: CircularProgressIndicator(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                              ),
                                            );
                                          }
                                        },
                                      )
                                    : Center(
                                        child: CircularProgressIndicator(
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
}

class ChatPageArguments {
  final String peerId;
  final String peerAvatar;
  final String peerNickname;
  final String activityId;

  ChatPageArguments(this.peerAvatar, this.activityId,
      {required this.peerId, required this.peerNickname});
}
