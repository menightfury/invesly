import 'package:invesly/common/extensions/color_extension.dart';
import 'package:invesly/common_libs.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, this.title, this.subTitle, this.icon, required this.tiles});

  final String? title;
  final String? subTitle;
  final Widget? icon;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2.0,
        children: <Widget>[
          if (title != null) ...[
            ListTile(
              title: Text(title!, style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              leading: icon,
              subtitle: subTitle != null
                  ? Text(subTitle!, style: context.textTheme.labelMedium?.copyWith(color: context.colors.secondary))
                  : null,
              tileColor: context.colors.primaryContainer.darken(10),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.0), bottom: Radius.circular(4.0)),
              ),
            ),
            // InveslyDivider.dashed(dashGap: 2.0, dashWidth: 2.0, colors: [Colors.grey]),
          ],
          ...tiles.asMap().entries.map((entry) {
            final index = entry.key;
            final tile = entry.value;
            late final BorderRadius borderRadius;
            if (index == 0 && title == null) {
              borderRadius = BorderRadius.vertical(
                top: AppConstants.cardBorderRadius.topLeft,
                bottom: const Radius.circular(4.0),
              );
            } else if (index == tiles.length - 1) {
              borderRadius = BorderRadius.vertical(
                top: const Radius.circular(4.0),
                bottom: AppConstants.cardBorderRadius.bottomLeft,
              );
            } else {
              borderRadius = const BorderRadius.all(Radius.circular(4.0));
            }
            return Material(borderRadius: borderRadius, clipBehavior: Clip.antiAlias, child: tile);
          }),
        ],
      ),
    );
  }
}
