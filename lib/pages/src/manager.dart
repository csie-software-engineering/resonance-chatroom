import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resonance_chatroom/pages/routes.dart';
import 'package:resonance_chatroom/providers/providers.dart';

import '../../models/models.dart';

class ManagerArguments {
  final bool isHost;

  ManagerArguments({
    required this.isHost,
  });
}

class ManagerPage extends StatefulWidget {
  const ManagerPage({Key? key}) : super(key: key);

  static const routeName = '/manager';

  @override
  State<ManagerPage> createState() => _ManagerPageState();
}

class _ManagerPageState extends State<ManagerPage> {
  bool _setNickname = false;
  String nickname = "肥老鼠";
  bool isOrganizer = false;
  List<String> userActivities = [
    "活動A",
    "活動B",
    "活動C",
    "活動D",
    "活動E",
    "活動F",
    "活動A",
    "活動B",
    "活動C",
    "活動D",
    "活動E",
    "活動F"
  ]; // 更改為使用者的活動
  List<String> organizerActivities = ["活動X", "活動Y", "活動Z"]; // 更改為主辦者的活動

  @override
  Widget build(BuildContext context) {
    final args =
    ModalRoute.of(context)!.settings.arguments as ManagerArguments;

    return FutureBuilder<User>(
        future:
        context.read<AuthProvider>().currentUser,
        context.read<ActivityProvider>().getManagers(activityId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: const Text('使用者資訊'),
            ),
            body: Column(
              children: [
                CircleAvatar(
                  foregroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  backgroundImage: const AssetImage('lib/assets/user.png'),
                  radius: MediaQuery.of(context).size.width * 0.1,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                _NickNameWidget(user: user),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.15,
                      child: const Text(
                        'Email : ',
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Text(
                        user.email ?? '匿名使用',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.15)
                  ],
                ),
                // Text(
                //   'Email : ${user.email}',
                //   textAlign: TextAlign.center,
                // ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  '目前狀態 : ${args.isHost ? '主辦者' : '使用者'}',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              ],
            ),
            // body: ListView(
            //   children: <Widget>[
            //     ListTile(
            //       title: Text('暱稱: $nickname'),
            //       trailing: IconButton(
            //         icon: const Icon(Icons.edit),
            //         onPressed: () {
            //           _showNicknameDialog();
            //         },
            //       ),
            //     ),
            //     ListTile(
            //       title: const Text('切換身分'),
            //       subtitle: isOrganizer
            //           ? const Text('當前身分: 主辦者',
            //               style: TextStyle(color: Colors.red))
            //           : const Text('當前身分: 使用者',
            //               style: TextStyle(color: Colors.lightBlue)),
            //       trailing: Switch(
            //         value: isOrganizer,
            //         onChanged: (value) {
            //           setState(() {
            //             isOrganizer = value;
            //           });
            //         },
            //       ),
            //     ),
            //     const Divider(),
            //     Text(
            //       isOrganizer ? '我主辦過的活動' : '我參加過的活動',
            //       style: const TextStyle(
            //           fontSize: 18, fontWeight: FontWeight.bold),
            //       textAlign: TextAlign.center,
            //     ),
            //     const SizedBox(height: 10),
            //     isOrganizer
            //         ? _buildOrganizerActivities()
            //         : _buildUserActivities(),
            //   ],
            // ),
            bottomNavigationBar: BottomAppBar(
              child: Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .popUntil(ModalRoute.withName(LoginPage.routeName));
                    context.read<AuthProvider>().logout();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 30),
                      Text(
                        '登出',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget _buildUserActivities() {
    return Column(
      children: userActivities
          .map((activity) => ListTile(
        title: Text(activity),
        subtitle: const Text('標籤: ...'),
        onTap: () {
          //
        },
      ))
          .toList(),
    );
  }

  Widget _buildOrganizerActivities() {
    return Column(
      children: organizerActivities
          .map((activity) => ListTile(
          title: Text(activity),
          subtitle: const Text('標籤: ...'),
          onTap: () {
            //
          }))
          .toList(),
    );
  }

  void _showNicknameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('修改暱稱'),
          content: TextField(
            onChanged: (value) {
              nickname = value;
            },
            decoration: const InputDecoration(hintText: '輸入新的暱稱'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  // 更新暱稱
                });
                Navigator.of(context).pop();
              },
              child: const Text('確定'),
            ),
          ],
        );
      },
    );
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
          width: MediaQuery.of(context).size.width * 0.15,
          child: const Text(
            '暱稱 : ',
            textAlign: TextAlign.right,
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
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
          width: MediaQuery.of(context).size.width * 0.15,
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