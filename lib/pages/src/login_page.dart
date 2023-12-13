import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../routes.dart';
import '../../models/src/user.dart';

import '../routes.dart';
import '../../providers/providers.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    late final AuthProvider authProvider = context.read<AuthProvider>();
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Login with'),
            SizedBox(
              width: 200.0,
              child: ElevatedButton(
                onPressed: () {
                  authProvider.signInWithGoogle().then((user) {
                    Navigator.of(context).pushNamed(
                      InitPage.routeName,
                      arguments: InitPageArguments(
                        title: 'title',
                        curUser: user,
                      ),
                    );
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/assets/google.png',
                      width: 15,
                      height: 15,
                    ),
                    const Text('  Google'),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 200.0,
              child: ElevatedButton(
                onPressed: () {
                  authProvider.signInWithFacebook().then((user) {
                    Navigator.of(context).pushNamed(
                      InitPage.routeName,
                      arguments: InitPageArguments(
                        title: 'title',
                        curUser: user,
                      ),
                    );
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/assets/facebook.png',
                      width: 15,
                      height: 15,
                    ),
                    const Text(' Facebook'),
                  ],
                ),
              ),
            ),
            const Text('OR'),
            SizedBox(
              width: 200.0,
              child: ElevatedButton(
                onPressed: () {
                  authProvider.signInWithAnonymous().then((user) {
                    Navigator.of(context).pushNamed(
                      InitPage.routeName,
                      arguments: InitPageArguments(
                        title: 'title',
                        curUser: user,
                      ),
                    );
                  });
                },
                child: const Text('Login as guest'),
              ),
            ),
          ],
        ),
      ),
                Text('OR'),
                SizedBox(
                    width: 200.0,
                    child: ElevatedButton(
                      onPressed: () async {
                        await authProvider.signInWithAnonymous();

                        String id = authProvider.getUserId() as String;
                        debugPrint("getUserId: ${authProvider.getUserId()}");
                        // 獲取各項活動
                        var tags1 = <UserTag>[];
                        tags1.add(UserTag(id: "111", displayName: "apple"));
                        tags1.add(UserTag(id: "222", displayName: "banana"));

                        var act = UserActivity(
                            id: "asdfghjkl",
                            displayName: "qwertyuiop",
                            tags: tags1);

                        await userProvider.addUser(User(
                          id: id,
                          displayName: "Daniel",
                          email: "daniel@gmail.com",
                        ));

                        await userProvider.addUserActivity(id, act,
                            addTag: true);

                        User acts = await userProvider.getUser(id, loadActivity: true, loadSocial: false) as User;

                        Navigator.of(context).pushNamed(Routes.initPage.value, arguments: {
                          "activities" : acts.activities,
                        });
                      },
                      child: Text('Login as guest'),
                    )
                )
              ],
            )
        )
    );
  }
}
