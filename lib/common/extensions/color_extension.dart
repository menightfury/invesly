import 'package:flutter/painting.dart';

extension ColorX on Color {
  Color darken([double percent = 10]) {
    assert(percent >= 0 && percent <= 100, 'Amount must be between 0 and 100');
    final hsl = HSLColor.fromColor(this);
    final darkenedHsl = hsl.withLightness((hsl.lightness * (1 - percent / 100)).clamp(0.0, 1.0));
    return darkenedHsl.toColor();
  }

  Color lighten([double percent = 10]) {
    assert(percent >= 0 && percent <= 100, 'Amount must be between 0 and 100');
    final hsl = HSLColor.fromColor(this);
    final lightenedHsl = hsl.withLightness((hsl.lightness * (1 + percent / 100)).clamp(0.0, 1.0));
    return lightenedHsl.toColor();
  }
}
