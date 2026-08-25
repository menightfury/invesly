import 'package:flutter/material.dart';
import 'package:invesly/common/presentations/widgets/simple_chip.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'Default', type: SimpleChip)
Widget buildSimpleChipUseCase(BuildContext context) {
  return Center(
    child: Column(
      mainAxisSize: .min,
      spacing: 16.0,
      children: <Widget>[
        SimpleChip(
          // elevation: 4.0,
          // color: Colors.redAccent,
          // shadowColor: Colors.red,
          // borderRadius: BorderRadius.all(Radius.circular(2.0)),
          child: const Text('Simple Card'),
        ),
      ],
    ),
  );
}
