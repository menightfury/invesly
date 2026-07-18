import 'dart:math' as math;

import 'package:flutter/material.dart';

extension IconX on Icon {
  // static const double _defaultRadius = 20.0;

  Widget inContainer(BuildContext context, {Color? backgroundColor, double? radius, double? padding = 8.0}) {
    final theme = Theme.of(context);
    final iconTheme = IconTheme.of(context);

    final minSize = (size ?? iconTheme.size ?? kDefaultFontSize) + 2.0 * (padding ?? 0.0);
    final effectiveSize = math.max(minSize, 2.0 * (radius ?? 0.0));

    return SizedBox.square(
      dimension: effectiveSize,
      child: PhysicalModel(
        color: backgroundColor ?? theme.colorScheme.secondaryContainer,
        shape: BoxShape.circle,
        child: Center(child: this),
      ),
    );
  }
}
