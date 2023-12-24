import 'dart:async';

import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../../../pages/routes.dart';
import '../activity_card/tag_list.dart';

class AnimatedButtons extends StatefulWidget {
  const AnimatedButtons({
    super.key,
    required this.enableTagWidget,
    required this.matching,
    required this.startMatching,
    required this.goToHistoricalChatRoomPage,
    required this.buttonPositionTop,
    required this.buttonPositionLeft,
    required this.tagSelected,
    required this.currentActivityTags,
    required this.changeTagAndName,
    required this.enableMatch,
    required this.currentUserName,
    required this.enableHistoricalChatRoom,
  });

  final bool enableTagWidget;
  final bool enableMatch;
  final bool enableHistoricalChatRoom;
  final bool startMatching;
  final Function() matching;
  final Function() goToHistoricalChatRoomPage;
  final void Function(TextEditingController, List<bool>) changeTagAndName;
  final double buttonPositionTop;
  final double buttonPositionLeft;
  final List<bool> tagSelected;
  final List<Tag> currentActivityTags;
  final String currentUserName;

  @override
  State<AnimatedButtons> createState() => AnimatedButtonsState();
}

class AnimatedButtonsState extends State<AnimatedButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  final TextEditingController _textEditingController = TextEditingController();

  bool toggle = true;
  late double top1;
  late double left1;
  late double top2;
  late double left2;
  late double top3;
  late double left3;

  double size1 = 20;
  double size2 = 20;
  double size3 = 20;

  bool initial = false;

  void _init() {
    if (!initial) {
      top1 = top2 = top3 = widget.buttonPositionTop + 10;
      left1 = left2 = left3 = widget.buttonPositionLeft + 10;
      initial = true;
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 275),
    );

    _animation = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn);

    _controller.addListener(() {
      setState(() {});
    });
    _textEditingController.text = widget.currentUserName;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _init();
    return Stack(
      children: [
        AnimatedPositioned(
          duration: toggle
              ? const Duration(milliseconds: 275)
              : const Duration(milliseconds: 875),
          top: top1,
          left: left1,
          curve: toggle ? Curves.easeIn : Curves.elasticOut,
          child: AnimatedContainer(
            duration: toggle
                ? const Duration(milliseconds: 275)
                : const Duration(milliseconds: 875),
            curve: toggle ? Curves.easeIn : Curves.elasticOut,
            height: size1,
            width: size1,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withRed(200),
              borderRadius: BorderRadius.circular(40.0),
            ),
            child: widget.enableHistoricalChatRoom
                ? IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                          HistoricalChatRoomPage.routeName,
                          arguments: HistoricalChatRoomPageArguments(
                            activityId: widget.currentActivityTags[0].activityId,
                          )
                      );
                    },
                    icon: Icon(
                      Icons.chat,
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                  )
                : IconButton(onPressed: () {}, icon: const Text("無效")),
          ),
        ),
        AnimatedPositioned(
          top: top2,
          left: left2,
          duration: toggle
              ? const Duration(milliseconds: 275)
              : const Duration(milliseconds: 875),
          curve: toggle ? Curves.easeIn : Curves.elasticOut,
          child: AnimatedContainer(
              duration: toggle
                  ? const Duration(milliseconds: 275)
                  : const Duration(milliseconds: 875),
              curve: toggle ? Curves.easeIn : Curves.elasticOut,
              height: size2,
              width: size2,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withRed(200),
                borderRadius: BorderRadius.circular(40.0),
              ),
              child: widget.enableTagWidget && widget.enableMatch
                  ? IconButton(
                      icon: widget.startMatching
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
                      onPressed: widget.matching,
                    )
                  : IconButton(onPressed: () {}, icon: const Text("無效"))),
        ),
        AnimatedPositioned(
          top: top3,
          left: left3,
          duration: toggle
              ? const Duration(milliseconds: 275)
              : const Duration(milliseconds: 875),
          curve: toggle ? Curves.easeIn : Curves.elasticOut,
          child: AnimatedContainer(
            duration: toggle
                ? const Duration(milliseconds: 275)
                : const Duration(milliseconds: 875),
            curve: toggle ? Curves.easeIn : Curves.elasticOut,
            height: size3,
            width: size3,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withRed(200),
              borderRadius: BorderRadius.circular(40.0),
            ),
            child: widget.enableTagWidget
                ? IconButton(
                    icon: Text("標籤",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                        )),
                    onPressed: () {
                      var width = context.size!.width * 0.8;

                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            List<bool> _tagTmp = List.generate(
                                widget.currentActivityTags.length,
                                (index) => false);
                            for (int i = 0;
                                i < widget.tagSelected.length;
                                i++) {
                              _tagTmp[i] = widget.tagSelected[i];
                            }
                            return AlertDialog(
                              insetPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 40.0),
                              actionsPadding: const EdgeInsets.only(
                                  top: 0, right: 20, bottom: 10),
                              scrollable: true,
                              title: Column(
                                // alignment: AlignmentDirectional.topStart,
                                children: [
                                  const Text("匹配設定"),
                                  const SizedBox(height: 20),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inversePrimary
                                            .withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.3),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Text(
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
                                                controller:
                                                    _textEditingController,
                                                decoration:
                                                    const InputDecoration(
                                                        isCollapsed: true),
                                                maxLines: 1,
                                              )),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              content: Container(
                                padding: const EdgeInsets.all(14),
                                height: 300,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary
                                      .withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                      child: TagsWidget(
                                          tagList: widget.currentActivityTags,
                                          tagSelectedTmp: _tagTmp),
                                    )
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    widget.changeTagAndName(
                                        _textEditingController, _tagTmp);
                                  },
                                  child: const Text('確定'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _textEditingController.text =
                                        widget.currentUserName;
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('取消'),
                                ),
                              ],
                            );
                          });
                    })
                : IconButton(onPressed: () {}, icon: const Text("無效")),
          ),
        ),
        Positioned(
          top: widget.buttonPositionTop,
          left: widget.buttonPositionLeft,
          child: Transform.rotate(
            angle: _animation.value * 3.14159 * (3 / 4),
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 375),
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
                      color: Theme.of(context).colorScheme.onInverseSurface,
                      splashColor: Colors.black54,
                      onPressed: () {
                        setState(() {
                          if (toggle) {
                            toggle = !toggle;
                            _controller.forward();
                            Future.delayed(const Duration(milliseconds: 10),
                                () {
                              top1;
                              left1 = left1 - 100;
                              size1 = 50;
                            });
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
                              top2 = top2 - 70;
                              left2 = left2 - 70;
                              size2 = 50;
                            });
                            Future.delayed(const Duration(milliseconds: 200),
                                () {
                              left3;
                              top3 = top3 - 100;
                              size3 = 50;
                            });
                          } else {
                            toggle = !toggle;
                            _controller.reverse();
                            top1 = top2 = top3 = widget.buttonPositionTop + 10;
                            left1 =
                                left2 = left3 = widget.buttonPositionLeft + 10;
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
      ],
    );
  }
}
