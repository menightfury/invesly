import 'package:flutter/material.dart';

extension IconX on Icon {
  static const double _defaultRadius = 20.0;

  Widget inContainer(BuildContext context, {Color? backgroundColor, double? radius}) {
    final theme = Theme.of(context);
    final diameter = 2.0 * (radius ?? _defaultRadius);

    return SizedBox.square(
      dimension: diameter,
      child: PhysicalModel(
        color: backgroundColor ?? theme.colorScheme.secondaryContainer,
        shape: BoxShape.circle,
        child: Center(child: this),
      ),
    );
  }
}
