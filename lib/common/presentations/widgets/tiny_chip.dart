import 'package:flutter/material.dart';

class TinyChip extends StatelessWidget {
  const TinyChip({super.key, required this.title, this.color});

  final Widget title;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final titleText = DefaultTextStyle(style: textTheme.labelSmall!, overflow: TextOverflow.ellipsis, child: title);

    return PhysicalShape(
      clipper: ShapeBorderClipper(shape: const StadiumBorder()),
      color: color ?? colorScheme.primaryContainer,
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0), child: titleText),
    );
  }
}
