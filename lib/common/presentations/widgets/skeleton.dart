import 'package:flutter/material.dart';

class Skeleton extends StatelessWidget {
  const Skeleton({super.key, this.height = 16.0, this.width = double.infinity, this.color});

  final double height, width;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      child: ColoredBox(
        color: color ?? theme.colorScheme.primaryContainer,
        child: SizedBox(width: width, height: height),
      ),
    );
  }
}
