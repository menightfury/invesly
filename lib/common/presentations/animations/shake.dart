import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A widget that shakes its child when triggered.
class Shake extends StatefulWidget {
  const Shake({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 167),
    this.shakeCount = 3,
    this.shakeOffset = 10.0,
    this.direction = Axis.horizontal,
    this.shake = true,
  });

  /// The widget to shake.
  final Widget child;

  /// The offset of the shake in pixels.
  final double shakeOffset;

  /// The direction of the shake.
  final Axis direction;

  /// The number of shakes to perform.
  final int shakeCount;

  /// The duration of the shake animation.
  final Duration duration;

  /// whether to shake the [child]
  final bool shake;

  @override
  State<Shake> createState() => ShakeState();
}

class ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: SineCurve(count: widget.shakeCount),
    );
    _controller.addStatusListener(_updateStatus);
    if (widget.shake) {
      shake();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_updateStatus);
    _controller.dispose();
    super.dispose();
  }

  void _updateStatus(AnimationStatus status) {
    // Reset animationController when the animation is complete
    if (status == AnimationStatus.completed) {
      _controller.reset();
    }
  }

  void shake() {
    _controller
      ..reset()
      ..forward();
  }

  @override
  void didUpdateWidget(Shake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shake) {
      shake();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final offset = widget.direction == Axis.horizontal
            ? Offset(_animation.value * widget.shakeOffset, 0)
            : Offset(0, _animation.value * widget.shakeOffset);

        return Transform.translate(offset: offset, child: child);
      },
    );
  }
}

class SineCurve extends Curve {
  const SineCurve({required this.count});
  final int count;

  @override
  double transformInternal(double t) {
    return math.sin(count * 2 * math.pi * t);
  }
}
