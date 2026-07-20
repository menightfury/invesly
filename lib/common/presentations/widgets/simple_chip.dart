import 'package:flutter/material.dart';

class SimpleChip extends StatelessWidget {
  const SimpleChip({
    super.key,
    this.icon,
    required this.child,
    this.color,
    this.titleColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
  });

  final Widget? icon;
  final Widget child;
  final Color? color;
  final Color? titleColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    Widget content = DefaultTextStyle(
      style: textTheme.labelSmall!.copyWith(color: titleColor),
      overflow: TextOverflow.ellipsis,
      child: child,
    );

    if (icon != null) {
      content = Row(mainAxisSize: MainAxisSize.min, spacing: 4.0, children: <Widget>[icon!, content]);
    }

    return ClipPath(
      clipper: ShapeBorderClipper(shape: const StadiumBorder()),
      child: ColoredBox(
        color: color ?? colorScheme.primaryContainer,
        child: Padding(padding: padding, child: content),
      ),
    );
  }
}
