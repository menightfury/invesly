import 'package:flutter/material.dart';
import 'package:invesly/common/presentations/widgets/simple_card.dart';
import 'package:invesly/constants.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'Default', type: SimpleCard)
Widget buildSimpleCardUseCase(BuildContext context) {
  return Center(
    child: Column(
      mainAxisSize: .min,
      spacing: 16.0,
      children: <Widget>[
        SimpleCard(
          elevation: 2.0,
          // color: Colors.redAccent,
          shadowColor: Colors.red,
          child: const Text('Simple Card'),
        ),

        Material(
          borderRadius: iCardBorderRadius,
          elevation: 2.0,
          shadowColor: Colors.red,
          child: const Padding(padding: iCardPadding, child: Text('Material')),
        ),

        SimpleCard2(
          elevation: 2.0,
          // color: Colors.redAccent,
          shadowColor: Colors.red,
          child: const Text('Simple Card 2'),
        ),
      ],
    ),
  );
}
