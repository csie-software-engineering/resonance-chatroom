import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/src/confirm_buttons.dart';
import '../routes.dart';
import '../../providers/providers.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const routeName = '/login';

  static bool first = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final pref = context.read<SharedPreferenceProvider>().pref;

    pref.then((instance) {
      bool? isHost = instance.getBool('isHost');
      if (isHost != null) {
        if (first && context.read<AuthProvider>().getFBAUser != null) {
          Navigator.of(context).pushReplacementNamed(
            MainPage.routeName,
            arguments: MainPageArguments(isHost: isHost),
          );
          first = false;
        }
      } else {
        instance.setBool('isHost', false);
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.08),
            child: Text(
              '請先登入',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.08,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height * 0.08,
            child: FloatingActionButton.extended(
              heroTag: 'googleFAB',
              onPressed: () {
                context.read<AuthProvider>().signInWithGoogle().then((_) {
                  pref.then((instance) {
                    Navigator.of(context).pushReplacementNamed(
                      MainPage.routeName,
                      arguments: MainPageArguments(
                        isHost: instance.getBool('isHost')!,
                      ),
                    );
                  });
                });
              },
              label: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/assets/google.png',
                    width: MediaQuery.of(context).size.width * 0.08,
                    height: MediaQuery.of(context).size.height * 0.08,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '使用 Google 登入',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height * 0.08,
            child: FloatingActionButton.extended(
              heroTag: 'facebookFAB',
              onPressed: () {
                context.read<AuthProvider>().signInWithFacebook().then((_) {
                  pref.then((instance) {
                    Navigator.of(context).pushReplacementNamed(
                      MainPage.routeName,
                      arguments: MainPageArguments(
                        isHost: instance.getBool('isHost')!,
                      ),
                    );
                  });
                });
              },
              label: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/assets/facebook.png',
                    width: MediaQuery.of(context).size.width * 0.08,
                    height: MediaQuery.of(context).size.height * 0.08,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '使用 Facebook 登入',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.04),
            child: Text(
              'OR',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.05,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height * 0.08,
            child: FloatingActionButton.extended(
              heroTag: 'anonymousFAB',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('注意'),
                    content:
                        const Text('匿名使用無法使用部分功能\n且無法轉移帳號資料\n也無法串辦活動\n確定要繼續嗎？'),
                    actions: confirmButtons(
                      context,
                      action: () {
                        authProvider.signInWithAnonymous().then((_) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            MainPage.routeName,
                            (_) => false,
                            arguments: const MainPageArguments(
                              isHost: false,
                            ),
                          );
                        });
                      },
                      cancel: () => Navigator.of(context).pop(),
                    ),
                  ),
                );
              },
              label: Text(
                '以匿名身份繼續',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          FutureBuilder(
            future: pref,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              final instance = snapshot.requireData;
              return _SetIsHostWidget(pref: instance);
            },
          ),
        ],
      ),
    );
  }
}

class _SetIsHostWidget extends StatefulWidget {
  const _SetIsHostWidget({Key? key, required this.pref}) : super(key: key);

  final SharedPreferences pref;

  @override
  State<_SetIsHostWidget> createState() => _SetIsHostWidgetState();
}

class _SetIsHostWidgetState extends State<_SetIsHostWidget> {
  @override
  Widget build(BuildContext context) {
    bool isHost = widget.pref.getBool('isHost') ?? false;

    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('之後可隨時切換角色'))),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '我是參加者',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.05,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(width: 10),
            Switch.adaptive(
              value: isHost,
              onChanged: (value) => setState(() {
                isHost = value;
                context.read<SharedPreferenceProvider>().setIsHost(isHost);
              }),
              activeColor: Colors.transparent,
              activeTrackColor: Colors.lightBlue,
              inactiveThumbColor: Colors.transparent,
              inactiveTrackColor: Colors.lightGreen,
              trackOutlineWidth: MaterialStateProperty.all(0.5),
              trackOutlineColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.onBackground.withOpacity(0.5)),
              thumbIcon: MaterialStateProperty.all(
                Icon(
                  Icons.person,
                  color: isHost ? Colors.blue[900] : Colors.green[900],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '我是主辦方',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.05,
                color: Colors.blue[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
