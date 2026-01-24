import 'package:flutter/material.dart';

class Skeleton2 extends StatelessWidget {
  const Skeleton2({
    super.key,
    this.height = 16.0,
    this.width = double.infinity,
    this.color,
    this.borderRadius,
    this.shape,
  }) : assert(!(shape != null && borderRadius != null));

  final double height, width;
  final Color? color;
  final ShapeBorder? shape;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveShape =
        shape ?? RoundedRectangleBorder(borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(16.0)));

    return LimitedBox(
      maxWidth: 100.0,
      child: ClipPath(
        clipper: ShapeBorderClipper(shape: effectiveShape, textDirection: Directionality.maybeOf(context)),
        child: ColoredBox(
          color: color ?? theme.colorScheme.primaryContainer,
          child: SizedBox(width: width, height: height),
        ),
      ),
    );
  }
}
