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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        borderRadius: BorderRadius.circular(16.0),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              ListTile(
                title: Text(title!),
                leading: icon,
                subtitle: subTitle != null ? Text(subTitle!, style: TextStyle(color: context.colors.secondary)) : null,
              ),
              InveslyDivider.dashed(dashGap: 2.0, dashWidth: 2.0, colors: [Colors.grey]),
            ],
            ...tiles,
          ],
        ),
      ),
    );
  }
}
