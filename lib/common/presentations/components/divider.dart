import 'package:flutter/material.dart';

class InveslyDivider extends StatelessWidget {
  /// A list of colors used to create a gradient effect on the dotted line.
  final List<Color>? colors;

  final List<double>? stops;

  /// The thickness of the line (height for horizontal, width for vertical).
  final double thickness;

  /// The gap between dashes.
  final double dashGap;

  /// The width of each dash.
  final double dashWidth;

  /// The direction of the dotted line (horizontal or vertical).
  final Axis direction;

  /// The indentation at the start and end of the line.
  final double? indent;

  /// The indentation at the end of the line.
  final double? endIndent;

  const InveslyDivider({
    super.key,
    this.thickness = 1.0,
    this.colors,
    this.stops,
    this.direction = Axis.horizontal,
    this.indent,
    this.endIndent,
  }) : assert(thickness >= 0.0, 'Thickness must be non-negative'),
       dashGap = 0.0,
       dashWidth = double.infinity;

  const InveslyDivider.dashed({
    super.key,
    this.thickness = 1.0,
    this.colors,
    this.stops,
    this.direction = Axis.horizontal,
    this.dashGap = 10.0,
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
        size: direction == Axis.horizontal ? Size(double.infinity, thickness) : Size(thickness, double.infinity),
        painter: _LinePainter(
          colors: effectiveColors,
          stops: stops,
          thickness: thickness,
          axis: direction,
          dashGap: dashGap,
          dashWidth: dashWidth,
        ),
      ),
    );
  }
}

/// A custom painter that draws a dotted line with optional gradient and shadow
class _LinePainter extends CustomPainter {
  final List<Color> colors;
  final List<double>? stops;
  final double thickness;
  final double dashGap;
  final double dashWidth;
  final Axis axis;

  _LinePainter({
    required this.colors,
    this.stops,
    required this.thickness,
    required this.dashGap,
    required this.dashWidth,
    required this.axis,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..style = PaintingStyle.fill
          ..strokeWidth = thickness
          ..strokeCap = StrokeCap.butt;

    // Apply gradient shader if multiple colors are provided
    if (colors.length > 1) {
      final (begin, end) =
          axis == Axis.horizontal
              ? (Alignment.centerLeft, Alignment.centerRight)
              : (Alignment.topCenter, Alignment.bottomCenter);

      paint.shader = LinearGradient(
        colors: colors,
        stops: stops,
        begin: begin,
        end: end,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      paint.color = colors.first;
    }

    double position = 0.0;
    final List<Offset> dashArray = [];
    // set the starting position
    if (axis == Axis.horizontal) {
      dashArray.add(Offset(position, size.height / 2));
    } else {
      dashArray.add(Offset(size.width / 2, position));
    }

    if (dashGap > 0) {
      bool isGap = false;

      while (position < (axis == Axis.horizontal ? size.width : size.height)) {
        position += isGap ? dashGap + thickness : dashWidth;
        if (axis == Axis.horizontal) {
          dashArray.add(Offset(position, size.height / 2));
        } else {
          dashArray.add(Offset(size.width / 2, position));
        }
        isGap = !isGap;
      }
    }
    // set the last position
    if (dashArray.length.isOdd) {
      if (axis == Axis.horizontal) {
        dashArray.add(Offset(size.width, size.height / 2));
      } else {
        dashArray.add(Offset(size.width / 2, size.height));
      }
    }

    // Draw actual dotted line segment
    for (int i = 0; i < dashArray.length; i += 2) {
      canvas.drawLine(dashArray[i], dashArray[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
