// ignore_for_file: avoid_print

import 'dart:ui' show Path;

import 'package:path_parsing/path_parsing.dart';

Path getPathDataFromSvgPath(String svg) {
  if (svg.isEmpty) {
    return Path();
  }

  final parser = SvgPathStringSource(svg);
  final normalizer = SvgPathNormalizer();
  final pathProxy = _PathPrinter();
  for (final PathSegmentData seg in parser.parseSegments()) {
    normalizer.emitSegment(seg, pathProxy);
  }
  return pathProxy.path;
}

/// A [PathProxy] that dumps Flutter `Path` commands to the console.
class _PathPrinter extends PathProxy {
  _PathPrinter({Path? p}) : path = p ?? Path();

  final Path path;

  @override
  void close() {
    // print('Path.close();');
    path.close();
  }

  @override
  void cubicTo(double x1, double y1, double x2, double y2, double x3, double y3) {
    // print('Path.cubicTo($x1, $y1, $x2, $y2, $x3, $y3);');
    path.cubicTo(x1, y1, x2, y2, x3, y3);
  }

  @override
  void lineTo(double x, double y) {
    // print('Path.lineTo($x, $y);');
    path.lineTo(x, y);
  }

  @override
  void moveTo(double x, double y) {
    // print('Path.moveTo($x, $y);');
    path.moveTo(x, y);
  }
}
