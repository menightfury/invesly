import 'package:flutter/painting.dart';

extension ColorX on Color {
  Color withLightness(double lightness) {
    assert(lightness >= 0 && lightness <= 1, 'Amount must be between 0 and 1');
    final hsl = HSLColor.fromColor(this);
    final newHsl = hsl.withLightness(lightness);
    return newHsl.toColor();
  }

  Color darken([double percent = 10]) {
    assert(percent >= 0 && percent <= 100, 'Amount must be between 0 and 100');
    final hsl = HSLColor.fromColor(this);
    final darkenedHsl = hsl.withLightness((hsl.lightness - percent / 100).clamp(0.0, 1.0));
    return darkenedHsl.toColor();
  }

  Color lighten([double percent = 10]) {
    assert(percent >= 0 && percent <= 100, 'Amount must be between 0 and 100');
    final hsl = HSLColor.fromColor(this);
    final lightenedHsl = hsl.withLightness((hsl.lightness + percent / 100).clamp(0.0, 1.0));
    return lightenedHsl.toColor();
  }

  String toHex({bool leadingHashSign = true}) {
    final hex = toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
    return '${leadingHashSign ? '#' : ''}$hex';
  }
}
