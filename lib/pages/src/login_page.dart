import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget{
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
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
                      onPressed: () {},
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
                        onPressed: () {},
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
                      onPressed: () {},
                      child: Text('Login as guest'),
                    )
                )
              ],
            )
        )
    );
  }
}

