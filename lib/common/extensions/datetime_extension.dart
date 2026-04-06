import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  /// Get a string representation of this date in the format of "Jan 1, 2024" by default
  String toReadable([String? pattern]) {
    if (pattern != null) return DateFormat(pattern).format(this);
    return DateFormat.yMMMd().format(this);
  }

  /// Get a string representation of this date in the format of "Month Year", e.g. "January 2024"
  String toMonthYear() => DateFormat.yMMMM().format(this);

  /// Get a greeting message based on the hour of this date
  String get greetingsMsg {
    return hour <= 12
        ? 'Good Morning'
        : (hour <= 17)
        ? 'Good Afternoon'
        : 'Good Evening';
  }

  /// Change [hour] of this date
  ///
  /// set [minute] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [second] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [millisecond] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [microsecond] if you want to change it as well
  DateTime setHour(int hour, [int? minute, int? second, int? millisecond, int? microsecond]) {
    return DateTime(
      year,
      month,
      day,
      hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }

  /// Get a [DateTime] representing start of Day of this [DateTime] in local time.
  DateTime get startOfDay => setHour(0, 0, 0, 0, 0);

  /// Check if this date is in the same day as other
  bool isSameDay(DateTime other) => startOfDay == other.startOfDay;

  /// Check if this date is in the same day as [DateTime.now()]
  bool get isToday => isSameDay(DateTime.now());
}
