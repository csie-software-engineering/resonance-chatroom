import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../pages/routes.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

class PersonalSettingPageArguments {
  final bool isHost;

  const PersonalSettingPageArguments({required this.isHost});
}

class PersonalSettingPage extends StatefulWidget {
  const PersonalSettingPage({Key? key}) : super(key: key);

  static const routeName = '/personal_setting';

  @override
  State<PersonalSettingPage> createState() => _PersonalSettingPageState();
}

class _PersonalSettingPageState extends State<PersonalSettingPage> {
  late final double height = MediaQuery.of(context).size.height;
  late final double width = MediaQuery.of(context).size.width;
  final AsyncMemoizer _userProfileMemoization = AsyncMemoizer<void>();
  final AsyncMemoizer _userHoldActivity = AsyncMemoizer<void>();
  late final User user;

  late final args = ModalRoute.of(context)!.settings.arguments
  as PersonalSettingPageArguments;

  late final List<UserActivity> userActivities;

  Future<void> _initProfile() async {
    user = await context.read<AuthProvider>().currentUser;
  }

  Future<void> _initHoldActivity() async {
    userActivities = await _getRelateActivities(
      args.isHost,
      context.read<ActivityProvider>(),
      context.read<UserProvider>(),
    );
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: myAppBar(
        context,
        title: const Text('使用者頁面'),
        leading: const BackButton(),
      ),
      body: FutureBuilder(
        future: _userProfileMemoization.runOnce(_initProfile),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              SizedBox(height: height * 0.01),
              CircleAvatar(
                foregroundImage:
                    user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                backgroundImage: const AssetImage('lib/assets/user.png'),
                radius: height * 0.05,
              ),
              SizedBox(height: height * 0.02),
              SizedBox(
                height: height * 0.05,
                child: _NickNameWidget(user: user, width: width, height: width,),
              ),
              SizedBox(height: height * 0.01),
              SizedBox(
                height: height * 0.05,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: width * 0.2,
                      child: const Text(
                        'Email : ',
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(
                      width: width * 0.55,
                      child: Text(
                        user.email ?? '匿名使用',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: width * 0.2)
                  ],
                ),
              ),
              SizedBox(height: height * 0.01),
              SizedBox(
                height: height * 0.05,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: width * 0.2,
                      child: const Text(
                        '目前身份 : ',
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(
                      width: width * 0.55,
                      child: Text(
                        args.isHost ? '主辦方' : '參加者',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: width * 0.2)
                  ],
                ),
              ),
              Divider(height: height * 0.03),
              Expanded(
                child: Scrollbar(
                  child: Column(
                    children: [
                      Text(
                        args.isHost ? '我舉辦過的活動' : '我參加過的活動',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                          height: height * 0.01),
                      Expanded(
                        child: FutureBuilder(
                          future: _userHoldActivity.runOnce(_initHoldActivity),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            return ListView.separated(
                              itemCount: userActivities.length,
                              itemBuilder: (context, index) {
                                final userActivity = userActivities[index];
                                return FutureBuilder<Activity>(
                                  future: context
                                      .read<ActivityProvider>()
                                      .getActivity(userActivity.uid),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }

                                    final activity = snapshot.requireData;
                                    return ListTile(
                                      leading: Icon(
                                        Icons.event,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      title: Text(activity.activityName),
                                      subtitle: args.isHost
                                          ? FutureBuilder<User>(
                                              future: context
                                                  .read<UserProvider>()
                                                  .getUser(
                                                      userId: activity.ownerId),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const Center(
                                                      child:
                                                          CircularProgressIndicator());
                                                }

                                                final host =
                                                    snapshot.requireData;
                                                return Text(
                                                  '創辦者暱稱: ${host.displayName}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                );
                                              },
                                            )
                                          : FutureBuilder<List<Tag>>(
                                              future: context
                                                  .read<ActivityProvider>()
                                                  .getAllTags(userActivity.uid),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const Center(
                                                      child:
                                                          CircularProgressIndicator());
                                                }

                                                final tags =
                                                    snapshot.requireData;
                                                return Text(
                                                  '標籤: ${userActivity.tagIds.map((utId) => tags.firstWhere((t) => t.uid == utId).tagName).join(', ')}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                );
                                              },
                                            ),
                                    );
                                  },
                                );
                              },
                              separatorBuilder: (context, index) => Divider(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.3),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            SizedBox(width: width * 0.02),
            Expanded(
              child: FloatingActionButton.extended(
                heroTag: 'changeRoleFAB',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('確認身份切換'),
                      content: Text('確定要切換成${args.isHost ? '參加者' : '主辦方'}角色嗎？'),
                      actions: confirmButtons(
                        context,
                        action: () {
                          context
                              .read<SharedPreferenceProvider>()
                              .setIsHost(!args.isHost)
                              .then((_) =>
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    MainPage.routeName,
                                    ModalRoute.withName(LoginPage.routeName),
                                    arguments: MainPageArguments(
                                      isHost: !args.isHost,
                                    ),
                                  ));
                        },
                      ),
                    ),
                  );
                },
                label: Text(
                  '切換身份',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            SizedBox(width: width * 0.05),
            Expanded(
              child: FloatingActionButton.extended(
                heroTag: 'logoutFAB',
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('確認登出'),
                      content: const Text('確定要登出嗎？'),
                      actions: confirmButtons(
                        context,
                        action: () {
                          Navigator.of(context).popUntil(
                              ModalRoute.withName(LoginPage.routeName));
                          context.read<AuthProvider>().logout();
                        },
                      ),
                    ),
                  );
                },
                label: Text(
                  '登出',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
            SizedBox(width: width * 0.02),
          ],
        ),
      ),
    );
  }

  Future<List<UserActivity>> _getRelateActivities(
    bool isHost,
    ActivityProvider activityProvider,
    UserProvider userProvider,
  ) async {
    final allActivities = await activityProvider.getAllActivities();

    final userActivities =
        await userProvider.getUserActivities(isManager: isHost);

    final activities = <UserActivity>[];

    for (final userActivity in userActivities) {
      for (final activity in allActivities) {
        if (userActivity.uid == activity.uid) {
          activities.add(userActivity);
          break;
        }
      }
    }

    return activities;
  }
}

class _NickNameWidget extends StatefulWidget {
  final User user;
  final double width;
  final double height;

  const _NickNameWidget({Key? key, required this.user, required this.width, required this.height}) : super(key: key);

  @override
  State<_NickNameWidget> createState() => _NickNameWidgetState();
}

class _NickNameWidgetState extends State<_NickNameWidget> {
  bool _setNickname = false;
  // FocusNode _focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: widget.user.displayName);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: widget.width * 0.2,
          child: const Text(
            '暱稱 : ',
            textAlign: TextAlign.right,
          ),
        ),
        SizedBox(
          width: widget.width * 0.55,
          child: _setNickname
              ? TextField(
                  controller:
                      TextEditingController(text: widget.user.displayName),
                  // focusNode: _focusNode,
                  onChanged: (value) {
                    widget.user.displayName = value;
                  },
                  onSubmitted: (_) => _rename(context),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(
                        3 + widget.height * 0.01),
                    border: InputBorder.none,
                    hintText: '輸入新的暱稱',
                  ),
                )
              : Text(
                  widget.user.displayName,
                  textAlign: TextAlign.center,
                ),
        ),
        SizedBox(
          width: widget.width * 0.2,
          child: IconButton(
            tooltip: '修改暱稱',
            icon:
                _setNickname ? const Icon(Icons.check) : const Icon(Icons.edit),
            onPressed: () {
              _rename(context);
            },
          ),
        ),
      ],
    );
  }

  void _rename(BuildContext context) {
    if (_setNickname) {
      context.read<UserProvider>().updateUser(widget.user).then(
            (_) => setState(
              () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('暱稱已更新')));
                _setNickname = false;
              },
            ),
          );
    } else {
      setState(() {
        _setNickname = true;
      });
    }
  }
}
