import 'package:invesly/common_libs.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, this.title, this.subTitle, this.icon, required this.tiles});

  final String? title;
  final String? subTitle;
  final Widget? icon;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            ListTile(
              title: Text(title!, style: context.textTheme.bodyMedium),
              leading: icon,
              subtitle: subTitle != null
                  ? Text(subTitle!, style: context.textTheme.labelMedium?.copyWith(color: context.colors.secondary))
                  : null,
            ),
            InveslyDivider.dashed(dashGap: 2.0, dashWidth: 2.0, colors: [Colors.grey]),
          ],
          ...tiles,
        ],
      ),
    );
  }
}
