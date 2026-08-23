// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const iPaddingFromScreenEdge = EdgeInsets.symmetric(horizontal: 12.0);

const iButtonPadding = EdgeInsetsGeometry.symmetric(horizontal: 20.0, vertical: 16.0);
const iButtonBorderRadius = BorderRadius.all(Radius.circular(16.0));
const iButtonSize = Size(96.0, 48.0);
const iCardBorderRadius = BorderRadius.all(Radius.circular(16.0));
const iCardPadding = EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0);
const iTileBorderRadius = BorderRadius.all(Radius.circular(4.0));
const iFormFieldLabelSpacing = 6.0;
const iFormFieldsInterSpacing = 12.0;
const iFormFieldContentPadding = EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0);
const iTextFieldBorderRadius = BorderRadius.all(Radius.circular(16.0));
const iFormFieldMinimumHeight = 58.0;

const iThemeChangeDuration = Duration(milliseconds: 400);

class InveslyColors {
  static const Color green = Color(0xFF249D8F);
  static const Color blue = Color(0xFF3368A0);
  static const Color violet = Color(0xFF744577);
  static const Color indigo = Color(0xFF3F51B5);
  static const Color red = Color(0xFFBD4444);
  static const Color yellow = Color(0xFFFACE68);
  static const Color orange = Color(0xFFFF7444);

  const InveslyColors(this.data);

  final int data;

  static const List<Color> colors = <Color>[green, blue, violet, indigo, red, yellow, orange];
}
