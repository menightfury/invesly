import 'package:invesly/common_libs.dart';

class InveslyColorPickerWidget extends StatelessWidget {
  const InveslyColorPickerWidget({
    super.key,
    this.selectedColor,
    this.onPickup,
    this.header,
    this.colors = defaultColors,
  });

  final Color? selectedColor;
  final ValueChanged<Color>? onPickup;
  final Widget? header;
  final List<Color> colors;

  static const defaultColors = <Color>[
    Color(0xFF34A853),
    Color(0xFF4285F4),
    Color(0xFF00E5FF),
    Color(0xFF3F51B5),
    Color(0xFFF05131),
    Color(0xFFE1BEE7),
    Color(0xFF008B85),
  ];

  static Future<Color?> showModal(BuildContext context, {Color? selectedColor, List<Color>? colors}) async {
    return await showModalBottomSheet<Color?>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          width: double.infinity,
          child: Padding(
            padding: iPaddingFromScreenEdge.copyWith(bottom: 16.0),
            child: InveslyColorPickerWidget(
              header: const Text('Pick a color'),
              selectedColor: selectedColor,
              colors: colors ?? defaultColors,
              onPickup: (color) => Navigator.maybePop(context, color),
            ),
          ),
        );
      },
    );
  }

  static const _circleSize = 40.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget content = Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: colors.map((color) => _buildSelectableColorCircle(context, color)).toList(),
    );

    if (header != null) {
      final headerContent = DefaultTextStyle(
        style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
        child: header!,
      );
      content = Column(spacing: 16.0, mainAxisSize: MainAxisSize.min, children: <Widget>[headerContent, content]);
    }

    return content;
  }

  Widget _buildSelectableColorCircle(BuildContext context, Color color) {
    final isSelected = selectedColor == color;

    return GestureDetector(
      onTap: () => onPickup?.call(color),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // ~ Outer
          AnimatedScale(
            duration: 300.ms,
            scale: isSelected ? 1.25 : 0.9,
            curve: Curves.bounceIn,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(width: 2.0, color: color, strokeAlign: BorderSide.strokeAlignInside),
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(dimension: _circleSize),
            ),
          ),

          // ~ Inner
          DecoratedBox(
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            child: SizedBox.square(
              dimension: _circleSize,
              child: AnimatedScale(
                duration: 200.ms,
                scale: isSelected ? 1.0 : 0.0,
                child: const Icon(Icons.check_rounded, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
