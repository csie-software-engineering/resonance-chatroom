import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.title});
  final String title;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: const BackButton(),
          title: const Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: SizedBox(
                width: 160, // <-- box的寬度
                height: 30,
                child: Align(
                  alignment: Alignment.center, // <-- 這裡設定text的對齊方式
                  child: Text(
                    'test',
                  ),
                ),
              ),
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(isOn ? Icons.lightbulb : Icons.lightbulb_outline),
              color: isOn ? Colors.amber : Colors.white,
              onPressed: () {
                setState(() {
                  isOn = !isOn;
                });
              },
            )
          ]),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
          ],
        ),
      ),
    );
  }
}
