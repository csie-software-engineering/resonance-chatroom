import 'package:flutter/material.dart';

class StartDateCard extends StatelessWidget {
  const StartDateCard({super.key, required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
        color: const Color(0xFF8EA373),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "AUG",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 10),
          Text("31",
              style: TextStyle(
                fontSize: 30,
                // fontWeight: FontWeight.w600
                color: Theme.of(context).colorScheme.onSurface,
              )),
          const SizedBox(width: 10),
          Text(
            "THU",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class EndDateCard extends StatelessWidget {
  const EndDateCard({super.key, required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
        color: const Color(0xFF8EA373),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "SEP",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 10),
          Text("02",
              style: TextStyle(
                fontSize: 30,
                // fontWeight: FontWeight.w600
                color: Theme.of(context).colorScheme.onSurface,
              )),
          const SizedBox(width: 10),
          Text(
            "SAT",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}