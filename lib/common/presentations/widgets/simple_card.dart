import 'package:flutter/material.dart';
import 'package:invesly/common/presentations/widgets/animated_physical_shape.dart';
import 'package:invesly/constants.dart';

class SimpleCard extends StatelessWidget {
  const SimpleCard({
    super.key,
    this.color,
    this.shadowColor,
    this.elevation = 0.0,
    this.shape,
    this.borderRadius = iCardBorderRadius,
    this.margin,
    this.padding,
    this.clipBehavior = Clip.antiAlias,
    this.label,
    this.child,
    this.contentSpacing = 8.0,
  }) : assert(elevation == null || elevation >= 0.0);

  final Color? color;
  final Color? shadowColor;
  final double? elevation;
  final ShapeBorder? shape;
  final BorderRadius? borderRadius;
  final Clip? clipBehavior;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Widget? label;
  final Widget? child;
  final double? contentSpacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme = CardTheme.of(context);
    final effectiveShape = shape ?? RoundedRectangleBorder(borderRadius: borderRadius ?? BorderRadius.zero);

    Widget? labelText, childText;

    if (label != null) {
      labelText = DefaultTextStyle(
        style: theme.textTheme.bodyMedium!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        child: label!,
      );
    }

    if (child != null) {
      childText = DefaultTextStyle(
        style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
        textAlign: TextAlign.end,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        child: child!,
      );
    }

    Widget? content = childText;

    if (labelText != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: contentSpacing ?? 0.0,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          labelText,
          Align(alignment: Alignment.bottomRight, child: content),
        ],
      );
    }

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    Widget card = AnimatedPhysicalShape(
      curve: Curves.fastOutSlowIn,
      duration: kThemeChangeDuration,
      clipBehavior: clipBehavior ?? cardTheme.clipBehavior ?? Clip.antiAlias,
      shape: effectiveShape,
      // clipper: ShapeBorderClipper(shape: effectiveShape, textDirection: Directionality.maybeOf(context)),
      elevation: elevation ?? cardTheme.elevation ?? 0.0,
      color: color ?? cardTheme.color ?? theme.cardTheme.color ?? theme.colorScheme.surfaceContainerLow,
      shadowColor: shadowColor ?? cardTheme.shadowColor ?? theme.colorScheme.shadow,
      child: content,
    );

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    return card;
  }
}
