import 'package:flutter/material.dart';

class SimpleChip extends StatelessWidget {
  const SimpleChip({
    super.key,
    this.icon,
    this.color,
    this.childColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
    this.onTap,
    required this.child,
  });

  final Widget? icon;
  final Color? color;
  final Color? childColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    Widget content = DefaultTextStyle(
      style: textTheme.labelSmall!.copyWith(color: childColor),
      overflow: TextOverflow.ellipsis,
      child: child,
    );

    if (icon != null) {
      content = Row(mainAxisSize: MainAxisSize.min, spacing: 4.0, children: <Widget>[icon!, content]);
    }

    content = ClipPath(
      clipper: ShapeBorderClipper(shape: const StadiumBorder()),
      child: ColoredBox(
        color: color ?? colorScheme.primaryContainer,
        child: Padding(padding: padding, child: content),
      ),
    );

    if (onTap != null) {
      content = GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }
}
