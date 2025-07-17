import 'package:flutter/material.dart';
import 'package:invesly/common/extensions/buildcontext_extension.dart';
import 'package:invesly/common/presentations/styles/constants.dart';

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
    required this.child,
    this.leading,
    this.trailing,
  });

  final Color? bgColor;
  final BorderRadius? borderRadius;
  final ShapeBorder? shape;
  final Size? size;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final Widget child;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final defaultShape = ContinuousRectangleBorder(borderRadius: borderRadius ?? AppConstants.buttonBorderRadius);
    Widget content = SizedBox.fromSize(size: size, child: child);

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    content = Material(
      color: bgColor ?? context.color.primaryContainer,
      type: MaterialType.canvas,
      shape: shape ?? defaultShape,
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        shape: shape ?? defaultShape,
        title: content,
        leading: leading,
        trailing: trailing,
        dense: false,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
        minVerticalPadding: 8.0,
        minTileHeight: 48.0,
        isThreeLine: false,
      ),
    );

    if (margin != null) {
      return Padding(padding: margin!, child: content);
    }

    return content;
  }
}
