import 'package:flutter/material.dart';

/// Builds an indicator, usually used in a stack behind the icon of a navigation bar destination.
class EMSelectionIndicator extends StatefulWidget {
  const EMSelectionIndicator({
    super.key,
    this.color,
    this.width = double.infinity,
    this.height = double.infinity,
    required this.isActive,
    this.duration = const Duration(milliseconds: 400),
    this.shape,
  });

  final Color? color;
  final double width;
  final double height;
  final Duration duration;
  final bool isActive;
  final ShapeBorder? shape;

  @override
  State<EMSelectionIndicator> createState() => _EMSelectionIndicatorState();
}

class _EMSelectionIndicatorState extends State<EMSelectionIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration, value: widget.isActive ? 1.0 : 0.0);
  }

  @override
  void didUpdateWidget(EMSelectionIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // The scale should be 0 when the animation is unselected, as soon as
        // the animation starts, the scale jumps to 40%, and then animates to
        // 100% along a curve.
        final double scale =
            _controller.isDismissed
                ? 0.0
                : Tween<double>(
                  begin: 0.4,
                  end: 1.0,
                ).transform(CurveTween(curve: Curves.easeInOutCubicEmphasized).transform(_controller.value));

        return Transform.scale(
          alignment: Alignment.center,
          scaleX: scale,
          child: Opacity(opacity: _controller.value, child: child),
        );
      },
      child: Material(
        color: widget.color ?? Theme.of(context).colorScheme.secondary,
        shape: widget.shape,
        child: SizedBox(width: widget.width, height: widget.height),
      ),
    );
  }
}
