import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  String groupChatId = "";
  late final String currentUserId;

  late final ChatProvider chatProvider = context.read<ChatProvider>();
  // late final AuthProvider authProvider = context.read<AuthProvider>();

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  void onSendMessage(String content, MessageType type) {
    if (content.trim().isNotEmpty) {
      // textEditingController.clear();
      chatProvider.sendMessage(
          content, type, groupChatId, currentUserId, widget.arguments.peerId);
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
    // if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
    //   currentUserId = authProvider.getUserFirebaseId()!;
    // } else {
    //   Navigator.of(context).pushAndRemoveUntil(
    //     MaterialPageRoute(builder: (context) => LoginPage()),
    //         (Route<dynamic> route) => false,
    //   );
    // }
    currentUserId = "Jason";
    String peerId = widget.arguments.peerId;
    if (currentUserId.compareTo(peerId) > 0) {
      groupChatId = '$currentUserId-$peerId';
    } else {
      groupChatId = '$peerId-$currentUserId';
    }

    chatProvider.updateDataFirestore(
      FirestoreConstants.pathUserCollection,
      currentUserId,
      {FirestoreConstants.chattingWith: peerId},
    );
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            _chatMessages[index - 1].get(FirestoreConstants.idFrom) ==
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            _chatMessages[index - 1].get(FirestoreConstants.idFrom) !=
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Widget buildItem(int index, DocumentSnapshot? document) {
    if (document != null) {
      MessageChat messageChat = MessageChat.fromDocument(document);
      if (messageChat.idFrom == currentUserId) {
        // Right (my message)
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            messageChat.type == MessageType.text
                // Text
                ? Container(
                    padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                    width: 200,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onPrimary,
                        borderRadius: BorderRadius.circular(8)),
                    margin: EdgeInsets.only(
                        bottom: isLastMessageRight(index) ? 20 : 10, right: 10),
                    child: Text(
                      messageChat.content,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  )
                : messageChat.type == MessageType.image
                    // Image
                    ? Container(
                        margin: EdgeInsets.only(
                            bottom: isLastMessageRight(index) ? 20 : 10,
                            right: 10),
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                // builder: (context) => FullPhotoPage(
                                //   url: messageChat.content,
                                // ),
                                builder: (context) => Text("hi"),
                              ),
                            );
                          },
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  EdgeInsets.all(0))),
                          child: Material(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            clipBehavior: Clip.hardEdge,
                            child: Image.network(
                              messageChat.content,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  width: 200,
                                  height: 200,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, object, stackTrace) {
                                return Material(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: Icon(Icons.not_accessible),
                                );
                              },
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                    // Sticker
                    : Container(
                        margin: EdgeInsets.only(
                            bottom: isLastMessageRight(index) ? 20 : 10,
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
                            widget.arguments.peerAvatar,
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
                          width: 200,
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onPrimary,
                              borderRadius: BorderRadius.circular(8)),
                          margin: EdgeInsets.only(left: 10),
                          child: Text(
                            messageChat.content,
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      : messageChat.type == MessageType.image
                          ? Container(
                              margin: EdgeInsets.only(left: 10),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      // builder: (context) => FullPhotoPage(url: messageChat.content),
                                      builder: (context) => Text("Another HI"),
                                    ),
                                  );
                                },
                                style: ButtonStyle(
                                    padding:
                                        MaterialStateProperty.all<EdgeInsets>(
                                            const EdgeInsets.all(0))),
                                child: Material(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8)),
                                  clipBehavior: Clip.hardEdge,
                                  child: Image.network(
                                    messageChat.content,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                        ),
                                        width: 200,
                                        height: 200,
                                        child: Center(
                                          child: CircularProgressIndicator(
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
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, object, stackTrace) =>
                                            const Material(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: Icon(Icons.not_accessible),
                                    ),
                                  ),
                                ),
                              ))
                          : Container(
                              margin: EdgeInsets.only(
                                  bottom: isLastMessageRight(index) ? 20 : 10,
                                  right: 10),
                              child: Icon(Icons.not_accessible)),
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
                          groupChatId.isNotEmpty
                              ? StreamBuilder<QuerySnapshot>(
                                  stream: chatProvider.getChatStream(
                                      groupChatId, _limit),
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
                                            child:
                                                const Text("No message here yet..."));
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
          // if (_isImageViewVisible)
          //   ImageGallery(
          //     imageHeaders: widget.imageHeaders,
          //     imageProviderBuilder: widget.imageProviderBuilder,
          //     images: _gallery,
          //     pageController: _galleryPageController!,
          //     onClosePressed: _onCloseGalleryPressed,
          //     options: widget.imageGalleryOptions,
          //   ),
        ],
      ),
    );
  }
}

class ChatPageArguments {
  final String peerId;
  final String peerAvatar;
  final String peerNickname;

  ChatPageArguments(this.peerAvatar,
      {required this.peerId, required this.peerNickname});
}
