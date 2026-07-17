import 'package:flutter/material.dart';

extension IconX on Icon {
  static const double _defaultRadius = 20.0;

  Widget inContainer(BuildContext context, {Color? color, double? radius}) {
    final theme = Theme.of(context);
    final backgroundColor = color ?? theme.colorScheme.secondaryContainer;
    final diameter = 2.0 * (radius ?? _defaultRadius);

    return SizedBox.square(
      dimension: diameter,
      child: PhysicalModel(
        color: backgroundColor,
        shape: BoxShape.circle,
        child: Center(child: Icon(genre.icon, color: genre.color.lighten(40))),
      ),
    );
  }
}
}