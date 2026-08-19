// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const iPaddingFromScreenEdge = EdgeInsets.symmetric(horizontal: 12.0);

const iButtonPadding = EdgeInsetsGeometry.symmetric(horizontal: 20.0, vertical: 16.0);
const iButtonBorderRadius = BorderRadius.all(Radius.circular(16.0));
const iButtonSize = Size(96.0, 48.0);
const iCardBorderRadius = BorderRadius.all(Radius.circular(16.0));
const iTileBorderRadius = BorderRadius.all(Radius.circular(4.0));
const iFormFieldLabelSpacing = 6.0;
const iFormFieldsInterSpacing = 12.0;
const iFormFieldContentPadding = EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0);
const iTextFieldBorderRadius = BorderRadius.all(Radius.circular(16.0));
const iFormFieldMinimumHeight = 58.0;

const iThemeChangeDuration = Duration(milliseconds: 400);

class InveslyColors {
  static const Color color1 = Color(0xFF34A853);
  static const Color color2 = Color(0xFF4285F4);
  static const Color color3 = Color(0xFF00E5FF);
  static const Color color4 = Color(0xFF3F51B5);
  static const Color color5 = Color(0xFFF05131);
  static const Color color6 = Color(0xFFE1BEE7);
  static const Color color7 = Color(0xFF008B85);

  const InveslyColors(this.data);

  final int data;

  static const List<Color> colors = <Color>[color1, color2, color3, color4, color5, color6, color7];
}
