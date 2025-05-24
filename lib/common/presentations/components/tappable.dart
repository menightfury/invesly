import 'package:flutter/material.dart';

class Tappable extends StatelessWidget {
  const Tappable({
    super.key,
    this.bgColor,
    this.borderRadius,
    this.onTap,
    this.shape,
    required this.child,
    this.onLongPress,
    this.onDoubleTap,
    this.margin,
  });

  final Color? bgColor;
  final BorderRadius? borderRadius;
  final ShapeBorder? shape;
  final EdgeInsets? margin;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: bgColor,
        borderRadius: borderRadius,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          onDoubleTap: onDoubleTap,
          customBorder: shape,
          borderRadius: borderRadius,
          child: child,
        ),
      ),
    );
  }
}
