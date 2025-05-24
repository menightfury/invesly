import 'package:flutter/material.dart';

class InveslyDivider extends StatelessWidget {
  const InveslyDivider({super.key, this.indent, this.endIndent, this.thickness = 1.0, this.color})
      : assert(thickness >= 0.0);

  final double thickness;
  final double? indent;
  final double? endIndent;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    Color effectiveColor = color ?? DividerTheme.of(context).color ?? Theme.of(context).dividerColor;

    return Padding(
      padding: EdgeInsetsDirectional.only(start: indent ?? 0.0, end: endIndent ?? indent ?? 0.0),
      child: ColoredBox(
        color: effectiveColor,
        child: SizedBox(height: thickness, width: double.infinity),
      ),
    );
  }
}
