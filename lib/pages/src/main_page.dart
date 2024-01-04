import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import '../routes.dart';

class MainPageArguments {
  final bool isHost;

  const MainPageArguments({required this.isHost});
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  static const routeName = '/main_page';

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as MainPageArguments;

    return FutureBuilder<User>(
      future: context.read<AuthProvider>().currentUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.requireData;
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: CustomAppBar(
            title: args.isHost ? '舉辦的活動' : '參加的活動',
            leading: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(PersonalSettingPage.routeName,
                      arguments:
                          PersonalSettingPageArguments(isHost: args.isHost));
                },
                child: CircleAvatar(
                  foregroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  backgroundImage: const AssetImage('lib/assets/user.png'),
                ),
              ),
            ),
            tail: null,
          ),
          body: ActivityCarouselWidget(isHost: args.isHost),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              if (args.isHost) {
                Navigator.of(context).pushNamed(HostActivitySetPage.routeName);
              } else {
                _joinActivity(context, user);
              }
            },
            tooltip: args.isHost ? '新增活動' : '加入活動',
            label: const Icon(Icons.event),
          ),
        );
      },
    );
  }

  void _joinActivity(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: FutureBuilder<List<Activity>>(
            future: context
                .read<UserProvider>()
                .getUserNotJoinedActivities(outdated: false),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              return AlertDialog(
                actionsAlignment: MainAxisAlignment.center,
                scrollable: true,
                title: const Text(
                  '加入活動',
                  textAlign: TextAlign.center,
                ),
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: ListView.builder(
                        itemCount: snapshot.data?.length ?? 0,
                        itemBuilder: (context, index) {
                          final activity = snapshot.requireData[index];

                          return ListTile(
                            leading: const Icon(Icons.event),
                            title: Text(activity.activityName),
                            subtitle: Text(
                                activity.startDate.toEpochTime().toString()),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('確認加入活動'),
                                  content: Text(
                                      '是否要加入「${activity.activityName}」活動？'),
                                  actions: confirmButtons(
                                    context,
                                    action: () {
                                      context
                                          .read<UserProvider>()
                                          .addUserActivity(UserActivity(
                                            uid: activity.uid,
                                            isManager: false,
                                          ))
                                          .then((_) => setState(() {
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pop();
                                              }));
                                    },
                                    cancel: () => Navigator.of(context).pop(),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('關閉'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class ActivityCarouselWidget extends StatefulWidget {
  final bool isHost;

  const ActivityCarouselWidget({
    super.key,
    required this.isHost,
  });

  @override
  State<ActivityCarouselWidget> createState() => _ActivityCarouselWidgetState();
}

class _ActivityCarouselWidgetState extends State<ActivityCarouselWidget> {
  int _activeIndex = 0;
  int _acivityCount = 0;
  late final List<UserActivity> _userActivities;
  late final List<Activity> _activities;
  late final List<String> _activityName;
  final AsyncMemoizer _initalPageMemoization = AsyncMemoizer<void>();
  List<Uint8List> _images = [];

  Future<void> _getActivities() async {
    _activities = [];
    for (var i in _userActivities) {
      var tmp = await context.read<ActivityProvider>().getActivity(i.uid);
      debugPrint("tmp: ${tmp.activityName}");
      _activities.add(tmp);
    }
  }

  Future<void> _init() async {
    _userActivities = await context
        .read<UserProvider>()
        .getUserActivities(isManager: widget.isHost);
    for(var i in _userActivities){
      debugPrint("userActivities: ${i.uid}");
    }
    await _getActivities();
    debugPrint("activities: ${_activities.length}");
    for (var i in _activities) {
      _images.add(base64ToImage(i.activityPhoto));
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: _initalPageMemoization.runOnce(_init),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          _acivityCount = _userActivities.length;
          return _userActivities.isNotEmpty
              ? Center(
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: CarouselSlider.builder(
                          itemCount: _userActivities.length,
                          options: CarouselOptions(
                              aspectRatio: 1,
                              // height: MediaQuery.of(context).size.height,
                              enlargeCenterPage: true,
                              initialPage: 0,
                              viewportFraction: 0.7,
                              enableInfiniteScroll: false,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _activeIndex = index;
                                });
                              }),
                          itemBuilder: (context, index, realIndex) {
                            final activityId = _userActivities[index].uid;
                            return InkWell(
                              onLongPress: () => widget.isHost
                                  ? ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('主辦方無法刪除活動')))
                                  : showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('刪除活動'),
                                        content: const Text('是否要刪除該活動？'),
                                        actions: confirmButtons(
                                          context,
                                          action: () {
                                            context
                                                .read<UserProvider>()
                                                .removeUserActivity(activityId,
                                                    isManager: false)
                                                .then((value) => setState(() {
                                                      Navigator.of(context)
                                                          .pop();
                                                    }));
                                          },
                                          cancel: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                      ),
                                    ),
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 0.0),
                                      child: RoomCardWidget(
                                        isHost: widget.isHost,
                                        activity: _activities[index],
                                        refresh: () => setState(() {}),
                                        image: _images[index],
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          height: 80,
                                          width: 200,
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .background,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.1),
                                                  offset: const Offset(0, 4),
                                                  spreadRadius: 1,
                                                  blurRadius: 2,
                                                )
                                              ]),
                                          child: Center(
                                              child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Text(
                                              _activities[index].activityName,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontSize: 16,
                                              ),
                                            ),
                                          )),
                                        ),
                                        const SizedBox(height: 30),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 80),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: AnimatedSmoothIndicator(
                            activeIndex: _activeIndex,
                            count: _acivityCount,
                            effect: ScrollingDotsEffect(
                              fixedCenter: true,
                              activeDotColor:
                                  Theme.of(context).colorScheme.primary,
                              dotColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.2),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : Center(
                  child: Text(
                    '目前沒有${widget.isHost ? '舉辦' : '參加'}活動',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
        },
      );
}

class RoomCardWidget extends StatelessWidget {
  final bool isHost;
  final Activity activity;
  final Function refresh;
  final Uint8List image;

  const RoomCardWidget({
    super.key,
    required this.isHost,
    required this.activity,
    required this.refresh,
    required this.image,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
        ),
        child: InkWell(
          onTap: () {
            if (isHost || activity.isEnabled) {
              Navigator.of(context)
                  .pushNamed(
                    ActivityMainPage.routeName,
                    arguments: ActivityMainPageArguments(
                      activityId: activity.uid,
                      isHost: isHost,
                    ),
                  )
                  .then((_) => refresh());
            } else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('發生錯誤'),
                  content: const Text('活動可能已經取消或發生錯誤\n長按活動可以刪除該活動\n若有疑問請聯繫主辦方'),
                  actions: [
                    TextButton(
                      child: const Text('了解'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.memory(
              image,
              fit: BoxFit.contain,
              opacity: AlwaysStoppedAnimation(activity.isEnabled ? 1 : 0.5),
            ),
          ),
        ),
      );
}
