// ignore_for_file: avoid_print

import 'dart:ui';

import 'package:path_parsing/path_parsing.dart';

Path getPathDataFromSvgPath(String svgPath, {Size? viewBox, Size? size}) {
  if (svgPath.isEmpty) {
    return Path();
  }

  final parser = SvgPathStringSource(svgPath);
  final normalizer = SvgPathNormalizer();
  final pathProxy = _PathProxyImpl(viewBox, size);
  for (final PathSegmentData seg in parser.parseSegments()) {
    normalizer.emitSegment(seg, pathProxy);
  }
  return pathProxy.path;
}

class _PathProxyImpl implements PathProxy {
  _PathProxyImpl([Size? viewBox, Size? size])
    : path = Path(),
      _size = size ?? viewBox ?? Size(1.0, 1.0),
      _viewBox = viewBox ?? size ?? Size(1.0, 1.0);

  final Path path;
  final Size _viewBox;
  final Size _size;

  double get _scaleX => _size.width / _viewBox.width;
  double get _scaleY => _size.height / _viewBox.height;

  @override
  void close() {
    path.close();
  }

  @override
  void cubicTo(double x1, double y1, double x2, double y2, double x3, double y3) {
    path.cubicTo(x1 * _scaleX, y1 * _scaleY, x2 * _scaleX, y2 * _scaleY, x3 * _scaleX, y3 * _scaleY);
  }

  @override
  void lineTo(double x, double y) {
    path.lineTo(x * _scaleX, y * _scaleY);
  }

  @override
  void moveTo(double x, double y) {
    path.moveTo(x * _scaleX, y * _scaleY);
  }
}
