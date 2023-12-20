import 'package:flutter/material.dart';
import 'date_card.dart';

class ActivityMainContent extends StatelessWidget {
  const ActivityMainContent(
      {super.key, required this.image, required this.startDate, required this.endDate});

  final DateTime startDate;
  final DateTime endDate;
  final Image image;

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
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StartDateCard(date: startDate),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.arrow_forward),
                      ),
                      EndDateCard(date: endDate),
                    ],
                  ),
                )),
            Card(
              clipBehavior: Clip.hardEdge,
              elevation: 10,
              shadowColor: Theme.of(context).colorScheme.primary,
              child: Container(
                child: image,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
