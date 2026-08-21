// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';
import 'package:flutter/material.dart';

class SimpleCard extends StatelessWidget {
  SimpleCard({
    super.key,
    this.margin,
    this.padding,
    this.color,
    this.elevation,
    this.shadowColor,
    this.shape,
    this.borderRadius,
    this.clipBehavior,
    this.label,
    required this.child,
    this.contentSpacing,
    this.constraints,
  }) : assert(margin == null || margin.isNonNegative),
       assert(padding == null || padding.isNonNegative),
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

  // ~ Convert elevation to Shadow
  List<BoxShadow> elevationShadow(double elevation) {
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

    return List.generate(3, (i) {
      return BoxShadow(
        offset: Offset(lerpDouble(a[i].offset.dx, b[i].offset.dx, t)!, lerpDouble(a[i].offset.dy, b[i].offset.dy, t)!),
        blurRadius: lerpDouble(a[i].blurRadius, b[i].blurRadius, t)!,
        spreadRadius: lerpDouble(a[i].spreadRadius, b[i].spreadRadius, t)!,
        color: a[i].color,
      );
    });
  }

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

    return Container(
      margin: margin,
      constraints: constraints,
      padding: padding,
      clipBehavior: clipBehavior ?? cardTheme.clipBehavior ?? Clip.none,
      decoration: ShapeDecoration(
        color: color ?? cardTheme.color ?? theme.cardTheme.color ?? theme.colorScheme.surfaceContainerLow,
        shape: effectiveShape,
        shadows: elevation != null ? elevationShadow(elevation!) : null,
        // elevation: elevation ?? cardTheme.elevation ?? 0.0,
        // shadowColor: shadowColor ?? cardTheme.shadowColor ?? theme.colorScheme.shadow,
      ),
      child: content,
    );
  }
}

// class AnimatedSimpleCard extends ImplicitlyAnimatedWidget {
//   AnimatedSimpleCard({
//     super.key,
//     this.color,
//     this.shadowColor,
//     this.elevation = 0.0,
//     this.shape,
//     this.borderRadius = iCardBorderRadius,
//     this.margin,
//     this.padding,
//     this.clipBehavior = Clip.antiAlias,
//     this.label,
//     required this.child,
//     this.contentSpacing = 8.0,
//     this.constraints,
//     super.curve,
//     super.duration = kThemeChangeDuration,
//   }) : assert(margin == null || margin.isNonNegative),
//        assert(padding == null || padding.isNonNegative),
//        assert(elevation == null || elevation >= 0.0);

//   /// The border of the widget.
//   ///
//   /// This border will be painted, and in addition the outer path of the border
//   /// determines the physical shape.
//   final ShapeBorder? shape;

//   /// {@macro flutter.material.Material.clipBehavior}
//   ///
//   /// Defaults to [Clip.none].
//   final Clip? clipBehavior;

//   /// The target z-coordinate relative to the parent at which to place this
//   /// physical object.
//   ///
//   /// The value will always be non-negative.
//   final double elevation;

//   /// The target background color.
//   final Color? color;

//   /// The target shadow color.
//   final Color? shadowColor;

//   final BorderRadius? borderRadius;

//   final EdgeInsetsGeometry? margin;

//   final EdgeInsetsGeometry? padding;

//   final Widget? label;

//   /// The widget below this widget in the tree.
//   ///
//   /// {@macro flutter.widgets.ProxyWidget.child}
//   final Widget child;

//   final double? contentSpacing;

//   final BoxConstraints? constraints;

//   @override
//   AnimatedWidgetBaseState<AnimatedSimpleCard> createState() => _AnimatedSimpleCardState();

//   @override
//   void debugFillProperties(DiagnosticPropertiesBuilder properties) {
//     super.debugFillProperties(properties);
//     properties.add(DiagnosticsProperty<ShapeBorder>('shape', shape));
//     properties.add(DoubleProperty('elevation', elevation));
//     properties.add(ColorProperty('color', color));
//     properties.add(DiagnosticsProperty<bool>('animateColor', animateColor));
//     properties.add(ColorProperty('shadowColor', shadowColor));
//     properties.add(DiagnosticsProperty<bool>('animateShadowColor', animateShadowColor));
//   }
// }

// class _AnimatedSimpleCardState extends AnimatedWidgetBaseState<AnimatedSimpleCard> {
//   EdgeInsetsGeometryTween? _padding;
//   ShapeBorderTween? _border;
//   Tween<double>? _elevation;
//   ColorTween? _color;
//   ColorTween? _shadowColor;

//   @override
//   void forEachTween(TweenVisitor<dynamic> visitor) {
//     _padding =
//         visitor(
//               _padding,
//               widget.padding,
//               (dynamic value) => EdgeInsetsGeometryTween(begin: value as EdgeInsetsGeometry),
//             )
//             as EdgeInsetsGeometryTween?;
//     _border =
//         visitor(_border, widget.shape, (dynamic value) => ShapeBorderTween(begin: value as ShapeBorder))
//             as ShapeBorderTween?;
//     _elevation =
//         visitor(_elevation, widget.elevation, (dynamic value) => Tween<double>(begin: value as double))
//             as Tween<double>?;
//     _color = visitor(_color, widget.color, (dynamic value) => ColorTween(begin: value as Color)) as ColorTween?;
//     _shadowColor =
//         visitor(_shadowColor, widget.shadowColor, (dynamic value) => ColorTween(begin: value as Color)) as ColorTween?;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Animation<double> animation = this.animation;

//     final theme = Theme.of(context);
//     final cardTheme = CardTheme.of(context);
//     final effectiveShape =
//         widget.shape ?? RoundedRectangleBorder(borderRadius: widget.borderRadius ?? BorderRadius.zero);

//     Widget content = widget.child;

//     if (widget.label != null) {
//       content = Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         spacing: widget.contentSpacing ?? 0.0,
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
//           DefaultTextStyle(
//             style: theme.textTheme.bodyMedium!,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//             child: widget.label!,
//           ),

//           Align(
//             alignment: Alignment.bottomRight,
//             child: DefaultTextStyle(
//               style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               child: content,
//             ),
//           ),
//         ],
//       );
//     }

//     return Container(
//       margin: widget.margin,
//       constraints: widget.constraints!,
//       padding: _padding?.evaluate(animation),
//       clipBehavior: widget.clipBehavior ?? cardTheme.clipBehavior ?? Clip.none,
//       shape: effectiveShape,
//       elevation: widget.elevation ?? cardTheme.elevation ?? 0.0,
//       color: widget.color ?? cardTheme.color ?? theme.cardTheme.color ?? theme.colorScheme.surfaceContainerLow,
//       shadowColor: widget.shadowColor ?? cardTheme.shadowColor ?? theme.colorScheme.shadow,
//       child: content,
//     );
//   }
// }
