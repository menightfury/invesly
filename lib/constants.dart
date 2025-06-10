// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:invesly/common_libs.dart';

// *** New Constants ***
@immutable
class AppConstants {
  const AppConstants._();

  static const primaryFont = 'ZillaSlab';
  static const headerFont = 'Maragsa';
  static const buttonPadding = EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0);
  static const buttonBorderRadius = BorderRadius.all(Radius.circular(16.0));
  static const formFieldLabelSpacing = 6.0;
  static const minButtonSize = Size(112.0, 48.0);
  static const textFieldPadding = EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0);
  static const textFieldBorderRadius = BorderRadius.all(Radius.circular(8.0));
}
// *** New Constants ***

/// Animation durations
class EMTimes {
  const EMTimes._();

  static const Duration fast = Duration(milliseconds: 300);
  static const Duration med = Duration(milliseconds: 600);
  static const Duration slow = Duration(milliseconds: 900);
  static const Duration pageTransition = Duration(milliseconds: 200);
}

/// Rounded edge corner radii
class EMCorners {
  const EMCorners._();

  static const double sm = 4;
  static const double md = 8;
  static const double lg = 32;
}

/// Padding, marging and gap values
class EMInsets {
  const EMInsets._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 16;
  static const double md = 24;
  static const double lg = 32;
  static const double xl = 48;
  static const double xxl = 56;
  static const double offset = 80;

  // bootstrap5 logic
  // t - for classes that set padding-top
  // b - for classes that set padding-bottom
  // s - (start) for classes that set padding-left in LTR, padding-right in RTL
  // e - (end) for classes that set padding-right in LTR, padding-left in RTL
  // x - for classes that set both *-left and *-right
  // y - for classes that set both *-top and *-bottom
  // blank - for classes that set a padding on all 4 sides of the element
}
