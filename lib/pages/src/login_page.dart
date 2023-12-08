import 'package:flutter/material.dart';
import '../../providers/providers.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget{
  const LoginPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context){
    late final AuthProviders authProvider = context.read<AuthProviders>();
    return Scaffold(
        body: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Login with'),
                SizedBox(
                    width: 200.0,
                    child: ElevatedButton(
                      onPressed: () async {
                        await authProvider.signInWithGoogle();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('lib/assets/google.png', width:15, height:15),
                          Text('  Google'),
                        ],
                      ),
                    )
                ),
                SizedBox(
                    width: 200.0,
                    child: ElevatedButton(
                        onPressed: () async {
                          await authProvider.signInWithFacebook();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('lib/assets/facebook.png', width: 15, height: 15),
                            Text(' Facebook'),
                          ],
                        )
                    )
                ),
                Text('OR'),
                SizedBox(
                    width: 200.0,
                    child: ElevatedButton(
                      onPressed: () async {
                        await authProvider.signInWithAnonymous();
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
