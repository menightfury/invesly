// import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:invesly/common/extensions/color_extension.dart';
import 'package:invesly/common/extensions/num_extension.dart';
import 'package:invesly/common_libs.dart';

final _kBigRadius = iCardBorderRadius;
const _kSmallRadius = iTileBorderRadius;

enum _SectionVariant { scrollable, fixed }

class Section extends StatelessWidget {
  const Section({
    super.key,
    this.title,
    this.subTitle,
    this.icon,
    this.trailingIcon,
    required List<Widget> tiles,
    this.margin = const EdgeInsets.symmetric(horizontal: 16.0),
  }) : tileCount = tiles.length,
       _variant = _SectionVariant.fixed,
       _tiles = tiles,
       _tileBuilder = null;

  const Section.builder({
    super.key,
    this.title,
    this.subTitle,
    this.icon,
    this.trailingIcon,
    required this.tileCount,
    required IndexedWidgetBuilder tileBuilder,
    this.margin = const EdgeInsets.symmetric(horizontal: 16.0),
  }) : assert(tileCount >= 0),
       _variant = _SectionVariant.scrollable,
       _tiles = null,
       _tileBuilder = tileBuilder;

  final Widget? title;
  final Widget? subTitle;
  final Widget? icon;
  final Widget? trailingIcon;
  final int tileCount;
  final _SectionVariant _variant;
  final List<Widget>? _tiles;
  final IndexedWidgetBuilder? _tileBuilder;
  final EdgeInsetsGeometry? margin;

  bool get hasTiles => tileCount > 0;

  BorderRadius effectiveTileRadius(int index) {
    BorderRadius tileRadius = _kSmallRadius;
    // check if the tile is first tile
    if (index == 0 && title == null) {
      tileRadius = tileRadius.copyWith(topLeft: _kBigRadius.topLeft, topRight: _kBigRadius.topRight);
    }

    // check if the tile is last tile
    if (index == tileCount - 1) {
      tileRadius = tileRadius.copyWith(bottomLeft: _kBigRadius.bottomLeft, bottomRight: _kBigRadius.bottomRight);
    }

    return tileRadius;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleText = DefaultTextStyle(
      style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
      child: title ?? const SizedBox.shrink(),
    );

    final subtitleText = DefaultTextStyle(
      style: theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.secondary),
      child: subTitle ?? const SizedBox.shrink(),
    );

    late Widget child;
    if (_variant == _SectionVariant.scrollable) {
      child = Expanded(
        child: ListView.separated(
          itemBuilder: (context, index) {
            final tileRadius = effectiveTileRadius(index);
            return ClipRRect(
              // clipBehavior: Clip.hardEdge,
              borderRadius: tileRadius,
              child: _tileBuilder!(context, index),
            );
          },
          separatorBuilder: (_, _) => const SizedBox(height: 2.0),
          itemCount: tileCount,
        ),
      );
    } else if (_variant == _SectionVariant.fixed) {
      child = Column(
        spacing: 2.0,
        children: List.generate(tileCount, (index) {
          final tileRadius = effectiveTileRadius(index);
          return ClipRRect(
            // clipBehavior: Clip.hardEdge,
            borderRadius: tileRadius,
            child: _tiles![index],
          );
        }),
      );
    } else {
      child = SizedBox.shrink();
    }

    child = Material(
      type: MaterialType.transparency,
      borderRadius: _kSmallRadius,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2.0,
        children: <Widget>[
          if (title != null)
            SectionTile(
              title: titleText,
              subtitle: subtitleText,
              icon: icon,
              trailingIcon: trailingIcon,
              tileColor: theme.colorScheme.primaryContainer.darken(5),
              borderRadius: hasTiles
                  ? _kBigRadius.copyWith(bottomLeft: _kSmallRadius.bottomLeft, bottomRight: _kSmallRadius.bottomRight)
                  : _kBigRadius,
            ),
          child,
        ],
      ),
    );

    if (margin != null) {
      return Padding(padding: margin!, child: child);
    }

    return child;
  }
}

enum _SectionTileVariant { normal, navigation, toggle, check }

class SectionTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final double? contentSpacing;
  final Widget? icon;
  final Widget? trailingIcon;
  final Color? tileColor;
  final Color? selectedTileColor;
  final BorderRadius? borderRadius;
  final VoidCallback? _onTap; // for other than switch tile
  final ValueChanged<bool>? _onChanged; // for switch tile only
  final bool enabled;
  final bool selected;
  final bool _value; // for switch tile only
  final _SectionTileVariant _variant;

  const SectionTile({
    super.key,
    required this.title,
    this.subtitle,
    this.contentSpacing,
    this.icon,
    this.trailingIcon,
    this.tileColor,
    this.selectedTileColor,
    this.borderRadius = _kSmallRadius,
    VoidCallback? onTap,
    this.enabled = true,
    this.selected = false,
  }) : _onTap = onTap,
       _variant = _SectionTileVariant.normal,
       _onChanged = null,
       _value = false;

  const SectionTile.navigation({
    super.key,
    required this.title,
    this.subtitle,
    this.contentSpacing,
    this.icon,
    this.trailingIcon,
    this.tileColor,
    this.selectedTileColor,
    this.borderRadius = _kSmallRadius,
    this.enabled = true,
    this.selected = false,
    VoidCallback? onTap,
  }) : _onTap = onTap,
       _variant = _SectionTileVariant.navigation,
       _value = false,
       _onChanged = null;

  const SectionTile.switchTile({
    super.key,
    required this.title,
    this.subtitle,
    this.contentSpacing,
    this.icon,
    required bool value,
    this.tileColor,
    this.selectedTileColor,
    this.borderRadius = _kSmallRadius,
    this.enabled = true,
    this.selected = false,
    void Function(bool)? onChanged,
  }) : _onChanged = onChanged,
       _value = value,
       _variant = _SectionTileVariant.toggle,
       trailingIcon = null,
       _onTap = null;

  const SectionTile.checkTile({
    super.key,
    required this.title,
    this.subtitle,
    this.contentSpacing,
    this.icon,
    required bool value,
    this.tileColor,
    this.selectedTileColor,
    this.borderRadius = _kSmallRadius,
    this.enabled = true,
    this.selected = false,
    void Function(bool)? onChanged,
  }) : _onChanged = onChanged,
       _value = value,
       _variant = _SectionTileVariant.check,
       trailingIcon = null,
       _onTap = null;

  Color _tileColor(ThemeData theme, ListTileThemeData tileTheme) {
    final Color? color = selected
        ? selectedTileColor ?? tileTheme.selectedTileColor ?? theme.listTileTheme.selectedTileColor
        : tileColor ?? tileTheme.tileColor ?? theme.listTileTheme.tileColor;
    return color ?? theme.canvasColor.lighten(4);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tileTheme = ListTileTheme.of(context);

    final titleText = AnimatedDefaultTextStyle(
      duration: 850.ms,
      style: theme.textTheme.bodyMedium!.copyWith(color: enabled ? null : theme.disabledColor),
      overflow: TextOverflow.ellipsis,
      child: title,
    );

    Widget? subtitleText;
    if (subtitle != null) {
      subtitleText = AnimatedDefaultTextStyle(
        duration: 850.ms,
        style: theme.textTheme.bodySmall!.copyWith(color: enabled ? theme.colorScheme.secondary : theme.disabledColor),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        child: subtitle!,
      );
    }

    final effectiveTrailingIcon = switch (_variant) {
      _SectionTileVariant.toggle => Switch(value: _value, onChanged: _onChanged),
      _SectionTileVariant.navigation => trailingIcon ?? const Icon(Icons.keyboard_double_arrow_right_outlined),
      _SectionTileVariant.check => Checkbox(
        value: _value,
        onChanged: _onChanged != null ? (value) => _onChanged.call(value ?? false) : null,
      ),
      _ => trailingIcon,
    };

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled
          ? _onChanged != null
                ? () => _onChanged.call(!_value)
                : _onTap
          : null,
      child: SafeArea(
        child: AnimatedPhysicalModel(
          curve: Curves.fastOutSlowIn,
          duration: 600.ms,
          clipBehavior: Clip.antiAlias,
          elevation: 0.0,
          color: _tileColor(theme, tileTheme),
          shadowColor: theme.colorScheme.shadow,
          borderRadius: borderRadius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                spacing: 16.0,
                children: <Widget>[
                  ?icon,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: contentSpacing ?? 0.0,
                      children: <Widget>[titleText, ?subtitleText],
                    ),
                  ),
                  ?effectiveTrailingIcon,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
