import 'package:invesly/common/extensions/color_extension.dart';
import 'package:invesly/common_libs.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key, this.height = 128.0, this.color, this.label, this.onPressed});

  final double height;
  final Widget? label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = this.color ?? theme.primaryColor;
    final lightColor = color.withLightness(0.9).toHex();
    final darkColor = color.withLightness(0.25).toHex();

    final svgString =
        '<svg viewBox="0 0 87 102" fill="none" xmlns="http://www.w3.org/2000/svg">'
        '  <path d="M1.48748 23.8917C1.21825 21.699 2.77751 19.7033 4.97018 19.434L33.2577 15.9608L70.5121 52.6944L75.0213 89.4186C75.2905 91.6113 73.7313 93.607 71.5386 93.8763L14.9635 100.823C12.7708 101.092 10.775 99.5328 10.5058 97.3401L1.48748 23.8917Z" fill="white"/>'
        '  <path d="M17.2529 17.9259L33.2577 15.9608L70.5121 52.6944L75.0213 89.4186C75.2905 91.6113 73.7313 93.607 71.5386 93.8763L14.9635 100.823C12.7708 101.092 10.775 99.5328 10.5058 97.3401L1.48748 23.8917C1.21825 21.699 2.77751 19.7033 4.97018 19.434L9.06444 18.9313" stroke="$darkColor" stroke-width="2" stroke-linecap="round"/>'
        '  <path d="M4.6431 24.57C4.50874 23.4758 5.2852 22.4792 6.37907 22.3419L33 19L67.5913 53.1168L71.9786 88.8484C72.1132 89.9448 71.3336 90.9426 70.2372 91.0772L15.6472 97.7801C14.5508 97.9147 13.553 97.135 13.4183 96.0387L4.6431 24.57Z" fill="$lightColor"/>'
        '  <path d="M21 5C21 2.79086 22.7909 1 25 1H68.4182C69.4344 1 70.4126 1.3868 71.154 2.08185L84.7358 14.8148C85.5424 15.571 86 16.6273 86 17.7329V79C86 81.2091 84.2091 83 82 83H25C22.7909 83 21 81.2091 21 79V5Z" fill="white" stroke="$darkColor" stroke-width="2"/>'
        '  <path d="M24 6C24 4.89543 24.8954 4 26 4H69V12.9024C69 15.1116 70.7909 16.9024 73 16.9024H81C82.1046 16.9024 83 17.7979 83 18.9024V78C83 79.1046 82.1046 80 81 80H26C24.8954 80 24 79.1046 24 78V6Z" fill="$lightColor"/>'
        '  <path d="M69 1V13C69 15.2091 70.7909 17 73 17H81" stroke="$darkColor" stroke-width="2" stroke-linecap="round"/>'
        '  <path d="M31 17H57" stroke="$darkColor" stroke-width="2" stroke-linecap="round"/>'
        '  <path d="M31 30H74" stroke="$darkColor" stroke-width="2" stroke-linecap="round"/>'
        '  <path d="M31 43H70" stroke="$darkColor" stroke-width="2" stroke-linecap="round"/>'
        '  <path d="M31 56H68" stroke="$darkColor" stroke-width="2" stroke-linecap="round"/>'
        '  <path d="M31 69H57" stroke="$darkColor" stroke-width="2" stroke-linecap="round"/>'
        '</svg>';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: height,
            child: SvgPicture.string(svgString, height: height * 0.75),
          ),
          // CustomPaint(
          //   size: Size(height * 0.8529, height),
          //   painter: EmptyWidgetPainter(color: color ?? theme.colorScheme.primary),
          // ),
          if (label != null)
            DefaultTextStyle(style: theme.textTheme.labelMedium!, textAlign: TextAlign.center, child: label!),
          if (onPressed != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add user'),
              ),
            ),
        ],
      ),
    );
  }
}
