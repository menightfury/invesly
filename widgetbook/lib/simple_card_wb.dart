import 'package:flutter/material.dart';
import 'package:invesly/common/presentations/animations/fade_in.dart';
import 'package:invesly/common/presentations/widgets/simple_card.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'Default', type: SimpleCard)
Widget buildSimpleCardUseCase(BuildContext context) {
  return Center(
    child: FadeIn(child: SimpleCard(child: const Text('Simple Card'))),
  );
}
