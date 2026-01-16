import 'package:invesly/common_libs.dart';
import 'dart:math' as math;

/// The checkbox itself does not maintain any state. Instead, when the state of
/// the checkbox changes, the widget calls the [onChanged] callback. Most
/// widgets that use a checkbox will listen for the [onChanged] callback and
/// rebuild the checkbox with a new [value] to update the visual appearance of
/// the checkbox.
class EMCheckbox extends StatefulWidget {
  const EMCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 24.0,
    this.thickness = 2.0,
    this.duration,
    this.color,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? color;
  final double size;
  final double thickness;
  final Duration? duration;

  @override
  State<EMCheckbox> createState() => _EMCheckboxState();
}

class _EMCheckboxState extends State<EMCheckbox> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late bool _previousValue;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 500),
      value: widget.value ? 1.0 : 0.0,
    );
    _previousValue = widget.value;
  }

  @override
  void didUpdateWidget(EMCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value) {
      _previousValue = oldWidget.value;
      if (widget.value) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void onChangedHandler() {
    widget.onChanged?.call(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: GestureDetector(
        onTap: onChangedHandler,
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return CustomPaint(
              foregroundPainter: _CheckPainter(
                percentage: _animController.value,
                strokeWidth: widget.thickness,
                color: widget.color ?? theme.colorScheme.primary,
              ),
              child: child,
            );
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: widget.thickness, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Color color;

  const _CheckPainter({required this.percentage, required this.strokeWidth, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    assert(percentage >= 0.0 && percentage <= 1.0);

    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final d = size.shortestSide - strokeWidth;
    final rect = Rect.fromCenter(center: center, width: d, height: d);

    final t = Curves.easeInOutCubic.transform(percentage);

    canvas.drawArc(rect, -math.pi / 4, 2 * t * math.pi, false, paint..color = color);

    final path = Path();
    final start = Offset(rect.width * 0.2, rect.width * 0.5);
    final mid = Offset(rect.width * 0.4, rect.width * 0.7);
    final end = Offset(rect.width * 0.75, rect.width * 0.35);

    path.moveTo(rect.left + start.dx, rect.top + start.dy);
    if (t < 0.5) {
      final double strokeT = t * 2.0;
      final Offset drawMid = Offset.lerp(start, mid, strokeT)!;
      path.lineTo(rect.left + drawMid.dx, rect.top + drawMid.dy);
    } else {
      final double strokeT = (t - 0.5) * 2.0;
      final Offset drawEnd = Offset.lerp(mid, end, strokeT)!;
      path.lineTo(rect.left + mid.dx, rect.top + mid.dy);
      path.lineTo(rect.left + drawEnd.dx, rect.top + drawEnd.dy);
    }

    if (t > 0.0) canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) {
    return percentage != oldDelegate.percentage;
  }
}
