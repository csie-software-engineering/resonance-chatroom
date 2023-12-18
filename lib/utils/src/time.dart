extension DateTimeExtension on DateTime {
  String toEpochString() => millisecondsSinceEpoch.toString();
}

extension StringExtension on String {
  DateTime toEpochTime() => DateTime.fromMillisecondsSinceEpoch(int.parse(this));
}