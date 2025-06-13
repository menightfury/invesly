import 'package:flutter/material.dart';
import 'package:invesly/common/presentations/components/tappable.dart';

class InveslyColorPickerWidget extends StatelessWidget {
  const InveslyColorPickerWidget({super.key, this.colors, this.selectedColor, this.onPickup, this.scrollController});

  final List<int>? colors;
  final int? selectedColor;
  final ValueChanged<int>? onPickup;
  final ScrollController? scrollController;

  final _defaultColors = const <int>[
    0xFFB71C1C,
    0xFFD50000,
    0xFFE53935,
    0xFFEF5350,
    0xFF880E4F,
    0xFFC51162,
    0xFFD81B60,
    0xFFEC407A,
    0xFF4A148C,
    0xFFAA00FF,
    0xFF8E24AA,
    0xFFAB47BC,
    0xFF1A237E,
    0xFF2962FF,
    0xFF2979FF,
    0xFF42A5F5,
    0xFF006064,
    0xFF00897B,
    0xFF00BFA5,
    0xFF4DB6AC,
    0xFF1B5E20,
    0xFF388E3C,
    0xFF8BC34A,
    0xFFD4E157,
    0xFFBF360C,
    0xFFF4511E,
    0xFFFB8C00,
    0xFFFFA726,
    0xFFE65100,
    0xFFFFA000,
    0xFFFFAB00,
    0xFFFFCA28,
    0xFF546E7A,
    0xFF90A4AE,
    0xFF795548,
    0xFF757575,
  ];
  final _circleSize = 48.0;

  static Future<int?> showModal(BuildContext context) async {
    return await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.65,
          minChildSize: 0.45,
          initialChildSize: 0.65,
          builder: (context, scrollController) {
            return InveslyColorPickerWidget(onPickup: (color) => Navigator.maybePop(context, color));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColors = (colors?.isNotEmpty ?? false) ? colors : _defaultColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.0,
        children: <Widget>[
          Text('Pick a color'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              controller: scrollController,
              child: Align(
                alignment: Alignment.center,
                heightFactor: 1.0,
                child: Wrap(
                  runAlignment: WrapAlignment.center,
                  spacing: 6.0,
                  runSpacing: 12.0,
                  children: effectiveColors!.map((color) => _buildSelectableColorCircle(context, color)).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableColorCircle(BuildContext context, int color) {
    return Tappable(
      size: Size(_circleSize, _circleSize),
      bgColor: Color(color),
      shape: CircleBorder(),
      onTap: () => onPickup?.call(color),
      child: selectedColor == color ? Center(child: Icon(Icons.check, color: Colors.white)) : null,
    );
  }
}
