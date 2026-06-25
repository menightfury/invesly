// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class FadeIn extends StatefulWidget {
  const FadeIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 240),
    this.enable = true,
    this.from = const Offset(0, -0.1),
    this.curve = Curves.fastOutSlowIn,
    this.controller,
  });

  final Widget child;
  final Duration duration;
  final bool enable;
  final Offset from;
  final Curve curve;
  final void Function(AnimationController)? controller;

  @override
  _FadeInState createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _position;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0, 0.65)));
    _position = Tween<Offset>(
      begin: widget.from,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.enable) {
      _controller.forward();
    }

    if (widget.controller != null) {
      widget.controller?.call(_controller);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FadeIn oldWidget) {
    if (widget.enable != oldWidget.enable && widget.enable) {
      _controller
        ..reset()
        ..forward();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FractionalTranslation(
          translation: _position.value,
          child: Opacity(opacity: _opacity.value, child: child),
        );
      },
      child: widget.child,
    );
  }
}
