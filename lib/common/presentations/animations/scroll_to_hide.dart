import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ScrollToHide extends StatefulWidget {
  const ScrollToHide({
    super.key,
    required this.child,
    required this.scrollController,
    this.duration = const Duration(milliseconds: 300),
    this.hideAxis = Axis.horizontal,
    this.hideDirection = ScrollDirection.reverse,
    this.isShown = true,
  });

  final Widget child;
  final ScrollController scrollController;
  final Duration duration;
  final Axis hideAxis;
  final ScrollDirection hideDirection;
  final bool isShown;

  @override
  State<ScrollToHide> createState() => _ScrollToHideState();
}

class _ScrollToHideState extends State<ScrollToHide> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: widget.duration, value: widget.isShown ? 1.0 : 0.0);
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _sizeAnimation = CurvedAnimation(parent: _animController, curve: Curves.fastOutSlowIn);
    widget.scrollController.addListener(_listen);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_listen);
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SizeTransition(axis: widget.hideAxis, axisAlignment: 1.0, sizeFactor: _sizeAnimation, child: widget.child),
    );
  }

  void _listen() {
    final shouldShow = widget.scrollController.position.userScrollDirection != widget.hideDirection;

    if (shouldShow) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }
}
