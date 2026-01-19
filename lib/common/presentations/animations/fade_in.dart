// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class FadeIn extends StatefulWidget {
  const FadeIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 240),
    this.fadeIn = true,
    this.from = const Offset(0, -0.1),
    this.curve = Curves.fastOutSlowIn,
    this.controller,
  });

  final Widget child;
  final Duration duration;
  final bool fadeIn;
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

    if (widget.fadeIn) {
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
    super.didUpdateWidget(oldWidget);
    if (widget.fadeIn != oldWidget.fadeIn) {
      if (widget.fadeIn) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
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
