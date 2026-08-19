import 'package:flutter/material.dart';
import 'package:invesly/common/extensions/color_extension.dart';
import 'package:invesly/common/presentations/widgets/color_picker.dart';
import 'package:invesly/constants.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'Default', type: InveslyColorPickerWidget)
Widget buildColorPickerUseCase(BuildContext context) {
  return Center(
    child: InveslyColorPickerWidget(
      header: Text('Pick your favorite color'),
      selectedColor: context.knobs.objectOrNull.dropdown(
        label: 'Selected color',
        labelBuilder: (value) => value.toHex(),
        options: InveslyColors.colors,
      ),
    ),
  );
}
