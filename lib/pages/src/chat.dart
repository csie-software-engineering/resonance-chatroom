import 'package:flutter/material.dart';
import 'package:resonance_chatroom/widgets/widgets.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.title});
  final String title;

  get inputOptions => null;


  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isOn = true;
  List<Object> _chatMessages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: const BackButton(),
          title: const Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: SizedBox(
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
              icon: Icon(isOn ? Icons.lightbulb : Icons.lightbulb_outline),
              color: isOn ? Colors.amber : Colors.white,
              onPressed: () {
                setState(() {
                  isOn = !isOn;
                });
              },
            )
          ]),

      // body: const Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: <Widget>[
      //       Text(
      //         'You have pushed the button this many times:',
      //       ),
      //     ],
      //   ),
      // ),

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
                            ) => Text("HI"),
                            //     ChatList(
                            //   bottomWidget: widget.listBottomWidget,
                            //   bubbleRtlAlignment: widget.bubbleRtlAlignment!,
                            //   isLastPage: widget.isLastPage,
                            //   itemBuilder: (Object item, int? index) =>
                            //       _messageBuilder(
                            //     item,
                            //     constraints,
                            //     index,
                            //   ),
                            //   items: _chatMessages,
                            //   keyboardDismissBehavior:
                            //       widget.keyboardDismissBehavior,
                            //   onEndReached: widget.onEndReached,
                            //   onEndReachedThreshold:
                            //       widget.onEndReachedThreshold,
                            //   scrollController: _scrollController,
                            //   scrollPhysics: widget.scrollPhysics,
                            //   typingIndicatorOptions:
                            //       widget.typingIndicatorOptions,
                            //   useTopSafeAreaInset:
                            //       widget.useTopSafeAreaInset ?? isMobile,
                            // ),
                          ),
                        ),
                ),
                Input(
                    onSendPressed: (String){},
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
