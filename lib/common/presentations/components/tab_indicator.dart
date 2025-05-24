import 'package:flutter/material.dart';

/// Tab indicator
class EMTabIndicator extends Decoration {
  final double height;
  final Color color;

  const EMTabIndicator({
    this.height = 4.0,
    this.color = Colors.amber,
  });

  @override
  EMTabPainter createBoxPainter([VoidCallback? onChanged]) {
    return EMTabPainter(this, onChanged);
  }
}

class EMTabPainter extends BoxPainter {
  final EMTabIndicator decoration;

  EMTabPainter(this.decoration, super.onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);

    Rect rect;
    // if (decoration.indicatorSize == MD2IndicatorSize.full) {
    rect = Offset(offset.dx, (configuration.size!.height - decoration.height)) &
        Size(configuration.size!.width, decoration.height);
    // } else if (decoration.indicatorSize == MD2IndicatorSize.normal) {
    // rect = Offset(offset.dx + 6,
    //         (configuration.size.height - decoration.indicatorHeight ?? 3)) &
    //     Size(configuration.size.width - 12, decoration.indicatorHeight ?? 3);
    // } else if (decoration.indicatorSize == MD2IndicatorSize.tiny) {
    //   rect = Offset(offset.dx + configuration.size.width / 2 - 8,
    //           (configuration.size.height - decoration.indicatorHeight ?? 3)) &
    //       Size(16, decoration.indicatorHeight ?? 3);
    // }

    final Paint paint = Paint();
    paint.color = decoration.color;
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topRight: const Radius.circular(3.0),
          topLeft: const Radius.circular(3.0),
        ),
        paint);
  }
}
