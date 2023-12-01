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

  // File? imageFile;
  bool isLoading = false;
  bool isShowSticker = false;
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
    currentUserId = "Daniel";
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
                    margin: EdgeInsets.only(
                        // bottom: isLastMessageRight(index) ? 20 : 10, right: 10)
                        bottom: 10,
                        right: 10),
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
          margin: EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  isLastMessageLeft(index)
                      ? Material(
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
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, object, stackTrace) {
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
                        )
                      : Container(width: 35),
                  messageChat.type == MessageType.text
                      ? Container(
                          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                          constraints: const BoxConstraints(maxWidth: 200),
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onPrimary,
                              borderRadius: BorderRadius.circular(8)),
                          margin: EdgeInsets.only(left: 10),
                          child: Text(
                            messageChat.content,
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.only(
                              bottom: isLastMessageRight(index) ? 20 : 10,
                              right: 10),
                          child: const Icon(Icons.not_accessible)),
                ],
              ),

              // Time
              isLastMessageLeft(index)
                  ? Container(
                      margin:
                          const EdgeInsets.only(left: 50, top: 5, bottom: 5),
                      child: Text(
                        // DateFormat('dd MMM kk:mm')
                        //     .format(DateTime.fromMillisecondsSinceEpoch(int.parse(messageChat.timestamp))),
                        "Date",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 12,
                            fontStyle: FontStyle.italic),
                      ),
                    )
                  : SizedBox.shrink()
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
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          leading: const BackButton(),
          title: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: const BorderRadius.all(Radius.circular(16)),
              ),
              child: const SizedBox(
                width: 160, // <-- box的寬度
                height: 30,
                child: Align(
                  alignment: Alignment.center, // <-- 這裡設定text的對齊方式
                  child: Text(
                    'test',
                  ),
                ),
              ),
            ),
          ),
          actions: <Widget>[
            IconButton(
              padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
              icon: Icon(isOn ? Icons.lightbulb : Icons.lightbulb_outline),
              color: isOn ? Colors.amber : Colors.white,
              onPressed: () {
                setState(() {
                  isOn = !isOn;
                });
              },
            )
          ]),
      body: Stack(
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
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasData) {
                                      _chatMessages = snapshot.data!.docs;
                                      if (_chatMessages.isNotEmpty) {
                                        return ListView.builder(
                                          padding: const EdgeInsets.all(10),
                                          itemBuilder: (context, index) =>
                                              buildItem(index,
                                                  snapshot.data?.docs[index]),
                                          itemCount: snapshot.data?.docs.length,
                                          reverse: true,
                                          controller: listScrollController,
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
                )
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
