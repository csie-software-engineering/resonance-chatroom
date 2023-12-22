import 'package:flutter/material.dart';
import 'package:resonance_chatroom/pages/routes.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const routeName = '/welcome';

  @override
  Widget build(BuildContext context) =>  Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 大標題
            const Text(
              '歡迎使用我的 App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            // 圖片
            Image.asset('lib/assets/user.png'),

            // 繼續使用的按鈕
            ElevatedButton(
              onPressed: () {
                // 跳轉到下一個頁面
                Navigator.of(context).pushNamed(LoginPage.routeName);
              },
              child: const Text('繼續使用'),
            ),
          ],
        ),
      ),
    );
}
