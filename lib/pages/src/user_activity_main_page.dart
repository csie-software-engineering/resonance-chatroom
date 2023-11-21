import 'package:flutter/material.dart';

class UserActivityMainPage extends StatefulWidget {
  const UserActivityMainPage({super.key});

  @override
  State<UserActivityMainPage> createState() => _UserActivityMainPageState();
}

class _UserActivityMainPageState extends State<UserActivityMainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: const BackButton(),
        title: Center(
            // child: DecoratedBox(
            //   decoration: BoxDecoration(
            //     color: Theme.of(context).colorScheme.background,
            //     borderRadius: const BorderRadius.all(Radius.circular(16)),
            //   ),
              child: SizedBox(
                child: Align(
                  alignment: Alignment.center, // <-- 這裡設定text的對齊方式
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                      color: Theme.of(context).colorScheme.background,
                      child: Text(
                        '三峽科技人 CTM',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        body: Container(
          color: Colors.red,
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        child: Text("配對"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
