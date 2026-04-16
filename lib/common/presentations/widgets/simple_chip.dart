import 'package:flutter/material.dart';

class SimpleChip extends StatelessWidget {
  const SimpleChip({super.key, required this.title, this.color, this.titleColor});

  final Widget title;
  final Color? color;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final titleText = DefaultTextStyle(
      style: textTheme.labelSmall!.copyWith(color: titleColor),
      overflow: TextOverflow.ellipsis,
      child: title,
    );

    return PhysicalShape(
      clipper: ShapeBorderClipper(shape: const StadiumBorder()),
      color: color ?? colorScheme.primaryContainer,
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0), child: titleText),
    );
  }
}
