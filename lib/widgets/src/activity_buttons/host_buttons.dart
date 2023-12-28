import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:resonance_chatroom/pages/routes.dart';

import '../../../providers/src/activity_provider.dart';

class HostButtons extends StatefulWidget {
  const HostButtons(
      {super.key,
      required this.enableStopActivity,
      required this.enableStatistic,
      required this.enableUpdateActivity,
      required this.activityId,
      required this.isEnableActivity});

  final String activityId;
  final bool enableStopActivity;
  final bool enableStatistic;
  final bool enableUpdateActivity;
  final bool isEnableActivity;

  @override
  State<HostButtons> createState() => HostButtonsState();
}

class HostButtonsState extends State<HostButtons>
    with SingleTickerProviderStateMixin {
  late final ActivityProvider activityProvider =
      context.read<ActivityProvider>();
  late AnimationController _controller;
  late Animation _animation;

  late final double buttonPositionTop; //70
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

  bool Initial = false;
  bool isPushButton = false;
  bool isTryChangeActivityState = false;
  late bool localEnableActivity;

  void _init() {
    if (!Initial) {
      localEnableActivity = widget.isEnableActivity;
      buttonPositionTop = MediaQuery.of(context).size.height - 70; //70
      buttonPositionLeft = MediaQuery.of(context).size.width - 100;
      top1 = top2 = top3 = buttonPositionTop + 10;
      left1 = left2 = left3 = buttonPositionLeft + 10;
      Initial = true;
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _init();
    return Container(
        child: Stack(
      children: [
        AnimatedPositioned(
          // todo 尚未串接
          duration: toggle
              ? Duration(milliseconds: 275)
              : Duration(milliseconds: 875),
          top: top1,
          left: left1,
          curve: toggle ? Curves.easeIn : Curves.elasticOut,
          child: AnimatedContainer(
            duration: toggle
                ? Duration(milliseconds: 275)
                : Duration(milliseconds: 875),
            curve: toggle ? Curves.easeIn : Curves.elasticOut,
            height: size1,
            width: size1,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withRed(200),
              borderRadius: BorderRadius.circular(40.0),
            ),
            child: widget.enableStopActivity
                ? localEnableActivity
                    ? IconButton(
                        icon: Text("停用",
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface,
                            )),
                        onPressed: () async {
                          if (!isTryChangeActivityState) {
                            isTryChangeActivityState = true;
                            try {
                              await activityProvider
                                  .deleteActivity(widget.activityId);
                              Fluttertoast.showToast(msg: "活動已停用");
                              setState(() {
                                localEnableActivity = false;
                              });
                            } catch (e) {
                              debugPrint("disableActivityError: $e");
                            }
                            isTryChangeActivityState = false;
                          }
                        },
                      )
                    : IconButton(
                        icon: Text("啟用",
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface,
                            )),
                        onPressed: () async {
                          if (!isTryChangeActivityState) {
                            isTryChangeActivityState = true;
                            try {
                              await activityProvider
                                  .enableActivity(widget.activityId);
                              Fluttertoast.showToast(msg: "活動已啟用");
                              setState(() {
                                localEnableActivity = true;
                              });
                            } catch (e) {
                              debugPrint("enableActivityError: $e");
                            }
                            isTryChangeActivityState = false;
                          }
                        },
                      )
                : IconButton(onPressed: () {}, icon: const Text("無效")),
          ),
        ),
        AnimatedPositioned(
          top: top2,
          left: left2,
          duration: toggle
              ? Duration(milliseconds: 275)
              : Duration(milliseconds: 875),
          curve: toggle ? Curves.easeIn : Curves.elasticOut,
          child: AnimatedContainer(
              duration: toggle
                  ? Duration(milliseconds: 275)
                  : Duration(milliseconds: 875),
              curve: toggle ? Curves.easeIn : Curves.elasticOut,
              height: size2,
              width: size2,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withRed(200),
                borderRadius: BorderRadius.circular(40.0),
              ),
              child: widget.enableStatistic
                  ? IconButton(
                      icon: Text("統計",
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onInverseSurface,
                          )),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                            HostQuestionStatisticPage.routeName,
                            arguments: HostQuestionStatisticPageArguments(
                                widget.activityId));
                      },
                    )
                  : IconButton(onPressed: () {}, icon: const Text("無效"))),
        ),
        AnimatedPositioned(
          top: top3,
          left: left3,
          duration: toggle
              ? Duration(milliseconds: 275)
              : Duration(milliseconds: 875),
          curve: toggle ? Curves.easeIn : Curves.elasticOut,
          child: AnimatedContainer(
            duration: toggle
                ? Duration(milliseconds: 275)
                : Duration(milliseconds: 875),
            curve: toggle ? Curves.easeIn : Curves.elasticOut,
            height: size3,
            width: size3,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withRed(200),
              borderRadius: BorderRadius.circular(40.0),
            ),
            child: widget.enableUpdateActivity
                ? IconButton(
                    icon: Text("修改",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                        )),
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                          HostActivityEditPage.routeName,
                          arguments: HostActivityEditPageArguments(
                              activityId: widget.activityId));
                    })
                : IconButton(onPressed: () {}, icon: const Text("無效")),
          ),
        ),
        Positioned(
          top: buttonPositionTop,
          left: buttonPositionLeft,
          child: Transform.rotate(
            angle: _animation.value * 3.14159 * (3 / 4),
            child: AnimatedContainer(
                duration: Duration(milliseconds: 375),
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
    ));
  }
}
