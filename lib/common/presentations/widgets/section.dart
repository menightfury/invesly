import 'package:invesly/common/extensions/color_extension.dart';
import 'package:invesly/common_libs.dart';

class Section extends StatelessWidget {
  const Section({super.key, this.title, this.subTitle, this.icon, required this.tiles});

  final Widget? title;
  final Widget? subTitle;
  final Widget? icon;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    // TextStyle titleStyle = titleTextStyle ?? tileTheme.titleTextStyle ?? defaults.titleTextStyle!;
    // final Color? titleColor = effectiveColor;
    // titleStyle = titleStyle.copyWith(color: titleColor, fontSize: _isDenseLayout(theme, tileTheme) ? 13.0 : null);
    final titleText = DefaultTextStyle(
      style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
      child: title ?? const SizedBox.shrink(),
    );

    final subtitleText = DefaultTextStyle(
      style: context.textTheme.labelMedium!.copyWith(color: context.colors.secondary),
      child: subTitle ?? const SizedBox.shrink(),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2.0,
        children: <Widget>[
          if (title != null) ...[
            ListTile(
              title: titleText,
              leading: icon,
              subtitle: subtitleText,
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

enum _SectionTileVariant { normal, navigation, toggle }

class SectionTile extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? icon;
  final Widget? trailingIcon;
  final VoidCallback? _onTap; // for other than switch tile
  final ValueChanged<bool>? _onChanged; // for switch tile only
  final bool enabled;
  final bool _value; // for switch tile only
  final _SectionTileVariant _variant;

  const SectionTile({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.trailingIcon,
    VoidCallback? onTap,
    this.enabled = true,
  }) : _onTap = onTap,
       _variant = _SectionTileVariant.normal,
       _onChanged = null,
       _value = false;

  const SectionTile.navigation({
    super.key,
    required this.title,
    this.description,
    this.icon,
    Widget? trailingIcon,
    this.enabled = true,
    VoidCallback? onTap,
  }) : _onTap = onTap,
       _variant = _SectionTileVariant.navigation,
       _value = false,
       _onChanged = null,
       trailingIcon = trailingIcon ?? const Icon(Icons.keyboard_double_arrow_right_outlined);

  const SectionTile.switchTile({
    super.key,
    required this.title,
    this.description,
    this.icon,
    required bool value,
    this.enabled = true,
    void Function(bool)? onChanged,
  }) : _onChanged = onChanged,
       _value = value,
       _variant = _SectionTileVariant.toggle,
       trailingIcon = null,
       _onTap = null;

  @override
  Widget build(BuildContext context) {
    final titleStyle = context.textTheme.bodyMedium?.copyWith(color: enabled ? null : context.theme.disabledColor);
    final subtitleStyle = context.textTheme.labelMedium?.copyWith(
      color: enabled ? context.colors.secondary : context.theme.disabledColor,
    );
    if (_variant == _SectionTileVariant.toggle) {
      return SwitchListTile(
        key: key,
        title: Text(title, style: titleStyle),
        subtitle: description != null ? Text(description!, style: subtitleStyle) : null,
        secondary: icon,
        value: _value,
        onChanged: _onChanged,
      );
    }

    return ListTile(
      title: Text(title, style: titleStyle),
      subtitle: description != null ? Text(description!, style: subtitleStyle) : null,
      leading: icon,
      trailing: trailingIcon,
      onTap: _onTap,
      enabled: enabled,
    );
  }
}
