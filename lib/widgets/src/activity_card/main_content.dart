import 'package:flutter/material.dart';
import 'date_card.dart';

class ActivityMainContent extends StatelessWidget {
  const ActivityMainContent(
      {super.key, required this.date, required this.imageUrl});

  final String imageUrl;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StartDateCard(date: "日期資料"),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.arrow_forward),
                      ),
                      EndDateCard(date: "日期資料"),
                    ],
                  ),
                )),
            Card(
              clipBehavior: Clip.hardEdge,
              elevation: 10,
              shadowColor: Theme.of(context).colorScheme.primary,
              child: Container(
                child: Image.network(
                  imageUrl,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}