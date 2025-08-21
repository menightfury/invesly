import 'package:flutter/material.dart';
import 'package:invesly/common/extensions/buildcontext_extension.dart';
import 'package:invesly/constants.dart';

class Tappable extends StatelessWidget {
  const Tappable({
    super.key,
    required this.child,
    this.childAlignment = Alignment.center,
    this.leading,
    this.trailing,
    this.bgColor,
    this.borderRadius,
    this.shape,
    this.margin,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0),
    this.size,
    this.onTap,
    this.onLongPress,
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
  final AlignmentGeometry childAlignment;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final defaultShape = RoundedRectangleBorder(borderRadius: borderRadius ?? AppConstants.buttonBorderRadius);
    Widget content = SizedBox.fromSize(size: size, child: child);

    content = Material(
      color: bgColor ?? context.colors.primaryContainer,
      type: MaterialType.canvas,
      shape: shape ?? defaultShape,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ?leading,
              Align(alignment: childAlignment, child: content),
              ?trailing,
            ],
          ),
        ),
        // shape: shape ?? defaultShape,
        // title: Align(alignment: childAlignment, child: content),
        // titleAlignment: ListTileTitleAlignment.titleHeight,
        // leading: leading,
        // trailing: trailing,
        // dense: false,
        // contentPadding: padding,
        // minVerticalPadding: 0.0,
        // minTileHeight: 0.0,
        // isThreeLine: false,
      ),
    );

    if (margin != null) {
      return Padding(padding: margin!, child: content);
    }

    return content;
  }
}
