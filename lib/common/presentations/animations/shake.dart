import 'dart:math' as math;

import 'package:flutter/material.dart';

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

  final Widget child;
  final double shakeOffset;
  final Axis direction;
  final int shakeCount;
  final Duration duration;
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
    _animation = CurvedAnimation(parent: _controller, curve: SineCurve(count: widget.shakeCount));
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
        final offset =
            widget.direction == Axis.horizontal
                ? Offset(_animation.value * widget.shakeOffset, 0)
                : Offset(0, _animation.value * widget.shakeOffset);

        return Transform.translate(offset: offset, child: child);
      },
    );
  }
}

class ShakeWidget2 extends AnimatedWidget {
  const ShakeWidget2({
    super.key,
    required Animation<double> shakeAnimation,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.shakeCount = 3,
    this.shakeOffset = 10.0,
  }) : super(listenable: shakeAnimation);

  final Widget child;
  final double shakeOffset;
  final int shakeCount;
  final Duration duration;

  /// The animation that controls the shaking of the child.
  Animation<double> get _animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final offset = math.sin(shakeCount * 2 * math.pi * _animation.value);
    return Transform.translate(offset: Offset(offset * shakeOffset, 0), child: child);
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
