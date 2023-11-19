import 'package:flutter/material.dart';

class HostActivitySetPage extends StatefulWidget {
  const HostActivitySetPage({super.key, required this.title});
  final String title;

  @override
  State<HostActivitySetPage> createState() => _HostActivitySetPageState();
}

class _HostActivitySetPageState extends State<HostActivitySetPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              '請輸入活動名稱:',
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Expanded(
              child: TextField(
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
