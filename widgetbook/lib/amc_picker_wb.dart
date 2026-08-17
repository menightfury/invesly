import 'package:flutter/material.dart';
import 'package:invesly/amcs/view/widgets/amc_picker_widget.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'Default', type: InveslyAmcPickerWidget)
Widget buildAmcPickerUseCase(BuildContext context) {
  return InveslyAmcPickerWidget();
}
