import 'package:flutter/material.dart';

class Tappable extends StatelessWidget {
  const Tappable({
    super.key,
    this.bgColor,
    this.borderRadius,
    this.shape,
    this.margin,
    this.padding,
    this.size,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    required this.child,
  });

  final Color? bgColor;
  final BorderRadius? borderRadius;
  final ShapeBorder? shape;
  final Size? size;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    Widget content = SizedBox.fromSize(size: size, child: child);

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    content = Material(
      color: bgColor,
      type: MaterialType.canvas,
      borderRadius: shape != null ? null : (borderRadius ?? const BorderRadius.all(Radius.circular(8.0))),
      shape: shape,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        onDoubleTap: onDoubleTap,
        customBorder: shape,
        borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(16.0)),
        child: content,
      ),
    );

    if (margin != null) {
      return Padding(padding: margin!, child: content);
    }

    return content;
  }
}
