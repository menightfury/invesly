import 'package:invesly/common_libs.dart';

class SettingsTile2 extends StatelessWidget {
  const SettingsTile2({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTap,
    this.mainAxis = Axis.vertical,
    this.isPrimary = false,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Function() onTap;
  final Axis mainAxis;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tappable(
      bgColor: isPrimary ? colorScheme.primary.withAlpha(50) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          width: 2,
          color: isPrimary ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
        ),
      ),
      onTap: () => onTap(),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: mainAxis == Axis.horizontal ? 12 : 12,
          horizontal: mainAxis == Axis.horizontal ? 16 : 16,
        ),
        child: Flex(
          direction: mainAxis,
          //mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isPrimary ? Theme.of(context).colorScheme.primary : null,
              size: mainAxis == Axis.horizontal ? 24 : 28,
              // color: Theme.of(context).colorScheme.primary,
            ),
            if (mainAxis == Axis.horizontal) const SizedBox(width: 12),
            if (mainAxis == Axis.vertical) const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final toReturn = Column(
                  crossAxisAlignment: mainAxis == Axis.vertical ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      textAlign: mainAxis == Axis.vertical ? TextAlign.center : TextAlign.start,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: mainAxis == Axis.vertical ? TextAlign.center : TextAlign.start,
                      ),
                  ],
                );

                return mainAxis == Axis.vertical ? toReturn : Expanded(child: toReturn);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? icon;
  final Widget? trailingIcon;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.trailingIcon,
    Widget? value,
    this.onTap,
    bool enabled = true,
  });

  factory SettingsTile.navigation({
    Key? key,
    required String title,
    String? description,
    Widget? icon,
    Widget? trailingIcon,
    bool enabled = true,
    required VoidCallback onTap,
  }) {
    return _SettingsNavigationTile(
      key: key,
      title: title,
      description: description,
      icon: icon,
      trailingIcon: trailingIcon,
      onTap: onTap,
    );
  }

  factory SettingsTile.switchTile({
    Key? key,
    required String title,
    String? description,
    Widget? icon,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return _SettingsSwitchTile(
      key: key,
      title: title,
      description: description,
      icon: icon,
      value: value,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle:
          description != null
              ? Text(description!, style: context.textTheme.labelSmall?.copyWith(color: context.color.secondary))
              : null,
      leading: icon,
      trailing: trailingIcon,
      onTap: onTap,
      // enabled: enabled,
    );
  }
}

class _SettingsNavigationTile extends SettingsTile {
  const _SettingsNavigationTile({
    super.key,
    required super.title,
    super.description,
    super.icon,
    super.trailingIcon,
    required super.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: key,
      title: Text(title),
      subtitle:
          description != null
              ? Text(description!, style: context.textTheme.labelSmall?.copyWith(color: context.color.secondary))
              : null,
      leading: icon,
      trailing: trailingIcon ?? const Icon(Icons.keyboard_double_arrow_right_outlined),
      onTap: onTap,
    );
  }
}

class _SettingsSwitchTile extends SettingsTile {
  const _SettingsSwitchTile({
    super.key,
    required super.title,
    super.description,
    super.icon,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      key: key,
      title: Text(title),
      subtitle:
          description != null
              ? Text(
                description!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.color.secondary),
              )
              : null,
      secondary: icon,
      value: value,
      onChanged: onChanged,
    );
  }
}
