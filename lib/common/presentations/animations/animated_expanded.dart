// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

/// A widget that smoothly expands or collapses its child with an animation.
///
/// The animation can be configured to expand either vertically or horizontally
/// and includes both size and fade transitions.
///
/// [AnimatedExpand] is useful for cases where you want to dynamically show
/// or hide content with a smooth animation, such as expanding a section of a
/// list or a collapsible panel.
///
/// The widget automatically listens for changes to the [expand] property and
/// triggers the animation accordingly.
class AnimatedExpand extends StatefulWidget {
  /// The widget to display inside the animated container.
  final Widget child;

  /// A boolean flag indicating whether to expand or collapse the [child]
  final bool expand;

  /// The duration of the expansion/collapse animation.
  final Duration duration;

  /// The curve to use for the animation.
  final Curve curve;

  /// The axis along which to expand or collapse the child.
  /// The default is [Axis.horizontal], which means the child will expand or collapse horizontally.
  /// If set to [Axis.vertical], the child will expand or collapse vertically.
  final Axis axis;

  /// The alignment of the child when expanding or collapsing.
  ///
  /// A value of -1.0 indicates the top when [axis] is [Axis.vertical], and the start when [axis] is [Axis.horizontal].
  /// The start is on the left when the text direction in effect is [TextDirection.ltr] and on the right when it is [TextDirection.rtl].
  ///
  /// A value of 1.0 indicates the bottom or end, depending upon the [axis].
  ///
  /// A value of 0.0 (the default) indicates the center for either [axis] value.
  final double alignment;

  const AnimatedExpand({
    super.key,
    this.expand = false,
    required this.child,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.fastOutSlowIn,
    this.axis = Axis.horizontal,
    this.alignment = 1.0,
  });

  @override
  _AnimatedExpandState createState() => _AnimatedExpandState();
}

class _AnimatedExpandState extends State<AnimatedExpand> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> sizeAnimation;
  late final Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration, value: widget.expand ? 1.0 : 0.0);
    sizeAnimation = CurvedAnimation(parent: _controller, curve: widget.curve);
    fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(covariant AnimatedExpand oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expand) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SizeTransition(
        axis: widget.axis,
        axisAlignment: widget.alignment,
        sizeFactor: sizeAnimation,
        child: widget.child,
      ),
    );
  }
}

/// A widget that switches between two children with an animated size transition.
///
/// [AnimatedSizeSwitcher] ensures that the old widget remains visible until the new one
/// has fully transitioned in, making the transition smoother. It uses [AnimatedSwitcher]
/// internally, with a custom transition that animates the size of the child widget.
class AnimatedSizeSwitcher extends StatelessWidget {
  const AnimatedSizeSwitcher({
    required this.child,
    this.duration = const Duration(milliseconds: 250),
    this.enabled = true,
    this.axis = Axis.vertical,
    super.key,
  });

  final Widget child;
  final Duration duration;
  final bool enabled;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    if (enabled == false) return child;

    return AnimatedSwitcher(
      switchInCurve: Curves.fastEaseInToSlowEaseOut,
      switchOutCurve: Curves.fastOutSlowIn,
      duration: duration,
      transitionBuilder: (child, animation) {
        return SizeTransition(axisAlignment: 1, sizeFactor: animation, axis: axis, child: child);
      },
      child: child,
    );
  }
}
