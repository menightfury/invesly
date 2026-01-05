import 'package:invesly/common/extensions/color_extension.dart';
import 'package:invesly/common/utils/svg_path_parser.dart';
import 'package:invesly/common_libs.dart';
import 'package:path_parsing/path_parsing.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key, this.height = 256.0, this.label, this.onPressed});

  final double height;
  final String? label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // SizedBox(
          //   height: height,
          //   // child: SvgPicture.asset('assets/images/empty.svg', height: height * 0.75),
          //   child: Image.asset('assets/images/empty_1.png', height: height * 0.75),
          // ),
          CustomPaint(
            size: Size(height * 0.85, height),
            painter: EmptyWidgetPainter(color: Colors.red),
          ),
          if (label != null) Text(label!, style: Theme.of(context).textTheme.labelMedium),
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

// <svg width="87" height="102" viewBox="0 0 87 102" fill="none" xmlns="http://www.w3.org/2000/svg">
//   <g fill="#DBDBDB">
//     <path d="M 15.75 97.88 C 14.65 98.01 13.65 97.24 13.52 96.14 L 4.74 24.68 C 4.61 23.58 5.39 22.58 6.49 22.4465 L 15.5364 21.3352 L 21.0545 20.6576 L 21.5 82.5 L 71.4 83 L 72.0928 88.9596 C 72.2198 90.0518 71.4413 91.0417 70.3499 91.1757 L 15.7472 97.88 Z"/>
//     <path d="M 24 6 C 24 4.8954 24.8954 4 26 4 H 67 C 68.1046 4 69 4.8954 69 6 V 14.9024 C 69 16.007 69.8954 16.9024 71 16.9024 H 81 C 82.1046 16.9024 83 17.7979 83 18.9024 V 78 C 83 79.1046 82.1046 80 81 80 H 26 C 24.8954 80 24 79.1046 24 78 V 6 Z"/>
//   </g>
//   <g stroke="black" stroke-width="2" stroke-linecap="round">
//     <path d="M 10.4292 18.7637 L 4.9702 19.434 C 2.7775 19.7033 1.2183 21.699 1.4875 23.8917 L 10.5058 97.3401 C 10.775 99.5328 12.7708 101.092 14.9635 100.823 L 71.5386 93.8763 C 73.7313 93.607 75.2905 91.6113 75.0213 89.4186 L 74.2787 83.3703 M 13.655 18.3677 L 19.7343 17.6212"/>
//     <path d="M 21 5 C 21 2.7909 22.7909 1 25 1 H 68.4182 C 69.4344 1 70.4126 1.3868 71.154 2.0819 L 84.7358 14.8148 C 85.5424 15.571 86 16.6273 86 17.7329 V 79 C 86 81.2091 84.2091 83 82 83 H 25 C 22.7909 83 21 81.2091 21 79 V 5 Z"/>
//     <path d="M 69 1 V 13 C 69 15.2091 70.7909 17 73 17 H 81"/>
//   </g>
//   <g stroke="#7C7C7C" stroke-width="2" stroke-linecap="round">
//     <path d="M 31 17 H 57"/>
//     <path d="M 31 29 H 74"/>
//     <path d="M 31 42 H 74"/>
//     <path d="M 31 55 H 74"/>
//     <path d="M 31 68 H 57"/>
//   </g>
// </svg>

class EmptyWidgetPainter extends CustomPainter {
  final Color color;

  const EmptyWidgetPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // size: 256*0.85, 256
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withAlpha(100);

    final path1 =
        'M 15.75 97.88 C 14.65 98.01 13.65 97.24 13.52 96.14 L 4.74 24.68 C 4.61 23.58 5.39 22.58 6.49 22.4465'
        'L 15.5364 21.3352 L 21.0545 20.6576 L 21.5 82.5 L 71.4 83 L 72.0928 88.9596'
        'C 72.2198 90.0518 71.4413 91.0417 70.3499 91.1757 L 15.7472 97.88 Z';
    final path = getPathDataFromSvgPath(size: size, viewBox: Size(87, 102), svgPath: path1);
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
