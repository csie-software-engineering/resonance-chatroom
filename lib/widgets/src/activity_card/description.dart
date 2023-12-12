import 'package:flutter/material.dart';

class ActivityDescription extends StatelessWidget {
  const ActivityDescription({super.key, required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          color: Theme.of(context).colorScheme.surface,
          clipBehavior: Clip.hardEdge,
          elevation: 10,
          shadowColor: Theme.of(context).colorScheme.primary,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}