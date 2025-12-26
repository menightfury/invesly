import 'package:invesly/common_libs.dart';

// NOT WORKING
class SingleDigitFlipCounter extends StatelessWidget {
  final double value;
  final Duration duration;
  final Curve curve;
  final Size size;
  final Color color;
  final EdgeInsets padding;
  final bool visible; // user can choose to hide leading zeroes

  const SingleDigitFlipCounter({
    super.key,
    required this.value,
    required this.duration,
    required this.curve,
    required this.size,
    required this.color,
    required this.padding,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: curve,
      builder: (_, value, _) {
        $logger.d(value);
        final whole = value ~/ 1;
        final decimal = (value - whole) as double;
        final w = size.width + padding.horizontal;
        final h = size.height + padding.vertical;

        return SizedBox(
          width: visible ? w : 0,
          height: h,
          child: Stack(
            children: <Widget>[
              _buildSingleDigit(digit: whole % 10, offset: h * decimal, opacity: 1 - decimal),
              _buildSingleDigit(digit: (whole + 1) % 10, offset: h * decimal - h, opacity: decimal),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSingleDigit({required int digit, required double offset, required double opacity}) {
    // Try to avoid using the `Opacity` widget when possible, for performance.
    final Widget child;
    if (color.opacity == 1) {
      // If the text style does not involve transparency, we can modify
      // the text color directly.
      child = Text(
        '$digit',
        textAlign: TextAlign.center,
        style: TextStyle(color: color.withOpacity(opacity.clamp(0, 1))),
      );
    } else {
      // Otherwise, we have to use the `Opacity` widget (less performant).
      child = Opacity(
        opacity: opacity.clamp(0, 1),
        child: Text('$digit', textAlign: TextAlign.center),
      );
    }
    return Positioned(left: 0, right: 0, bottom: offset + padding.bottom, child: child);
  }
}
