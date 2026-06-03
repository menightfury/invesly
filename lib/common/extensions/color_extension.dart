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
    // // Method #1
    // final f = 1 - percent / 100;
    // return Color.fromARGB(
    //   (a * 255.0).round().clamp(0, 255),
    //   (r * 255.0 * f).round().clamp(0, 255),
    //   (g * 255.0 * f).round().clamp(0, 255),
    //   (b * 255.0 * f).round().clamp(0, 255),
    // );

    // Method #2
    return Color.lerp(this, Color(0xFF000000), percent / 100)!;
  }

  Color lighten([double percent = 10]) {
    assert(percent >= 0 && percent <= 100, 'Amount must be between 0 and 100');
    // Method #1
    // final f = percent / 100;
    // return Color.fromARGB(
    //   (a * 255.0).round().clamp(0, 255),
    //   ((r * (1 - f) + f) * 255.0).round().clamp(0, 255),
    //   ((g * (1 - f) + f) * 255.0).round().clamp(0, 255),
    //   ((b * (1 - f) + f) * 255.0).round().clamp(0, 255),
    // );

    // Method #2
    return Color.lerp(this, Color(0xFFFFFFFF), percent / 100)!;
  }

  String toHex({bool leadingHashSign = true}) {
    final hex = toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
    return '${leadingHashSign ? '#' : ''}$hex';
  }
}
