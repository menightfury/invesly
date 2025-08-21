import 'package:flutter/material.dart';
import 'package:invesly/common/extensions/buildcontext_extension.dart';
import 'package:invesly/constants.dart';

class Tappable extends StatelessWidget {
  const Tappable({
    super.key,
    required this.content,
    this.childAlignment = Alignment.center,
    this.leading,
    this.trailing,
    this.color,
    this.borderRadius,
    this.border,
    this.shape,
    this.margin,
    this.padding,
    // this.size,
    this.height,
    this.width,
    this.spacing = 8.0,
    this.onTap,
    this.onLongPress,
  });

  final Color? color;
  final BorderRadius? borderRadius;
  final BorderSide? border;
  final ShapeBorder? shape;
  // final Size? size;
  final double? height;
  final double? width;
  final double spacing;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final Widget content;
  final AlignmentGeometry childAlignment;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final defaultShape = RoundedRectangleBorder(
      side: border ?? BorderSide.none,
      borderRadius: borderRadius ?? AppConstants.buttonBorderRadius,
    );

    Widget content = Material(
      color: color ?? context.colors.primaryContainer,
      type: MaterialType.canvas,
      shape: shape ?? defaultShape,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: spacing,
            children: <Widget>[
              ?leading,
              Flexible(
                child: Align(
                  alignment: childAlignment,
                  child: SizedBox(width: width, height: height, child: this.content),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );

    if (margin != null) {
      return Padding(padding: margin!, child: content);
    }

    return content;
  }
}
