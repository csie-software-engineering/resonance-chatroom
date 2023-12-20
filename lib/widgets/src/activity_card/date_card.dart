import 'package:flutter/material.dart';

String monthToAbbreviation(int month) {
  final monthAbbreviations = {
    1: 'JAN',
    2: 'FEB',
    3: 'MAR',
    4: 'APR',
    5: 'MAY',
    6: 'JUN',
    7: 'JUL',
    8: 'AUG',
    9: 'SEP',
    10: 'OCT',
    11: 'NOV',
    12: 'DEC',
  };
  // 检查月份是否在有效范围内
  if (month < 1 || month > 12) {
    throw ArgumentError('Invalid month: $month. Month should be between 1 and 12.');
  }

  return monthAbbreviations[month]!;
}

String numberToChinese(int number) {
  final chineseNumbers = {
    1: '一',
    2: '二',
    3: '三',
    4: '四',
    5: '五',
    6: '六',
    7: '日',
  };

  // 检查数字是否在有效范围内
  if (number < 1 || number > 7) {
    throw ArgumentError('Invalid number: $number. Number should be between 1 and 7.');
  }

  return chineseNumbers[number]!;
}

class StartDateCard extends StatelessWidget {
  const StartDateCard({super.key, required this.date});

  final DateTime date;

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
            monthToAbbreviation(date.month),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 10),
          Text(date.day.toString(),
              style: TextStyle(
                fontSize: 30,
                // fontWeight: FontWeight.w600
                color: Theme.of(context).colorScheme.onSurface,
              )),
          const SizedBox(width: 10),
          Text(
            numberToChinese(date.weekday),
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

  final DateTime date;

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
            monthToAbbreviation(date.month),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 10),
          Text(date.day.toString(),
              style: TextStyle(
                fontSize: 30,
                // fontWeight: FontWeight.w600
                color: Theme.of(context).colorScheme.onSurface,
              )),
          const SizedBox(width: 10),
          Text(
          numberToChinese(date.weekday),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
