import 'dart:math' as math;

import 'package:flutter/material.dart';

extension IconX on Icon {
  // static const double _defaultRadius = 20.0;

  Widget inContainer(BuildContext context, {Color? color, BoxBorder? border, double? radius, double? padding = 8.0}) {
    final theme = Theme.of(context);
    final iconTheme = IconTheme.of(context);

    final minSize = (size ?? iconTheme.size ?? kDefaultFontSize) + 2.0 * (padding ?? 0.0);
    final effectiveSize = math.max(minSize, 2.0 * (radius ?? 0.0));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: effectiveSize,
      height: effectiveSize,
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.secondaryContainer,
        shape: BoxShape.circle,
        border: border,
      ),
      child: Center(child: this),
    );
  }
}
