import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../pages/routes.dart';
import '../../providers/providers.dart';

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
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as PersonalSettingPageArguments;

    return Container(
      color: Theme.of(context).colorScheme.background,
      child: FutureBuilder<User>(
        future: context.read<AuthProvider>().currentUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                '使用者資訊',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            body: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                CircleAvatar(
                  foregroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  backgroundImage: const AssetImage('lib/assets/user.png'),
                  radius: MediaQuery.of(context).size.height * 0.07,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                  child: _NickNameWidget(user: user),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: const Text(
                          'Email : ',
                          textAlign: TextAlign.right,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.55,
                        child: Text(
                          user.email ?? '匿名使用',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.2)
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: const Text(
                          '目前身份 : ',
                          textAlign: TextAlign.right,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.55,
                        child: Text(
                          args.isHost ? '主辦方' : '參加者',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.2)
                    ],
                  ),
                ),
                Divider(height: MediaQuery.of(context).size.height * 0.03),
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
                            height: MediaQuery.of(context).size.height * 0.01),
                        Expanded(
                          child: FutureBuilder<List<Activity>>(
                            future: _getRelateActivities(
                              args.isHost,
                              context.read<ActivityProvider>(),
                              context.read<UserProvider>(),
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              final activities = snapshot.data!;
                              return ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: activities.length,
                                itemBuilder: (context, index) {
                                  final activity = activities[index];
                                  return ListTile(
                                    leading: Icon(
                                      Icons.event,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    title: Text(activity.activityName),
                                    subtitle: FutureBuilder<List<Tag>>(
                                      future: context
                                          .read<ActivityProvider>()
                                          .getAllTags(activity.uid),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                        final tags = snapshot.data!;
                                        return Text(
                                          '標籤: ${tags.map((e) => e.tagName).join(', ')}',
                                          overflow: TextOverflow.ellipsis,
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: BottomAppBar(
              child: Row(
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                  Expanded(
                    child: FloatingActionButton.extended(
                      heroTag: 'changeRoleFAB',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('確認身份切換'),
                            content: Text(
                                '確定要切換成${args.isHost ? '參加者' : '主辦方'}角色嗎？'),
                            actions: [
                              FilledButton.tonal(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Theme.of(context)
                                        .colorScheme
                                        .errorContainer,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).maybePop();
                                },
                                child: Text(
                                  '取消',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                              FilledButton.tonal(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                  ),
                                ),
                                onPressed: () {
                                  context
                                      .read<SharedPreferenceProvider>()
                                      .setIsHost(!args.isHost)
                                      .then((_) => Navigator.of(context)
                                              .pushNamedAndRemoveUntil(
                                            MainPage.routeName,
                                            ModalRoute.withName(
                                                LoginPage.routeName),
                                            arguments: MainPageArguments(
                                              isHost: !args.isHost,
                                            ),
                                          ));
                                },
                                child: Text(
                                  '確定',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                              ),
                            ],
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
                  SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                  Expanded(
                    child: FloatingActionButton.extended(
                      heroTag: 'logoutFAB',
                      backgroundColor:
                          Theme.of(context).colorScheme.errorContainer,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('確認登出'),
                            content: const Text('確定要登出嗎？'),
                            actions: [
                              FilledButton.tonal(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Theme.of(context)
                                        .colorScheme
                                        .errorContainer,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).maybePop();
                                },
                                child: Text(
                                  '取消',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                              FilledButton.tonal(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context)
                                      .popUntil(ModalRoute.withName('/'));
                                  context.read<AuthProvider>().logout();
                                },
                                child: Text(
                                  '確定',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                              ),
                            ],
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
                  SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<Activity>> _getRelateActivities(
    bool isHost,
    ActivityProvider activityProvider,
    UserProvider userProvider,
  ) async {
    final allActivities = await activityProvider.getAllActivities();

    final userActivities =
        await userProvider.getUserActivities(isManager: isHost);

    final activities = <Activity>[];

    for (final activity in allActivities) {
      for (final userActivity in userActivities) {
        if (userActivity.uid == activity.uid) {
          activities.add(activity);
          break;
        }
      }
    }

    return activities;
  }
}

class _NickNameWidget extends StatefulWidget {
  final User user;

  const _NickNameWidget({Key? key, required this.user}) : super(key: key);

  @override
  State<_NickNameWidget> createState() => _NickNameWidgetState();
}

class _NickNameWidgetState extends State<_NickNameWidget> {
  bool _setNickname = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.2,
          child: const Text(
            '暱稱 : ',
            textAlign: TextAlign.right,
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.55,
          child: _setNickname
              ? TextField(
                  controller:
                      TextEditingController(text: widget.user.displayName),
                  onChanged: (value) {
                    widget.user.displayName = value;
                  },
                  onSubmitted: (_) => _rename(context),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
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
          width: MediaQuery.of(context).size.width * 0.2,
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
