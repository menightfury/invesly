import 'package:flutter/material.dart';
import 'package:invesly/common/extensions/color_extension.dart';

class SimpleChip extends StatelessWidget {
  const SimpleChip({
    super.key,
    this.icon,
    this.color,
    this.childColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
    this.onTap,
    this.borderSide,
    this.clipBehavior = Clip.none,
    required this.child,
  });

  final Widget? icon;
  final Color? color;
  final Color? childColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final BorderSide? borderSide;
  final Widget child;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final defaultColor = color ?? colorScheme.secondaryContainer;

    Widget content = DefaultTextStyle(
      style: textTheme.labelSmall!.copyWith(color: childColor ?? colorScheme.onSecondaryContainer),
      overflow: TextOverflow.ellipsis,
      child: child,
    );

    if (icon != null) {
      content = Row(mainAxisSize: MainAxisSize.min, spacing: 4.0, children: <Widget>[icon!, content]);
    }

    content = PhysicalShape(
      clipper: ShapeBorderClipper(
        shape: StadiumBorder(side: borderSide ?? BorderSide(color: defaultColor, width: 1.0)),
      ),
      clipBehavior: clipBehavior,
      color: defaultColor.lighten(50),
      // elevation: 1.0,
      child: Padding(padding: padding, child: content),
    );

    if (onTap != null) {
      content = GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }
}
