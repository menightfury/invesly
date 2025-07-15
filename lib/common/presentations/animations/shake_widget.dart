import 'dart:math';

import 'package:flutter/material.dart';

class ShakeWidget extends StatefulWidget {
  const ShakeWidget({
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.shakeCount = 3,
    this.shakeOffset = 10.0,
    super.key,
  });

  final Widget child;
  final double shakeOffset;
  final int shakeCount;
  final Duration duration;

  @override
  State<ShakeWidget> createState() => ShakeWidgetState();
}

class SineCurve extends Curve {
  const SineCurve({this.count = 3});
  final int count;

  @override
  double transformInternal(double t) {
    return sin(count * 2 * pi * t);
  }
}

class ShakeWidgetState extends State<ShakeWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _sineAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _sineAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: SineCurve(count: widget.shakeCount)));
    _controller.addStatusListener(_updateStatus);
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_updateStatus);
    super.dispose();
  }

  void _updateStatus(AnimationStatus status) {
    // Reset animationController when the animation is complete
    if (status == AnimationStatus.completed) {
      _controller.reset();
    }
  }

  void shake() {
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sineAnimation,
      child: widget.child,
      builder: (context, child) {
        return Transform.translate(offset: Offset(_sineAnimation.value * widget.shakeOffset, 0), child: child);
      },
    );
  }
}
