import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routes.dart';
import '../../providers/providers.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool first = true;

  @override
  Widget build(BuildContext context) {
    final pref = context.read<SharedPreferenceProvider>().pref;

    pref.then((instance) {
      bool? isHost = instance.getBool('isHost');
      if (isHost != null) {
        if (first && context.read<AuthProvider>().getFBAUser != null) {
          Navigator.of(context).pushNamed(
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
      body: Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Column(
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
              child: ElevatedButton(
                onPressed: () {
                  context.read<AuthProvider>().signInWithGoogle().then((_) {
                    pref.then((instance) {
                      Navigator.of(context).pushNamed(
                        MainPage.routeName,
                        arguments: MainPageArguments(
                          isHost: instance.getBool('isHost')!,
                        ),
                      );
                    });
                  });
                },
                child: Row(
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
              child: ElevatedButton(
                onPressed: () {
                  context.read<AuthProvider>().signInWithFacebook().then((_) {
                    pref.then((instance) {
                      Navigator.of(context).pushNamed(
                        MainPage.routeName,
                        arguments: MainPageArguments(
                          isHost: instance.getBool('isHost')!,
                        ),
                      );
                    });
                  });
                },
                child: Row(
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
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('注意'),
                      content: const Text('匿名使用無法使用部分功能\n且無法轉移帳號資料\n也無法串辦活動\n確定要繼續嗎？'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () {
                            context
                                .read<AuthProvider>()
                                .signInWithAnonymous()
                                .then((_) {
                              pref.then((instance) {
                                Navigator.of(context).pushNamed(
                                  MainPage.routeName,
                                  arguments: MainPageArguments(
                                    isHost: false,
                                  ),
                                );
                              });
                            });
                            Navigator.of(context).pop();
                          },
                          child: const Text('確定'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  '以匿名身分繼續',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
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

                final instance = snapshot.data!;
                return _SetIsHostWidget(pref: instance);
              },
            ),
          ],
        ),
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

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '我是參與者',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.05,
            ),
          ),
          const SizedBox(width: 10),
          Switch(
            value: isHost,
            onChanged: (value) => setState(() {
              debugPrint(value.toString());
              isHost = value;
              context.read<SharedPreferenceProvider>().setIsHost(isHost);
            }),
            activeColor: Colors.transparent,
            activeTrackColor: Colors.pink,
            inactiveThumbColor: Colors.transparent,
            inactiveTrackColor: const Color(0xffA7D073),
            trackOutlineWidth: MaterialStateProperty.all(0.5),
            trackOutlineColor: MaterialStateProperty.all(Colors.black),

          ),
          const SizedBox(width: 10),
          Text(
            '我是主辦者',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.05,
            ),
          ),
        ],
      ),
    );
  }
}
