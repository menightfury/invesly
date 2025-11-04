// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@immutable
class AppConstants {
  const AppConstants._();

  static const buttonPadding = EdgeInsetsGeometry.symmetric(horizontal: 20.0, vertical: 12.0);
  static const buttonBorderRadius = BorderRadius.all(Radius.circular(16.0));
  static const minButtonSize = Size(112.0, 48.0);
  static const cardBorderRadius = BorderRadius.all(Radius.circular(16.0));
  static const tileBorderRadius = BorderRadius.all(Radius.circular(4.0));
  static const formFieldLabelSpacing = 6.0;
  static const formFieldContentPadding = EdgeInsetsGeometry.symmetric(horizontal: 12.0, vertical: 16.0);
  static const textFieldBorderRadius = BorderRadius.all(Radius.circular(16.0));
}
