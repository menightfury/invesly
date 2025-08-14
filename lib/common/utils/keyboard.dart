import 'package:flutter/widgets.dart';

void minimizeKeyboard() {
  FocusNode? currentFocus = WidgetsBinding.instance.focusManager.primaryFocus;
  currentFocus?.unfocus();
}
