import 'package:flutter/material.dart';

class InveslyDivider extends StatelessWidget {
  /// A list of colors used to create a gradient effect on the dotted line.
  final List<Color>? colors;

  /// The thickness of the line (height for horizontal, width for vertical).
  final double thickness;

  /// The gap between dashes.
  final double dashGap;

  /// The width of each dash.
  final double dashWidth;

  /// The direction of the dotted line (horizontal or vertical).
  final Axis axis;

  /// The indentation at the start and end of the line.
  final double? indent;

  /// The indentation at the end of the line.
  final double? endIndent;

  const InveslyDivider({
    super.key,
    this.thickness = 1.0,
    this.colors,
    this.axis = Axis.horizontal,
    this.indent,
    this.endIndent,
  }) : assert(thickness >= 0.0, 'Thickness must be non-negative');

  const InveslyDivider.dashed({
    super.key,
    this.thickness = 1.0,
    this.colors,
    this.axis = Axis.horizontal,
    this.dashGap = 5.0,
    this.dashWidth = 5.0,
    this.indent,
    this.endIndent,
  }) : assert(thickness >= 0.0, 'Thickness must be non-negative');

  @override
  Widget build(BuildContext context) {
    final effectiveColors = colors ?? [];
    if (effectiveColors.isEmpty) {
      effectiveColors.add(DividerTheme.of(context).color ?? Theme.of(context).dividerColor);
    }

    return Padding(
      padding: EdgeInsetsDirectional.only(start: indent ?? 0.0, end: endIndent ?? indent ?? 0.0),
      child: CustomPaint(
        size: axis == Axis.horizontal ? Size(double.infinity, thickness) : Size(thickness, double.infinity),
        painter: _DottedLinePainter(colors: effectiveColors, thickness: thickness, axis: axis),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<Color> colors;
  final double thickness;
  final Axis axis;

  _LinePainter({required this.colors, required this.thickness, required this.axis});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness
          ..strokeCap = StrokeCap.round;

    if (colors.length > 1) {
      final (begin, end) =
          axis == Axis.horizontal
              ? (Alignment.centerLeft, Alignment.centerRight)
              : (Alignment.topCenter, Alignment.bottomCenter);

      paint.shader = LinearGradient(
        colors: colors,
        begin: begin,
        end: end,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      paint.color = colors.first;
    }

    if (axis == Axis.horizontal) {
      canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
    } else {
      canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// A custom widget that renders a dotted line with optional gradient, shadow,
/// and configurable spacing.
class DottedLine extends StatelessWidget {
  /// A list of colors used to create a gradient effect on the dotted line.
  final List<Color> colors;

  /// The thickness of the line (height for horizontal, width for vertical).
  final double lineThickness;

  /// The gap between dashes.
  final double dashGap;

  /// The width of each dash.
  final double dashWidth;

  /// The total height of the widget (applicable for horizontal lines).
  final double height;

  /// The direction of the dotted line (horizontal or vertical).
  final Axis axis;

  /// The shadow color applied to the dashes.
  final Color shadowColor;

  /// The blur radius of the shadow.
  final double shadowBlurRadius;

  /// Creates a `DottedLine` widget with customizable properties.
  const DottedLine({
    super.key,
    this.colors = const [Colors.purple],
    this.lineThickness = 2.0,
    this.dashGap = 5.0,
    this.height = 2.0,
    this.dashWidth = 5.0,
    this.axis = Axis.horizontal,
    this.shadowColor = Colors.black54,
    this.shadowBlurRadius = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedLinePainter(
        colors: colors.isEmpty ? [Colors.purple] : colors,
        lineThickness: lineThickness,
        dashGap: dashGap,
        dashWidth: dashWidth,
        axis: axis,
        shadowColor: shadowColor,
        shadowBlurRadius: shadowBlurRadius,
      ),
      size: axis == Axis.horizontal ? Size(double.infinity, height) : Size(1, height),
    );
  }
}

/// A custom painter that draws a dotted line with optional gradient and shadow.
class _DottedLinePainter extends CustomPainter {
  final List<Color> colors;
  final double lineThickness;
  final double dashGap;
  final double dashWidth;
  final Axis axis;
  final Color shadowColor;
  final double shadowBlurRadius;

  _DottedLinePainter({
    required this.colors,
    required this.lineThickness,
    required this.dashGap,
    required this.dashWidth,
    required this.axis,
    required this.shadowColor,
    required this.shadowBlurRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = lineThickness
          ..strokeCap = StrokeCap.round;

    // Apply gradient shader if multiple colors are provided
    if (colors.length > 1) {
      final (begin, end) =
          axis == Axis.horizontal
              ? (Alignment.centerLeft, Alignment.centerRight)
              : (Alignment.topCenter, Alignment.bottomCenter);

      paint.shader = LinearGradient(
        colors: colors,
        begin: begin,
        end: end,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      paint.color = colors.first;
    }

    double startPos = 0.0;
    bool isGap = false;

    while (startPos < (axis == Axis.horizontal ? size.width : size.height)) {
      if (!isGap) {
        final (startOffset, endOffset) =
            axis == Axis.horizontal
                ? (Offset(startPos, size.height / 2), Offset(startPos + dashWidth, size.height / 2))
                : (Offset(size.width / 2, startPos), Offset(size.width / 2, startPos + dashWidth));

        // Draw actual dotted line segment
        canvas.drawLine(startOffset, endOffset, paint);
      }
      startPos += isGap ? dashGap : dashWidth;
      isGap = !isGap;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
