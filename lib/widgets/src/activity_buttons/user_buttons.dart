import 'dart:async';

import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../../../pages/routes.dart';
import '../../widgets.dart';
import '../activity_card/tag_list.dart';

class UserButtons extends StatefulWidget {
  const UserButtons({
    super.key,
    required this.enableTagWidget,
    required this.matching,
    required this.startMatching,
    required this.goToHistoricalChatRoomPage,
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
  final List<bool> tagSelected;
  final List<Tag> currentActivityTags;
  final String currentUserName;

  @override
  State<UserButtons> createState() => UserButtonsState();
}

class UserButtonsState extends State<UserButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  final TextEditingController _textEditingController = TextEditingController();

  late final double buttonPositionTop;
  late final double buttonPositionLeft;

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
  bool isPushButton = false;

  void _init() {
    if (!initial) {
      buttonPositionTop = MediaQuery.of(context).size.height - 70; //70
      buttonPositionLeft = MediaQuery.of(context).size.width - 100;
      top1 = top2 = top3 = buttonPositionTop + 10;
      left1 = left2 = left3 = buttonPositionLeft + 10;
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
              color: widget.enableHistoricalChatRoom
                  ? Theme.of(context).colorScheme.primary.withRed(200)
                  : Colors.grey,
              borderRadius: BorderRadius.circular(40.0),
            ),
            child: IconButton(
              onPressed: () {
                if (widget.enableHistoricalChatRoom) {
                  Navigator.of(context).pushNamed(
                    HistoricalChatRoomPage.routeName,
                    arguments: HistoricalChatRoomPageArguments(
                      activityId: widget.currentActivityTags[0].activityId,
                    ),
                  );
                }
              },
              icon: Icon(
                Icons.chat,
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            ),
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
              color: widget.enableTagWidget && widget.enableMatch
                  ? Theme.of(context).colorScheme.primary.withRed(200)
                  : Colors.grey,
              borderRadius: BorderRadius.circular(40.0),
            ),
            child: IconButton(
              icon: widget.startMatching
                  ? Text("取消",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      ))
                  : Text("配對",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      )),
              onPressed: () {
                if (widget.enableTagWidget && widget.enableMatch) {
                  widget.matching();
                }
              },
            ),
          ),
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
              color: widget.enableTagWidget
                  ? Theme.of(context).colorScheme.primary.withRed(200)
                  : Colors.grey,
              borderRadius: BorderRadius.circular(40.0),
            ),
            child: IconButton(
                icon: Text("標籤",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    )),
                onPressed: () {
                  var width = context.size!.width * 0.8;
                  if (widget.enableTagWidget) {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          List<bool> _tagTmp = List.generate(
                              widget.currentActivityTags.length,
                              (index) => false);
                          for (int i = 0; i < widget.tagSelected.length; i++) {
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
                                          padding:
                                              const EdgeInsets.only(right: 10),
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
                                              decoration: const InputDecoration(
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
                                        borderRadius: BorderRadius.circular(10),
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
                            actions: confirmButtons(
                              context,
                              action: () => widget.changeTagAndName(
                                  _textEditingController, _tagTmp),
                              cancel: () => _textEditingController.text =
                                  widget.currentUserName,
                            ),
                          );
                        });
                  }
                }),
          ),
        ),
        Positioned(
          top: buttonPositionTop,
          left: buttonPositionLeft,
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
                        if (!isPushButton) {
                          isPushButton = true;
                          setState(() {
                            if (toggle) {
                              toggle = !toggle;
                              _controller.forward();
                              Future.delayed(Duration(milliseconds: 10), () {
                                top1;
                                left1 = left1 - 100;
                                size1 = 50;
                              });
                              Future.delayed(Duration(milliseconds: 100), () {
                                top2 = top2 - 70;
                                left2 = left2 - 70;
                                size2 = 50;
                              });
                              Future.delayed(Duration(milliseconds: 200), () {
                                left3;
                                top3 = top3 - 100;
                                size3 = 50;
                              });
                            } else {
                              toggle = !toggle;
                              _controller.reverse();
                              top1 = top2 = top3 = buttonPositionTop + 10;
                              left1 = left2 = left3 = buttonPositionLeft + 10;
                              size1 = size2 = size3 = 20.0;
                            }
                          });
                          Future.delayed(Duration(milliseconds: 500), () {
                            isPushButton = false;
                          });
                        }
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
