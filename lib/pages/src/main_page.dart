import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/utils.dart';
import '../routes.dart';

class MainPageArguments {
  final bool isHost;

  MainPageArguments({required this.isHost});
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
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final user = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
              toolbarHeight: MediaQuery.of(context).size.height * 0.1,
              title: Text(
                args.isHost ? '舉辦的活動' : '參加的活動',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 5,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              centerTitle: true,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              leadingWidth: MediaQuery.of(context).size.width * 0.15,
              leading: Container(
                margin: const EdgeInsets.all(0),
                padding:
                    const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10.0),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                        PersonalSettingPage.routeName,
                        arguments:
                            PersonalSettingArguments(isHost: args.isHost));
                  },
                  child: CircleAvatar(
                    foregroundImage: user.photoUrl != null
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    backgroundImage: const AssetImage('lib/assets/user.png'),
                    radius: MediaQuery.of(context).size.width * 0.15,
                  ),
                ),
              )),
          body: Container(
            color: Theme.of(context).colorScheme.background,
            child: FutureBuilder<List<UserActivity>>(
              future: context
                  .read<UserProvider>()
                  .getUserActivities(isManager: args.isHost),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
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
                          return RoomCard(
                            isHost: args.isHost,
                            activityId: userActivities[index].uid,
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          '目前沒有${args.isHost ? '舉辦' : '參加'}活動',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Navigator.of(context).pushNamed(
              //             HostActivitySetPage.routeName,
              //             arguments: const HostActivitySetPage());
              _joinActivity(context, user);
            },
            tooltip: 'Add Activity',
            child: const Icon(Icons.add_circle_outline),
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
                          final activity = snapshot.data![index];

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
                                  actions: [
                                    TextButton(
                                      child: const Text('取消'),
                                      onPressed: () =>
                                          Navigator.of(context).maybePop(),
                                    ),
                                    TextButton(
                                      child: const Text('加入'),
                                      onPressed: () {
                                        context
                                            .read<UserProvider>()
                                            .addUserActivity(UserActivity(
                                              uid: activity.uid,
                                              isManager: false,
                                            ))
                                            .then((_) => setState(() {
                                                  Navigator.of(context)
                                                      .maybePop();
                                                }));
                                      },
                                    ),
                                  ],
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
                      Navigator.of(context).maybePop();
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

// class StatisticsScreen extends StatelessWidget {
//   const StatisticsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           '統計圖',
//           style: TextStyle(
//             fontSize: 24.0,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 1.2,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.green,
//       ),
//       body: Center(
//         child: SfCartesianChart(
//           primaryXAxis: CategoryAxis(),
//           primaryYAxis: NumericAxis(minimum: 0, maximum: 40, interval: 10),
//           tooltipBehavior: TooltipBehavior(enable: true),
//           series: <ChartSeries<_ChartData, String>>[
//             ColumnSeries<_ChartData, String>(
//               dataSource: [
//                 _ChartData('數據1', 12),
//                 _ChartData('數據2', 15),
//                 _ChartData('數據3', 30),
//                 _ChartData('數據4', 6.4),
//                 _ChartData('數據5', 14), //*****
//               ],
//               xValueMapper: (_ChartData data, _) => data.x,
//               yValueMapper: (_ChartData data, _) => data.y,
//               name: 'Gold',
//               color: Color.fromRGBO(8, 142, 255, 1),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class RoomCard extends StatelessWidget {
  final bool isHost;
  final String activityId;

  const RoomCard({
    super.key,
    required this.isHost,
    required this.activityId,
  });

  @override
  Widget build(BuildContext context) => Card(
        elevation: 4.0,
        child: SizedBox(
          height: 100.0,
          child: FutureBuilder<Activity>(
            future: context.read<ActivityProvider>().getActivity(activityId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final activity = snapshot.data!;
              return InkWell(
                onTap: () {
                  if (activity.isEnabled) {
                    Navigator.of(context).pushNamed(
                      UserActivityMainPage.routeName,
                      arguments: UserActivityMainPageArguments(
                        activityId: activityId,
                      ),
                    );
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
                        content: const Text(
                            '活動可能已經取消或發生錯誤\n長按活動可以刪除該活動\n若有疑問請聯繫主辦方'),
                        actions: [
                          TextButton(
                            child: const Text('了解'),
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                        ],
                      ),
                    );
                  }
                },
                onLongPress: () => isHost
                    ? ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('主辦方無法刪除活動')))
                    : showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('刪除活動'),
                          content: const Text('是否要刪除該活動？'),
                          actions: [
                            TextButton(
                              child: const Text('取消'),
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                            TextButton(
                              child: const Text('刪除'),
                              onPressed: () {
                                context.read<UserProvider>().removeUserActivity(
                                    activityId,
                                    isManager: false);
                                Navigator.of(context).maybePop();
                              },
                            ),
                          ],
                        ),
                      ),
                child: Image.memory(
                  base64ToImage(activity.activityPhoto),
                  fit: BoxFit.contain,
                  opacity: AlwaysStoppedAnimation(activity.isEnabled ? 1 : 0.5),
                ),
              );
            },
          ),
        ),
      );
}
