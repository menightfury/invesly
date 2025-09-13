import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

///
/// A widget renders shimmer effect over [child] widget tree.
///
/// * Use static [Widget] (which is an instance of [StatelessWidget]).
/// * [Widget] should be a solid color element. Every colors you set on these
/// [Widget]s will be overridden by colors of [gradient].
/// * Shimmer effect only affects to opaque areas of [child], transparent areas
/// still stays transparent.
///
/// ### Pro tips:
/// * use one [Shimmer] to wrap list of [Widget]s instead of a list of many [Shimmer]s
///
@immutable
class Shimmer extends StatefulWidget {
  /// [child] defines an area that shimmer effect blends on. You can build [child]
  /// from whatever [Widget] you like but there're some notices in order to get
  /// exact expected effect and get better rendering performance:
  ///
  /// * [child] should be made of basic and simple [Widget]s, such as [Container],
  /// [Row] and [Column], to avoid side effect.
  final Widget child;

  /// [period] controls the speed of shimmer effect. The default value is 1500
  /// milliseconds.
  final Duration period;

  /// [gradient] controls colors of shimmer effect.
  final Gradient gradient;

  /// [loop] the number of animation loop, set value of `0` to make animation run
  /// forever.
  final int loop;

  /// [isAnimating] controls if shimmer effect is active. When set to false the animation
  /// is paused
  final bool isAnimating;

  /// [isLoading] controls if shimmer effect is shown. When set to false the [child]
  /// will be displayed without the shimmer effect.
  final bool isLoading;

  const Shimmer({
    super.key,
    required this.child,
    this.gradient = const LinearGradient(
      colors: [Colors.black12, Colors.white10, Colors.black12],
      stops: [0.1, 0.3, 0.4],
      begin: Alignment(-1.0, -0.3),
      end: Alignment(1.0, 0.3),
    ),
    this.period = const Duration(milliseconds: 1500),
    this.loop = 0,
    this.isAnimating = true,
    this.isLoading = true,
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..addStatusListener((AnimationStatus status) {
        if (status != AnimationStatus.completed) {
          return;
        }
        _count++;
        if (widget.loop <= 0) {
          _controller.repeat();
        } else if (_count < widget.loop) {
          _controller.forward(from: 0.0);
        }
      });
    if (widget.isAnimating) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(Shimmer oldWidget) {
    if (widget.isAnimating) {
      _controller.forward();
    } else {
      _controller.stop();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return _ShimmerRenderWidget(gradient: widget.gradient, percent: _controller.value, child: child);
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

@immutable
class _ShimmerRenderWidget extends SingleChildRenderObjectWidget {
  final double percent;
  final Gradient gradient;

  const _ShimmerRenderWidget({required this.percent, required this.gradient, super.child});

  @override
  _ShimmerFilter createRenderObject(BuildContext context) {
    return _ShimmerFilter(percent, gradient);
  }

  @override
  void updateRenderObject(BuildContext context, _ShimmerFilter shimmer) {
    shimmer.percent = percent;
    shimmer.gradient = gradient;
  }
}

class _ShimmerFilter extends RenderProxyBox {
  Gradient _gradient;
  double _percent;

  _ShimmerFilter(this._percent, this._gradient);

  @override
  ShaderMaskLayer? get layer => super.layer as ShaderMaskLayer?;

  @override
  bool get alwaysNeedsCompositing => child != null;

  set percent(double newValue) {
    if (newValue == _percent) {
      return;
    }
    _percent = newValue;
    markNeedsPaint();
  }

  set gradient(Gradient newValue) {
    if (newValue == _gradient) {
      return;
    }
    _gradient = newValue;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      assert(needsCompositing);

      final double width = child!.size.width;
      final double height = child!.size.height;
      Rect rect;

      final dx = _offset(-width, width, _percent);
      final dy = 0.0;
      rect = Rect.fromLTWH(dx - width, dy, 3 * width, height);

      layer ??= ShaderMaskLayer();
      layer!
        ..shader = _gradient.createShader(rect)
        ..maskRect = offset & size
        ..blendMode = BlendMode.srcIn;
      context.pushLayer(layer!, super.paint, offset);
    } else {
      layer = null;
    }
  }

  double _offset(double start, double end, double percent) {
    return start + (end - start) * percent;
  }
}
