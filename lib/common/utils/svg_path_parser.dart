// ignore_for_file: avoid_print

import 'dart:ui';

import 'package:path_parsing/path_parsing.dart';

Path getPathDataFromSvgPath({required Size size, required Size viewBox, required String svgPath}) {
  if (svgPath.isEmpty) {
    return Path();
  }

  final parser = SvgPathStringSource(svgPath);
  final normalizer = SvgPathNormalizer();
  final pathProxy = _PathPrinter(size, viewBox);
  for (final PathSegmentData seg in parser.parseSegments()) {
    normalizer.emitSegment(seg, pathProxy);
  }
  return pathProxy.path;
}

/// A [PathProxy] that dumps Flutter `Path` commands to the console.
class _PathPrinter extends PathProxy {
  _PathPrinter([Size? size, Size? viewBox])
    : path = Path(),
      size = size ?? Size(100, 100),
      viewBox = viewBox ?? Size(100, 100);

  final Path path;
  final Size size;
  final Size viewBox;

  @override
  void close() {
    // print('Path.close();');
    path.close();
  }

  @override
  void cubicTo(double x1, double y1, double x2, double y2, double x3, double y3) {
    // print('Path.cubicTo($x1, $y1, $x2, $y2, $x3, $y3);');
    path.cubicTo(
      x1 * size.width / viewBox.width,
      y1 * size.height / viewBox.height,
      x2 * size.width / viewBox.width,
      y2 * size.height / viewBox.height,
      x3 * size.width / viewBox.width,
      y3 * size.height / viewBox.height,
    );
  }

  @override
  void lineTo(double x, double y) {
    // print('Path.lineTo($x, $y);');
    path.lineTo(x * size.width / viewBox.width, y * size.height / viewBox.height);
  }

  @override
  void moveTo(double x, double y) {
    // print('Path.moveTo($x, $y);');
    path.moveTo(x * size.width / viewBox.width, y * size.height / viewBox.height);
  }
}
