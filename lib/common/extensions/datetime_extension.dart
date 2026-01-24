import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  String toReadable([String? pattern]) {
    if (pattern != null) return DateFormat(pattern).format(this);
    return DateFormat.yMMMd().format(this);
  }

  String toMonthYear() => DateFormat.yMMMM().format(this);
  String get greetingsMsg {
    return hour <= 12
        ? 'Good Morning'
        : (hour <= 17)
        ? 'Good Afternoon'
        : 'Good Evening';
  }
}
