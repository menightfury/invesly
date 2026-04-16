import 'package:flutter/material.dart';

class Card extends StatelessWidget {
  /// Creates an elevated variant of Card.
  ///
  /// Elevated cards have a drop shadow, providing more separation from the
  /// background than filled cards, but less than outlined cards.
  ///
  /// The [elevation] must be null or non-negative.
  const Card({
    super.key,
    this.color,
    this.shadowColor,
    this.surfaceTintColor,
    this.elevation,
    this.shape,
    this.borderRadius,
    this.borderOnForeground = true,
    this.margin,
    this.clipBehavior,
    this.child,
  }) : assert(elevation == null || elevation >= 0.0),
       _variant = _CardVariant.elevated;

  /// Create a filled variant of Card.
  ///
  /// Filled cards provide subtle separation from the background. This has less
  /// emphasis than elevated cards (the default) or outlined cards.
  ///
  /// If [ThemeData.useMaterial3] is false, this constructor is equivalent to
  /// the default constructor of [Card].
  const Card.filled({
    super.key,
    this.color,
    this.shadowColor,
    this.surfaceTintColor,
    this.elevation,
    this.shape,
    this.borderRadius,
    this.borderOnForeground = true,
    this.margin,
    this.clipBehavior,
    this.child,
  }) : assert(elevation == null || elevation >= 0.0),
       _variant = _CardVariant.filled;

  /// Create an outlined variant of Card.
  ///
  /// Outlined cards have a visual boundary around the container. This can
  /// provide greater emphasis than the other types.
  ///
  /// The card's outline is defined by the [shape] property. By default, the
  /// card uses a [RoundedRectangleBorder] with a 12.0 corner radius, a 1.0
  /// border width, and the color from [ColorScheme.outlineVariant]. If you
  /// provide a custom [shape], it is recommended to use an [OutlinedBorder]
  /// with a non-null [OutlinedBorder.side] to keep a visible outline.
  ///
  /// If [ThemeData.useMaterial3] is false, this constructor is equivalent to
  /// the default constructor of [Card].
  const Card.outlined({
    super.key,
    this.color,
    this.shadowColor,
    this.surfaceTintColor,
    this.elevation,
    this.shape,
    this.borderRadius,
    this.borderOnForeground = true,
    this.margin,
    this.clipBehavior,
    this.child,
    this.semanticContainer = true,
  }) : assert(elevation == null || elevation >= 0.0),
       _variant = _CardVariant.outlined;

  /// The card's background color.
  ///
  /// Defines the card's [Material.color].
  ///
  /// If this property is null then the ambient [CardTheme.color] is used. If that is null,
  /// and [ThemeData.useMaterial3] is true, then [ColorScheme.surfaceContainerLow] of
  /// [ThemeData.colorScheme] is used. Otherwise, [ThemeData.cardColor] is used.
  final Color? color;

  /// The color to paint the shadow below the card.
  ///
  /// If null then the ambient [CardThemeData.shadowColor] is used.
  /// If that's null too, then the overall theme's [ThemeData.shadowColor]
  /// (default black) is used.
  final Color? shadowColor;

  /// The color used as an overlay on [color] to indicate elevation.
  ///
  /// This is not recommended for use. [Material 3 spec](https://m3.material.io/styles/color/the-color-system/color-roles)
  /// introduced a set of tone-based surfaces and surface containers in its [ColorScheme],
  /// which provide more flexibility. The intention is to eventually remove surface tint color from
  /// the framework.
  ///
  /// If this is null, no overlay will be applied. Otherwise this color
  /// will be composited on top of [color] with an opacity related
  /// to [elevation] and used to paint the background of the card.
  ///
  /// The default is [Colors.transparent].
  ///
  /// See [Material.surfaceTintColor] for more details on how this
  /// overlay is applied.
  final Color? surfaceTintColor;

  /// The z-coordinate at which to place this card. This controls the size of
  /// the shadow below the card.
  ///
  /// Defines the card's [Material.elevation].
  ///
  /// If this property is null then the ambient [CardThemeData.elevation] is
  /// used. If that's null, the default value is 1.0.
  final double? elevation;

  /// The shape of the card's [Material].
  ///
  /// Defines the card's [Material.shape].
  ///
  /// If null, the ambient [CardTheme.shape] from [ThemeData.cardTheme] is used.
  /// If that is also null, the shape defaults to a [RoundedRectangleBorder].
  /// The default corner radius is 12.0 when [ThemeData.useMaterial3] is true,
  /// and 4.0 otherwise. For Material 3 outlined cards, the default [shape] also
  /// includes a border side (see [OutlinedBorder.side]).
  final ShapeBorder? shape;

  final BorderRadius? borderRadius;

  /// Whether to paint the [shape] border in front of the [child].
  ///
  /// The default value is true.
  /// If false, the border will be painted behind the [child].
  final bool borderOnForeground;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// If this property is null then the ambient [CardThemeData.clipBehavior] is
  /// used. If that's null then the behavior will be [Clip.none].
  final Clip? clipBehavior;

  /// The empty space that surrounds the card.
  ///
  /// Defines the card's outer [Container.margin].
  ///
  /// If this property is null then the ambient [CardThemeData.margin] is used.
  /// If that's null, the default margin is 4.0 logical pixels on
  /// all sides: `EdgeInsets.all(4.0)`.
  final EdgeInsetsGeometry? margin;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  Color _cardColor(ThemeData theme, CardThemeData cardTheme) {
    final Color? color = cardTheme.color ?? theme.cardTheme.color;
    return color ?? theme.colorScheme.surfaceContainerLow;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme = CardTheme.of(context);
    final effectiveShape = shape ?? RoundedRectangleBorder(borderRadius: borderRadius ?? BorderRadius.zero);

    Widget card = PhysicalShape(
      clipBehavior: clipBehavior ?? cardTheme.clipBehavior ?? Clip.antiAlias,
      elevation: elevation ?? cardTheme.elevation ?? 0.0,
      color: _cardColor(theme, cardTheme),
      shadowColor: shadowColor ?? cardTheme.shadowColor ?? theme.colorScheme.shadow,
      borderOnForeground: borderOnForeground,
      clipper: ShapeBorderClipper(shape: effectiveShape, textDirection: Directionality.maybeOf(context)),
      child: child,
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
