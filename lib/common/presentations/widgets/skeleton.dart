import 'package:flutter/material.dart';

class Skeleton extends StatelessWidget {
  const Skeleton({super.key, this.height = 16.0, this.width = double.infinity, this.color = Colors.white});

  final double height, width;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      child: SizedBox(width: width, height: height),
    );
  }
}
