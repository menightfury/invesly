import 'package:flutter/material.dart';

class ScaledAnimatedSwitcher extends StatelessWidget {
  const ScaledAnimatedSwitcher({
    required this.keyToWatch,
    required this.child,
    this.duration = const Duration(milliseconds: 450),
    super.key,
  });

  final String keyToWatch;
  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: const Interval(0.5, 1)));

        final scaleAnimation = Tween<double>(
          begin: 0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: const Interval(0, 1.0)));

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(alignment: Alignment.center, scale: scaleAnimation, child: child),
        );
      },
      child: SizedBox(key: ValueKey(keyToWatch), child: child),
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
        return SizeTransition(alignment: Alignment.bottomRight, sizeFactor: animation, axis: axis, child: child);
      },
      child: child,
    );
  }
}
