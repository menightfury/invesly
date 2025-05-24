import 'package:flutter/material.dart';
import 'dart:math' as math;

class ColumnBuilder extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final int itemCount;

  const ColumnBuilder({
    super.key,
    this.padding,
    required this.itemBuilder,
    this.separatorBuilder,
    required this.itemCount,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
  });

  @override
  Widget build(BuildContext context) {
    final childCount = math.max(0, separatorBuilder == null ? itemCount : itemCount * 2 - 1);

    Widget child = Column(
      children: List.generate(childCount, (index) {
        if (separatorBuilder != null) {
          final int itemIndex = index ~/ 2;
          if (index.isEven) {
            return itemBuilder(context, itemIndex);
          }
          return separatorBuilder!(context, itemIndex);
        }

        return itemBuilder(context, index);
      }).toList(),
    );

    if (padding != null) {
      child = Padding(
        padding: padding!,
        child: child,
      );
    }

    return child;
  }
}
