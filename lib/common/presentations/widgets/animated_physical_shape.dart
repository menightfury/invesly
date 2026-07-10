import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AnimatedPhysicalShape extends ImplicitlyAnimatedWidget {
  /// Creates a widget that animates the properties of a [PhysicalShape].
  ///
  /// The [elevation] must be non-negative.
  ///
  /// Animating [color] is optional and is controlled by the [animateColor] flag.
  ///
  /// Animating [shadowColor] is optional and is controlled by the [animateShadowColor] flag.
  const AnimatedPhysicalShape({
    super.key,
    this.child,
    this.shape,
    this.borderOnForeground = true,
    this.clipBehavior = Clip.none,
    this.elevation = 0.0,
    required this.color,
    this.animateColor = true,
    this.shadowColor = const Color(0xFF000000),
    this.animateShadowColor = true,
    super.curve,
    required super.duration,
    super.onEnd,
  }) : assert(elevation >= 0.0);

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  /// The border of the widget.
  ///
  /// This border will be painted, and in addition the outer path of the border
  /// determines the physical shape.
  final ShapeBorder? shape;

  /// Whether to paint the border in front of the child.
  ///
  /// The default value is true.
  /// If false, the border will be painted behind the child.
  final bool borderOnForeground;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.none].
  final Clip clipBehavior;

  /// The target z-coordinate relative to the parent at which to place this
  /// physical object.
  ///
  /// The value will always be non-negative.
  final double elevation;

  /// The target background color.
  final Color color;

  /// Whether the color should be animated.
  final bool animateColor;

  /// The target shadow color.
  final Color shadowColor;

  /// Whether the shadow color should be animated.
  final bool animateShadowColor;

  @override
  AnimatedWidgetBaseState<AnimatedPhysicalShape> createState() => _AnimatedPhysicalShapeState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ShapeBorder>('shape', shape));
    properties.add(DoubleProperty('elevation', elevation));
    properties.add(ColorProperty('color', color));
    properties.add(DiagnosticsProperty<bool>('animateColor', animateColor));
    properties.add(ColorProperty('shadowColor', shadowColor));
    properties.add(DiagnosticsProperty<bool>('animateShadowColor', animateShadowColor));
  }
}

class _AnimatedPhysicalShapeState extends AnimatedWidgetBaseState<AnimatedPhysicalShape> {
  ShapeBorderTween? _border;
  Tween<double>? _elevation;
  ColorTween? _color;
  ColorTween? _shadowColor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _border =
        visitor(_border, widget.shape, (dynamic value) => ShapeBorderTween(begin: value as ShapeBorder))
            as ShapeBorderTween?;
    _elevation =
        visitor(_elevation, widget.elevation, (dynamic value) => Tween<double>(begin: value as double))
            as Tween<double>?;
    _color = visitor(_color, widget.color, (dynamic value) => ColorTween(begin: value as Color)) as ColorTween?;
    _shadowColor =
        visitor(_shadowColor, widget.shadowColor, (dynamic value) => ColorTween(begin: value as Color)) as ColorTween?;
  }

  @override
  Widget build(BuildContext context) {
    final ShapeBorder shape = _border!.evaluate(animation)!;

    return PhysicalShape(
      clipper: ShapeBorderClipper(shape: shape, textDirection: Directionality.maybeOf(context)),
      clipBehavior: widget.clipBehavior,
      elevation: _elevation!.evaluate(animation),
      color: widget.animateColor ? _color!.evaluate(animation)! : widget.color,
      shadowColor: widget.animateShadowColor ? _shadowColor!.evaluate(animation)! : widget.shadowColor,
      child: CustomPaint(
        painter: widget.borderOnForeground ? null : _ShapeBorderPainter(shape, Directionality.maybeOf(context)),
        foregroundPainter: widget.borderOnForeground
            ? _ShapeBorderPainter(shape, Directionality.maybeOf(context))
            : null,
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
