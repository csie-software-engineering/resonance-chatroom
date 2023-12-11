import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../routes.dart';

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
    );
  }
}
