import 'package:flutter/material.dart';

class SimpleCard extends StatelessWidget {
  const SimpleCard({
    super.key,
    this.color,
    this.shadowColor,
    this.elevation,
    this.shape,
    this.borderRadius,
    this.margin,
    this.clipBehavior,
    this.child,
  }) : assert(elevation == null || elevation >= 0.0);

  final Color? color;
  final Color? shadowColor;
  final double? elevation;
  final ShapeBorder? shape;
  final BorderRadius? borderRadius;
  final Clip? clipBehavior;
  final EdgeInsetsGeometry? margin;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme = CardTheme.of(context);
    final effectiveShape = shape ?? RoundedRectangleBorder(borderRadius: borderRadius ?? BorderRadius.zero);

    Widget card = PhysicalShape(
      clipBehavior: clipBehavior ?? cardTheme.clipBehavior ?? Clip.antiAlias,
      clipper: ShapeBorderClipper(shape: effectiveShape, textDirection: Directionality.maybeOf(context)),
      elevation: elevation ?? cardTheme.elevation ?? 0.0,
      color: color ?? cardTheme.color ?? theme.cardTheme.color ?? theme.colorScheme.surfaceContainerLow,
      shadowColor: shadowColor ?? cardTheme.shadowColor ?? theme.colorScheme.shadow,
      child: CustomPaint(
        foregroundPainter: _ShapeBorderPainter(effectiveShape, Directionality.maybeOf(context)),
        child: child,
      ),
    );

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    return card;
  }
}

class _ShapeBorderPainter extends CustomPainter {
  _ShapeBorderPainter(this.border, this.textDirection);
  final ShapeBorder border;
  final TextDirection? textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    border.paint(canvas, Offset.zero & size, textDirection: textDirection);
  }

  @override
  bool shouldRepaint(_ShapeBorderPainter oldDelegate) {
    return oldDelegate.border != border;
  }
}
