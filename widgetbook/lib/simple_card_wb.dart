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
          elevation: 4.0,
          // color: Colors.redAccent,
          // shadowColor: Colors.red,
          // borderRadius: BorderRadius.all(Radius.circular(2.0)),
          child: const Text('Simple Card'),
        ),

        SimpleCard2(
          elevation: 4.0,
          // color: Colors.redAccent,
          // shadowColor: Colors.red,
          child: const Text('Simple Card 2'),
        ),

        Material(
          borderRadius: iCardBorderRadius,
          elevation: 2.0,
          shadowColor: Colors.red,
          child: const Padding(padding: iCardPadding, child: Text('Material')),
        ),

        AnimatedSimpleCard(
          elevation: 2.0,
          // color: Colors.redAccent,
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
          shadowColor: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: const Text('Animated Simple Card'),
        ),
      ],
    ),
  );
}
