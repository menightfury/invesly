import 'dart:math';

import 'package:intl/intl.dart';

extension IntX on int {
  Duration get microseconds => Duration(microseconds: round());
  Duration get ms => (this * 1000).microseconds;
  Duration get milliseconds => (this * 1000).microseconds;
  Duration get seconds => (this * 1000 * 1000).microseconds;
  Duration get minutes => (this * 1000 * 1000 * 60).microseconds;
  Duration get hours => (this * 1000 * 1000 * 60 * 60).microseconds;
  Duration get days => (this * 1000 * 1000 * 60 * 60 * 24).microseconds;
}

extension EMDoubleExtension on num {
  /// Rounds the number to the specified number of decimal places.
  double toPrecisionDouble(int decimalPlaces) {
    if (isInfinite || isNaN) {
      return toDouble();
    }

    final expo = pow(10.0, decimalPlaces);
    return (this * expo).round().toDouble() / expo;
  }

  // TODO: Make better name
  /// Converts the number to a string with a specified number of decimal places, removing trailing zeros.
  String toPrecisionString(int decimalPlaces) {
    if (this == 0) return isNegative ? '-' : '';

    final string = toStringAsFixed(decimalPlaces);
    if (!string.contains('.')) return string;

    int index = string.length - 1;
    while (string[index] == '0') {
      index--;
    }
    if (string[index] == '.') {
      index--;
    }

    return string.substring(0, index + 1);
  }

  /// Converts the number to a compact string representation (e.g., 1.2K, 3.4M).
  String toCompact() {
    if (isInfinite || isNaN) {
      return '';
    }
    return NumberFormat.compact().format(this);
  }

  /// Converts the number to a human-readable string with appropriate byte units (e.g., 1.2 KB, 3.4 MB).
  String formatAsBytes(int decimals) {
    if (this <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(this) / log(1024)).floor();
    return '${(this / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
