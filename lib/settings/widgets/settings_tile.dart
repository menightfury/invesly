import 'package:flutter/material.dart';
import 'package:invesly/common/presentations/components/tappable.dart';

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
  final Widget title;
  final Widget? description;
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
    required Widget title,
    Widget? description,
    Widget? icon,
    Widget? trailingIcon,
    WidgetBuilder? routeBuilder,
    String? routeLocation,
    bool enabled = true,
  }) {
    assert(routeBuilder != null || routeLocation != null);
    assert(routeBuilder == null || routeLocation == null);
    return _SettingsNavigationTile(
      key: key,
      title: title,
      description: description,
      icon: icon,
      trailingIcon: trailingIcon,
      routeBuilder: routeBuilder,
      routeLocation: routeLocation,
    );
  }

  factory SettingsTile.switchTile({
    Key? key,
    required Widget title,
    Widget? description,
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
      title: title,
      subtitle: description,
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
    this.routeBuilder,
    this.routeLocation,
  });

  final WidgetBuilder? routeBuilder;
  final String? routeLocation;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: key,
      title: title,
      subtitle: description,
      leading: icon,
      trailing: trailingIcon ?? const Icon(Icons.chevron_right_rounded),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: routeBuilder!)),
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
      title: title,
      subtitle: description,
      secondary: icon,
      value: value,
      onChanged: onChanged,
    );
  }
}
