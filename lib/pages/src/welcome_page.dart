import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const routeName = '/welcome';

  @override
  Widget build(BuildContext context) => Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 大標題
          Text(
            '歡迎使用我的 App',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          // 圖片
          Image.asset('assets/images/logo.png'),

          // 繼續使用的按鈕
          ElevatedButton(
            onPressed: () {
              // 跳轉到下一個頁面
              Navigator.pushNamed(context, '/home');
            },
            child: Text('繼續使用'),
          ),
        ],
      ),
    );
}