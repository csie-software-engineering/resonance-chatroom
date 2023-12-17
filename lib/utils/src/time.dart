extension StringExtension on String {
  DateTime toEpochTime() {
    return DateTime.fromMillisecondsSinceEpoch(int.parse(this));
  }
}

extension DateTimeExtension on DateTime {
  String toEpochString() {
    return millisecondsSinceEpoch.toString();
  }
}