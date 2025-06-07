import 'package:flutter/material.dart';

// Widget createListSeparator(BuildContext context, String title) {
//   return Padding(
//     padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
//     child: Text(
//       title.toUpperCase(),
//       style: TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.w700,
//           color: Theme.of(context).colorScheme.primary),
//     ),
//   );
// }

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, this.title, required this.tiles});

  final Widget? title;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    if (title == null) {
      return buildTileList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsetsDirectional.only(top: 24, bottom: 10, start: 24, end: 24), child: title),
        buildTileList(),
      ],
    );
  }

  Widget buildTileList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          // color: theme.disabledColor, // TODO: fix background color
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: tiles),
      ),
    );
  }
}
