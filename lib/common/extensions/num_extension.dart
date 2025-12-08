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
  double toPrecision(int decimalPlaces) {
    if (isInfinite || isNaN) {
      return toDouble();
    }

    final expo = pow(10.0, decimalPlaces);
    return (this * expo).round().toDouble() / expo;
  }

  // TODO: Make better name
  String toPrecisionString() {
    if (this == 0) return isNegative ? '-' : '';

    final string = toStringAsFixed(2);
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

  String toCompact() {
    if (isInfinite || isNaN) {
      return '';
    }
    return NumberFormat.compact().format(this);
  }

  String formatAsBytes(int decimals) {
    if (this <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(this) / log(1024)).floor();
    return '${(this / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
