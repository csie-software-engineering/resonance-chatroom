import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          appBar: myAppBar(
            context,
            title: Text(args.isHost ? '舉辦的活動' : '參加的活動'),
            leading: Container(
              padding: const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10.0),
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
          ),
          body: ActivityCarouselWidget(isHost: args.isHost),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              if(args.isHost) {
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
                                  actions: confirmButtons(context, () {
                                    context
                                        .read<UserProvider>()
                                        .addUserActivity(UserActivity(
                                          uid: activity.uid,
                                          isManager: false,
                                        ))
                                        .then((_) => setState(() {}));
                                    Navigator.of(context).pop();
                                  }),
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
  @override
  Widget build(BuildContext context) => FutureBuilder<List<UserActivity>>(
        future: context
            .read<UserProvider>()
            .getUserActivities(isManager: widget.isHost),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userActivities = snapshot.requireData;
          return userActivities.isNotEmpty
              ? CarouselSlider.builder(
                  itemCount: userActivities.length,
                  options: CarouselOptions(
                    height: MediaQuery.of(context).size.height,
                    enlargeCenterPage: true,
                    initialPage: 0,
                    viewportFraction: 0.8,
                  ),
                  itemBuilder: (context, index, realIndex) {
                    final activityId = userActivities[index].uid;
                    return InkWell(
                      onLongPress: () => widget.isHost
                          ? ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('主辦方無法刪除活動')))
                          : showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('刪除活動'),
                                content: const Text('是否要刪除該活動？'),
                                actions: confirmButtons(context, () {
                                  context
                                      .read<UserProvider>()
                                      .removeUserActivity(activityId,
                                          isManager: false)
                                      .then((value) => setState(() {}));
                                  Navigator.of(context).pop();
                                }),
                              ),
                            ),
                      child: RoomCardWidget(
                        isHost: widget.isHost,
                        activityId: activityId,
                      ),
                    );
                  },
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
  final String activityId;

  const RoomCardWidget({
    super.key,
    required this.isHost,
    required this.activityId,
  });

  @override
  Widget build(BuildContext context) => Card(
        elevation: 4.0,
        child: FutureBuilder<Activity>(
          future: context.read<ActivityProvider>().getActivity(activityId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final activity = snapshot.requireData;
            return InkWell(
              onTap: () {
                if (activity.isEnabled) {
                  Navigator.of(context).pushNamed(
                    UserActivityMainPage.routeName,
                    arguments: UserActivityMainPageArguments(
                      activityId: activityId,
                      isPreview: false,
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('發生錯誤'),
                      content:
                          const Text('活動可能已經取消或發生錯誤\n長按活動可以刪除該活動\n若有疑問請聯繫主辦方'),
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
              child: Image.memory(
                base64ToImage(activity.activityPhoto),
                fit: BoxFit.contain,
                opacity: AlwaysStoppedAnimation(activity.isEnabled ? 1 : 0.5),
              ),
            );
          },
        ),
      );
}
