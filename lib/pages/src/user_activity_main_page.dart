import 'package:flutter/material.dart';

class UserActivityMainPage extends StatefulWidget {
  const UserActivityMainPage({super.key});

  @override
  State<UserActivityMainPage> createState() => _UserActivityMainPageState();
}

class _UserActivityMainPageState extends State<UserActivityMainPage> {
  FloatingActionButtonLocation buttonPosition =
      FloatingActionButtonLocation.centerFloat;
  Color buttonColor = Colors.yellow;
  bool startMatching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: const BackButton(),
        // leadingWidth: 20,
        centerTitle: true,
        title: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 2, horizontal: 20.0),
                color: Theme.of(context).colorScheme.background,
                child: Text(
                  '三峽科技人 CTM',
                ),
              ),
            ),
      ),
      body: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Image.network(
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSq6O3JNBylobYryHbyakwOtJ_WX8lHitEjQg&usqp=CAU",
            ),
          ),
          CardExample(title: "日程"),
          CardExample(title: "活動"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: buttonColor,
        onPressed: () {
          setState(() {
            if (!startMatching) {
              buttonPosition = FloatingActionButtonLocation.endFloat;
              startMatching = true;
              buttonColor = Theme.of(context).colorScheme.primary;
            } else {
              buttonPosition = FloatingActionButtonLocation.centerFloat;
              startMatching = false;
              buttonColor = Theme.of(context).colorScheme.secondary;
            }
          });
        },
        child: Text(
          "配對",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
      floatingActionButtonLocation: buttonPosition,
    );
  }
}

class CardExample extends StatelessWidget {
  const CardExample({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          clipBehavior: Clip.hardEdge,
          elevation: 2,
          child: InkWell(
            onTap: () {},
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.album),
                  title: Text(
                    title,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      child: const Text('BUY TICKETS'),
                      onPressed: () {/* ... */},
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      child: const Text('LISTEN'),
                      onPressed: () {/* ... */},
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

