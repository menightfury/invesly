import 'package:flutter/widgets.dart';

class TapZoomEffect extends StatefulWidget {
  const TapZoomEffect({
    super.key,
    required this.child,
    this.scaleFactor,
    this.duration = const Duration(milliseconds: 120),
    this.reverseDuration,
    this.curve = Curves.decelerate,
    this.reverseCurve,
    this.enabled = true,
    this.onTap,
  });

  final VoidCallback? onTap;
  final Widget child;
  final double? scaleFactor;
  final Duration duration;
  final Duration? reverseDuration;
  final Curve curve;
  final Curve? reverseCurve;
  final bool enabled;

  @override
  State<TapZoomEffect> createState() => _TapZoomEffectState();
}

class _TapZoomEffectState extends State<TapZoomEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.reverseDuration,
    );

    _animation = Tween<double>(begin: 1.0, end: widget.scaleFactor ?? 0.93)
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve, reverseCurve: widget.reverseCurve));
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Listener(
        onPointerDown: (_) async {
          await _controller.forward();
        },
        onPointerUp: (_) async {
          await _controller.reverse();
        },
        child: ScaleTransition(scale: _animation, child: widget.child),
      ),
    );
    // return GestureDetector(
    //   behavior: HitTestBehavior.translucent,
    //   onTap: () {
    //     _controller.forward();
    //     widget.onTap?.call();
    //   },
    //   onTapDown: (_) => _controller.forward(),
    //   onTapUp: (_) => Timer(const Duration(milliseconds: 150), () => _controller.reverse()),
    //   onTapCancel: () => _controller.reverse(),
    //   child: ScaleTransition(scale: _animation, child: widget.child),
    // );
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }
}

extension TappableZoomable on Widget {
  TapZoomEffect tapZoomEffect({double? scaleFactor}) {
    return TapZoomEffect(
      scaleFactor: scaleFactor ?? 0.93,
      child: this,
    );
  }
}
