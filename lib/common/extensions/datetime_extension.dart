import 'package:intl/intl.dart';

extension EMDateExtension on DateTime {
  String toReadable() => DateFormat.yMMMd().format(this);
  String toMonthYear() => DateFormat.yMMMM().format(this);
  String get greetingsMsg {
    return hour <= 12
        ? 'Good Morning'
        : (hour <= 17)
            ? 'Good Afternoon'
            : 'Good Evening';
  }
}
