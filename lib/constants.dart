// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:invesly/common_libs.dart';

// *** New Constants ***
@immutable
class AppConstants {
  const AppConstants._();

  static const primaryFont = 'Fredoka';
  static const currencyFont = 'DMSerif';
  static const headerFont = 'Maragsa';
  static const buttonPadding = EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0);
  static const buttonBorderRadius = BorderRadius.all(Radius.circular(16.0));
  static const formFieldLabelSpacing = 6.0;
  static const minButtonSize = Size(112.0, 48.0);
  static const textFieldPadding = EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0);
  static const textFieldBorderRadius = BorderRadius.all(Radius.circular(8.0));

  static const lightColors = AppLightColors;
}

/// theme colors: based on FlexScheme.mango
class AppLightColors {
  AppLightColors._();

  // disabled color is onSurface (here black) color with 12% (background) and 38% (content) opacity
  static const Color teal = Color(0xFF109DA3);
  static const Color teal100 = Color(0xFFD9FEFF);
  static const Color teal900 = Color(0xFF044A4D);

  static const Color amber = Color(0xFFF1B50D);
  static const Color amber100 = Color(0xFFFEF1CD);
  static const Color amber900 = Color(0xFF634903);

  static const Color red = Color(0xFFF22105);
  static const Color red100 = Color(0xFFFED3CD);
  static const Color red900 = Color(0xFF630E03);

  static const Color green = Color(0xFF18BB0C);
  static const Color green100 = Color(0xFFEAF9DE);
  static const Color green900 = Color(0xFF07540A);

  static const Color blue = Color(0xFF057BFA);
  static const Color blue100 = Color(0xFFE3FEFF);
  static const Color blue900 = Color(0xFF003063);

  static const Color yellow = Color(0xFFF1B50D);
  static const Color yellow100 = Color(0xFFFEF1CD);
  static const Color yellow900 = Color(0xFF634903);

  // static const Color surface = Color(0xfffcfaf6);
  static const Color white = Color(0xffffffff);
  // static const Color offwhite = Color(0xfffaf6ed); // background
  static const Color offwhite = Color(0xfff7feff); // background
  // static const Color black = Color(0xff131312);
  // static const Color black = Color(0xff000000);
  static const Color black = Color(0xff080404);
}

class AppDarkColors {
  AppDarkColors._();

  // disabled color is onSurface (here white) color with 12% (background) and 38% (content) opacity
  static const primary = Color(0xffdeb059);
  static const secondary = Color(0xffafb479);
  static const error = Color(0xffffb4ab);
  static const surface = Color(0xff161512);
  static const black = Color(0xff1d1a15); // background
  static const white = Color(0xffe4e4e3); // onBachground
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
