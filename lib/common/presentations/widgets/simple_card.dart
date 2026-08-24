// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:invesly/constants.dart';

class SimpleCard extends StatelessWidget {
  SimpleCard({
    super.key,
    this.margin,
    this.padding = iCardPadding,
    this.color,
    this.elevation = 0.0,
    this.shadowColor,
    this.shape,
    this.borderRadius = iCardBorderRadius,
    this.clipBehavior = Clip.none,
    this.constraints,
    this.contentSpacing = 8.0,
    this.label,
    required this.child,
  }) : assert(margin == null || margin.isNonNegative),
       assert(padding == null || padding.isNonNegative),
       assert(!(shape != null && borderRadius != null)),
       assert(elevation == null || elevation >= 0.0);

  /// The border of the widget.
  ///
  /// This border will be painted, and in addition the outer path of the border
  /// determines the physical shape.
  final ShapeBorder? shape;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.none].
  final Clip? clipBehavior;

  /// The target z-coordinate relative to the parent at which to place this
  /// physical object.
  ///
  /// The value will always be non-negative.
  final double? elevation;

  /// The target background color.
  final Color? color;

  /// The target shadow color.
  final Color? shadowColor;

  final BorderRadius? borderRadius;

  final EdgeInsetsGeometry? margin;

  final EdgeInsetsGeometry? padding;

  final Widget? label;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  final double? contentSpacing;

  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme = CardTheme.of(context);
    final effectiveShape = shape ?? RoundedRectangleBorder(borderRadius: borderRadius ?? BorderRadius.zero);

    Widget content = child;

    if (label != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: contentSpacing ?? 0.0,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DefaultTextStyle(
            style: theme.textTheme.bodyMedium!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            child: label!,
          ),

          Align(
            alignment: Alignment.bottomRight,
            child: DefaultTextStyle(
              style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              child: content,
            ),
          ),
        ],
      );
    }

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    if (constraints != null) {
      content = ConstrainedBox(constraints: constraints!, child: content);
    }

    Widget card = PhysicalShape(
      clipBehavior: clipBehavior ?? cardTheme.clipBehavior ?? Clip.antiAlias,
      clipper: ShapeBorderClipper(shape: effectiveShape),
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

// ~ Shadow effect is not working properly
class SimpleCard2 extends StatelessWidget {
  const SimpleCard2({
    super.key,
    this.margin,
    this.padding = iCardPadding,
    this.color,
    this.elevation,
    this.shadowColor,
    this.shape,
    this.borderRadius = iCardBorderRadius,
    this.clipBehavior,
    this.label,
    required this.child,
    this.contentSpacing,
    this.constraints,
  }) : assert(elevation == null || elevation >= 0.0);

  /// The border of the widget.
  ///
  /// This border will be painted, and in addition the outer path of the border
  /// determines the physical shape.
  final ShapeBorder? shape;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.none].
  final Clip? clipBehavior;

  /// The target z-coordinate relative to the parent at which to place this
  /// physical object.
  ///
  /// The value will always be non-negative.
  final double? elevation;

  /// The target background color.
  final Color? color;

  /// The target shadow color.
  final Color? shadowColor;

  final BorderRadius? borderRadius;

  final EdgeInsetsGeometry? margin;

  final EdgeInsetsGeometry? padding;

  final Widget? label;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  final double? contentSpacing;

  final BoxConstraints? constraints;

  // ~ Convert elevation to Shadow
  List<BoxShadow> _elevationToShadow(double elevation) {
    final levels = kElevationToShadow.keys.toList();

    if (elevation <= 0) {
      return const [];
    }

    if (elevation >= levels.last) {
      return kElevationToShadow.values.last;
    }

    // Exact predefined elevation
    final elevationInt = elevation.toInt();
    if (kElevationToShadow.containsKey(elevationInt) && elevation == elevationInt) {
      return kElevationToShadow[elevationInt]!;
    }

    // Find surrounding elevations
    int lower = levels.first;
    int upper = levels.last;

    for (int i = 0; i < levels.length - 1; i++) {
      if (elevation >= levels[i] && elevation <= levels[i + 1]) {
        lower = levels[i];
        upper = levels[i + 1];
        break;
      }
    }

    final t = (elevation - lower) / (upper - lower);

    final a = kElevationToShadow[lower]!;
    final b = kElevationToShadow[upper]!;
    final shadowLength = math.min(a.length, b.length);

    return List.generate(shadowLength, (i) {
      final alpha = switch (i) {
        0 => 0.2,
        1 => 0.14,
        _ => 0.12,
      };
      return BoxShadow(
        offset: Offset.lerp(a[i].offset, b[i].offset, t)!,
        blurRadius: lerpDouble(a[i].blurRadius, b[i].blurRadius, t)!,
        spreadRadius: lerpDouble(a[i].spreadRadius, b[i].spreadRadius, t)!,
        color: color?.withValues(alpha: alpha) ?? a[i].color,
      );
    });
  }

  BoxShadow _updateShadowColor(BoxShadow shadow, Color color) {
    return shadow.copyWith(
      color: shadow.color.withValues(red: color.r, green: color.g, blue: color.b),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(margin == null || margin!.isNonNegative);
    assert(padding == null || padding!.isNonNegative);

    final theme = Theme.of(context);
    final cardTheme = CardTheme.of(context);
    final effectiveShape = shape ?? RoundedRectangleBorder(borderRadius: borderRadius ?? BorderRadius.zero);

    Widget content = child;

    if (label != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: contentSpacing ?? 0.0,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DefaultTextStyle(
            style: theme.textTheme.bodyMedium!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            child: label!,
          ),

          Align(
            alignment: Alignment.bottomRight,
            child: DefaultTextStyle(
              style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              child: content,
            ),
          ),
        ],
      );
    }

    List<BoxShadow>? shadows;
    if (elevation != null) {
      shadows = _elevationToShadow(elevation!);
      if (shadowColor != null) {
        shadows = shadows.map((shadow) => _updateShadowColor(shadow, shadowColor!)).toList();
      }
    }

    return Container(
      margin: margin,
      constraints: constraints,
      padding: padding,
      clipBehavior: clipBehavior ?? cardTheme.clipBehavior ?? Clip.none,
      decoration: ShapeDecoration(
        color: color ?? cardTheme.color ?? theme.cardTheme.color ?? theme.colorScheme.surfaceContainerLow,
        shape: effectiveShape,
        shadows: shadows,
      ),
      child: content,
    );
  }
}

class AnimatedSimpleCard extends ImplicitlyAnimatedWidget {
  AnimatedSimpleCard({
    super.key,
    this.margin,
    this.padding = iCardPadding,
    this.color,
    this.elevation = 0.0,
    this.shadowColor,
    this.shape,
    this.borderRadius = iCardBorderRadius,
    this.clipBehavior = Clip.none,
    this.constraints,
    super.curve,
    super.duration = kThemeChangeDuration,
    this.contentSpacing = 8.0,
    this.label,
    required this.child,
  }) : assert(margin == null || margin.isNonNegative),
       assert(padding == null || padding.isNonNegative),
       assert(!(shape != null && borderRadius != null)),
       assert(elevation == null || elevation >= 0.0);

  /// The border of the widget.
  ///
  /// This border will be painted, and in addition the outer path of the border
  /// determines the physical shape.
  final ShapeBorder? shape;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.none].
  final Clip? clipBehavior;

  /// The target z-coordinate relative to the parent at which to place this
  /// physical object.
  ///
  /// The value will always be non-negative.
  final double? elevation;

  /// The target background color.
  final Color? color;

  /// The target shadow color.
  final Color? shadowColor;

  final BorderRadius? borderRadius;

  final EdgeInsetsGeometry? margin;

  final EdgeInsetsGeometry? padding;

  final Widget? label;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  final double? contentSpacing;

  final BoxConstraints? constraints;

  @override
  AnimatedWidgetBaseState<AnimatedSimpleCard> createState() => _AnimatedSimpleCardState();

  // @override
  // void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  //   super.debugFillProperties(properties);
  //   properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('margin', margin));
  //   properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding));
  //   // properties.add(DiagnosticsProperty<ShapeBorder>('shape', shape));
  //   properties.add(ColorProperty('color', color));
  //   properties.add(DoubleProperty('elevation', elevation));
  //   properties.add(ColorProperty('shadowColor', shadowColor));
  // }
}

class _AnimatedSimpleCardState extends AnimatedWidgetBaseState<AnimatedSimpleCard> {
  EdgeInsetsGeometryTween? _margin;
  EdgeInsetsGeometryTween? _padding;
  ColorTween? _color;
  Tween<double>? _elevation;
  ColorTween? _shadowColor;
  // ShapeBorderTween? _border;
  Tween<double>? _spacing;

  ShapeBorder get effectiveShape =>
      widget.shape ?? RoundedRectangleBorder(borderRadius: widget.borderRadius ?? BorderRadius.zero);

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _margin =
        visitor(_margin, widget.margin, (dynamic value) => EdgeInsetsGeometryTween(begin: value as EdgeInsetsGeometry))
            as EdgeInsetsGeometryTween?;
    _padding =
        visitor(
              _padding,
              widget.padding,
              (dynamic value) => EdgeInsetsGeometryTween(begin: value as EdgeInsetsGeometry),
            )
            as EdgeInsetsGeometryTween?;
    // _border =
    //     visitor(_border, effectiveShape, (dynamic value) => ShapeBorderTween(begin: value as ShapeBorder))
    //         as ShapeBorderTween?;
    _color = visitor(_color, widget.color, (dynamic value) => ColorTween(begin: value as Color)) as ColorTween?;
    _elevation =
        visitor(_elevation, widget.elevation, (dynamic value) => Tween<double>(begin: value as double))
            as Tween<double>?;
    _shadowColor =
        visitor(_shadowColor, widget.shadowColor, (dynamic value) => ColorTween(begin: value as Color)) as ColorTween?;
    _spacing =
        visitor(_spacing, widget.contentSpacing, (dynamic value) => Tween<double>(begin: value as double))
            as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = this.animation;
    final cardTheme = CardTheme.of(context);

    return SimpleCard(
      margin: _margin?.evaluate(animation),
      padding: _padding?.evaluate(animation),
      color: _color?.evaluate(animation),
      elevation: _elevation?.evaluate(animation),
      shadowColor: _shadowColor?.evaluate(animation),
      // shape: _border?.evaluate(animation),
      clipBehavior: widget.clipBehavior ?? cardTheme.clipBehavior ?? Clip.none,
      constraints: widget.constraints!,
      contentSpacing: _spacing?.evaluate(animation),
      label: widget.label,
      child: widget.child,
    );
  }
}
