import 'package:flutter/material.dart';
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

    Widget card = _MaterialInterior(
      curve: Curves.fastOutSlowIn,
      duration: kThemeChangeDuration,
      clipBehavior: clipBehavior ?? cardTheme.clipBehavior ?? Clip.antiAlias,
      shape: effectiveShape,
      // clipper: ShapeBorderClipper(shape: effectiveShape, textDirection: Directionality.maybeOf(context)),
      elevation: elevation ?? cardTheme.elevation ?? 0.0,
      color: color ?? cardTheme.color ?? theme.cardTheme.color ?? theme.colorScheme.surfaceContainerLow,
      shadowColor: shadowColor ?? cardTheme.shadowColor ?? theme.colorScheme.shadow,
      child: CustomPaint(
        foregroundPainter: _ShapeBorderPainter(effectiveShape, Directionality.maybeOf(context)),
        child: content,
      ),
    );

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    return card;
  }
}

class _MaterialInterior extends ImplicitlyAnimatedWidget {
  const _MaterialInterior({
    required this.child,
    required this.shape,
    this.borderOnForeground = true,
    this.clipBehavior = Clip.none,
    required this.elevation,
    required this.color,
    required this.shadowColor,
    this.surfaceTintColor,
    super.curve,
    required super.duration,
  }) : assert(elevation >= 0.0);

  final Widget child;
  final ShapeBorder shape;
  final bool borderOnForeground;
  final Clip clipBehavior;
  final double elevation;
  final Color color;
  final Color shadowColor;
  final Color? surfaceTintColor;

  @override
  _MaterialInteriorState createState() => _MaterialInteriorState();
}

class _MaterialInteriorState extends ImplicitlyAnimatedWidgetState<_MaterialInterior> {
  Tween<double>? _elevation;
  ColorTween? _surfaceTintColor;
  ColorTween? _shadowColor;
  ShapeBorderTween? _border;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _elevation =
        visitor(_elevation, widget.elevation, (dynamic value) => Tween<double>(begin: value as double))
            as Tween<double>?;
    _shadowColor =
        visitor(_shadowColor, widget.shadowColor, (dynamic value) => ColorTween(begin: value as Color)) as ColorTween?;
    _surfaceTintColor = widget.surfaceTintColor != null
        ? visitor(_surfaceTintColor, widget.surfaceTintColor, (dynamic value) => ColorTween(begin: value as Color))
              as ColorTween?
        : null;
    _border =
        visitor(_border, widget.shape, (dynamic value) => ShapeBorderTween(begin: value as ShapeBorder))
            as ShapeBorderTween?;
  }

  @override
  Widget build(BuildContext context) {
    final ShapeBorder shape = _border!.evaluate(animation)!;
    final double elevation = _elevation!.evaluate(animation);
    final Color color = Theme.of(context).useMaterial3
        ? ElevationOverlay.applySurfaceTint(widget.color, _surfaceTintColor?.evaluate(animation), elevation)
        : ElevationOverlay.applyOverlay(context, widget.color, elevation);
    final Color shadowColor = _shadowColor!.evaluate(animation)!;

    return PhysicalShape(
      clipBehavior: widget.clipBehavior,
      clipper: ShapeBorderClipper(shape: shape, textDirection: Directionality.maybeOf(context)),
      elevation: elevation,
      color: color,
      shadowColor: shadowColor,
      child: CustomPaint(
        foregroundPainter: _ShapeBorderPainter(shape, Directionality.maybeOf(context)),
        child: widget.child,
      ),
    );
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
