// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

// *** New Constants ***

@immutable
class AppConstants {
  const AppConstants._();

  static const buttonPadding = EdgeInsetsGeometry.symmetric(horizontal: 20.0, vertical: 12.0);
  static const buttonBorderRadius = BorderRadius.all(Radius.circular(16.0));
  static const formFieldLabelSpacing = 6.0;
  static const minButtonSize = Size(112.0, 48.0);
  static const textFieldPadding = EdgeInsetsGeometry.symmetric(horizontal: 12.0, vertical: 12.0);
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
}
