import 'package:invesly/common_libs.dart';

enum _SettingsTileVariant { normal, navigation, toggle }

class SettingsTile extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? icon;
  final Widget? trailingIcon;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onChanged; // for switch tile only
  final bool enabled;
  final bool value; // for switch tile only
  final _SettingsTileVariant _type;

  const SettingsTile({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.trailingIcon,
    this.onTap,
    this.enabled = true,
  }) : _type = _SettingsTileVariant.normal,
       onChanged = null,
       value = false;

  const SettingsTile.navigation({
    super.key,
    required this.title,
    this.description,
    this.icon,
    Widget? trailingIcon,
    this.enabled = true,
    required this.onTap,
  }) : _type = _SettingsTileVariant.navigation,
       value = false,
       onChanged = null,
       trailingIcon = trailingIcon ?? const Icon(Icons.keyboard_double_arrow_right_outlined);

  const SettingsTile.switchTile({
    super.key,
    required this.title,
    this.description,
    this.icon,
    required this.value,
    this.enabled = true,
    this.onChanged,
  }) : _type = _SettingsTileVariant.toggle,
       trailingIcon = null,
       onTap = null;

  @override
  Widget build(BuildContext context) {
    final titleStyle = context.textTheme.bodyMedium?.copyWith(color: enabled ? null : context.theme.disabledColor);
    final subtitleStyle = context.textTheme.labelMedium?.copyWith(
      color: enabled ? context.colors.secondary : context.theme.disabledColor,
    );
    if (_type == _SettingsTileVariant.toggle) {
      return SwitchListTile(
        key: key,
        title: Text(title, style: titleStyle),
        subtitle: description != null ? Text(description!, style: subtitleStyle) : null,
        secondary: icon,
        value: value,
        onChanged: onChanged,
      );
    }

    return ListTile(
      title: Text(title, style: titleStyle),
      subtitle: description != null ? Text(description!, style: subtitleStyle) : null,
      leading: icon,
      trailing: trailingIcon,
      onTap: onTap,
      enabled: enabled,
    );
  }
}
