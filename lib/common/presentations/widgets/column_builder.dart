import 'package:flutter/material.dart';
import 'dart:math' as math;

class ColumnBuilder extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final double spacing;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final int itemCount;
  final ShapeBorder? _childShape;
  final ShapeBorder? _firstChildShape;
  final ShapeBorder? _lastChildShape;

  const ColumnBuilder({
    super.key,
    this.padding,
    required this.itemBuilder,
    this.separatorBuilder,
    this.spacing = 0.0,
    required this.itemCount,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
  }) : _childShape = null,
       _firstChildShape = null,
       _lastChildShape = null;

  const ColumnBuilder.m3({
    super.key,
    this.padding,
    required this.itemBuilder,
    this.separatorBuilder,
    this.spacing = 0.0,
    required this.itemCount,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    ShapeBorder? childShape = const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
    ShapeBorder? firstChildShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(1600.0), bottom: Radius.circular(4.0)),
    ),
    ShapeBorder? lastChildShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(4.0), bottom: Radius.circular(16.0)),
    ),
  }) : _childShape = childShape,
       _firstChildShape = firstChildShape,
       _lastChildShape = lastChildShape;

  @override
  Widget build(BuildContext context) {
    final childCount = math.max(0, separatorBuilder == null ? itemCount : itemCount * 2 - 1);

    Widget child = Column(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      spacing: spacing,
      children: List.generate(childCount, (index) {
        if (separatorBuilder == null) {
          Widget item = itemBuilder(context, index);

          if (_firstChildShape != null && index == 0) {
            item = ClipPath(
              clipBehavior: Clip.hardEdge,
              clipper: ShapeBorderClipper(shape: _firstChildShape),
              child: item,
            );
          } else if (_lastChildShape != null && index == childCount - 1) {
            item = ClipPath(
              clipper: ShapeBorderClipper(shape: _lastChildShape),
              child: item,
            );
          } else if (_childShape != null) {
            item = ClipPath(
              clipper: ShapeBorderClipper(shape: _childShape),
              child: item,
            );
          }

          return item;
        }

        final int itemIndex = index ~/ 2;
        if (index.isEven) {
          Widget item = itemBuilder(context, itemIndex);

          if (_firstChildShape != null && index == 0) {
            item = ClipPath(
              clipBehavior: Clip.hardEdge,
              clipper: ShapeBorderClipper(shape: _firstChildShape),
              child: item,
            );
          } else if (_lastChildShape != null && index == childCount - 1) {
            item = ClipPath(
              clipper: ShapeBorderClipper(shape: _lastChildShape),
              child: item,
            );
          } else if (_childShape != null) {
            item = ClipPath(
              clipper: ShapeBorderClipper(shape: _childShape),
              child: item,
            );
          }

          return item;
        }
        return separatorBuilder!(context, itemIndex);
      }).toList(),
    );

    if (padding != null) {
      child = Padding(padding: padding!, child: child);
    }

    return child;
  }
}
