// import 'dart:math' as math;

import 'package:invesly/common/extensions/color_extension.dart';
import 'package:invesly/common_libs.dart';

// const _kBorderRadius = AppConstants.tileBorderRadius;
const _kBigRadius = Radius.circular(16.0);
const _kSmallRadius = Radius.circular(4.0);

enum _SectionVariant { scrollable, fixed }

class Section extends StatelessWidget {
  Section({super.key, this.title, this.subTitle, this.icon, this.trailingIcon, required List<Widget> tiles})
    : assert(tiles.isNotEmpty),
      tileCount = tiles.length,
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
  }) : assert(tileCount > 0),
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

  bool get hasTiles => tileCount > 0;

  BorderRadius effectiveTileRadius(int index) {
    BorderRadius tileRadius = BorderRadius.all(_kSmallRadius);
    // check if first tile
    if (index == 0 && title == null) {
      tileRadius = tileRadius.copyWith(topLeft: _kBigRadius, topRight: _kBigRadius);
    }

    // check if last tile
    if (index == tileCount - 1) {
      tileRadius = tileRadius.copyWith(bottomLeft: _kBigRadius, bottomRight: _kBigRadius);
    }

    return tileRadius;
  }

  @override
  Widget build(BuildContext context) {
    final titleText = DefaultTextStyle(
      style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
      child: title ?? const SizedBox.shrink(),
    );

    final subtitleText = DefaultTextStyle(
      style: context.textTheme.bodySmall!.copyWith(color: context.colors.secondary),
      child: subTitle ?? const SizedBox.shrink(),
    );

    BorderRadius headerRadius = BorderRadius.all(_kBigRadius);
    if (hasTiles) {
      headerRadius = headerRadius.copyWith(bottomLeft: _kSmallRadius, bottomRight: _kSmallRadius);
    }

    late final Widget tileContainer;
    if (_variant == _SectionVariant.scrollable) {
      tileContainer = Expanded(
        child: ListView.separated(
          itemBuilder: (context, index) {
            final tileRadius = effectiveTileRadius(index);
            $logger.d('tileRadius: $tileRadius');
            return ClipPath(
              // clipBehavior: Clip.hardEdge,
              clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(borderRadius: tileRadius)),
              child: _tileBuilder!(context, index),
            );
          },
          separatorBuilder: (_, _) => const SizedBox(height: 2.0),
          itemCount: tileCount,
        ),
      );
    } else if (_variant == _SectionVariant.fixed) {
      tileContainer = Column(
        spacing: 2.0,
        children: List.generate(tileCount, (index) {
          final tileRadius = effectiveTileRadius(index);
          $logger.d('tileRadius: $tileRadius');
          return ClipPath(
            clipBehavior: Clip.hardEdge,
            clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(borderRadius: tileRadius)),
            child: _tiles![index],
          );
        }),
      );
    } else {
      tileContainer = SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Material(
        type: MaterialType.transparency,
        // borderRadius: AppConstants.cardBorderRadius,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2.0,
          children: <Widget>[
            if (title != null)
              ListTile(
                title: titleText,
                leading: icon,
                trailing: trailingIcon,
                subtitle: subtitleText,
                tileColor: context.colors.primaryContainer.darken(5),
                minVerticalPadding: 12.0,
                shape: RoundedRectangleBorder(borderRadius: headerRadius),
                // shape: _kBorderRadius,
              ),
            tileContainer,
          ],
        ),
      ),
    );
  }
}

enum _SectionTileVariant { normal, navigation, toggle, check }

class SectionTile extends StatelessWidget {
  final Widget title;
  final Widget? description;
  final Widget? icon;
  final Widget? trailingIcon;
  final Color? color;
  final Color? selectedColor;
  final VoidCallback? _onTap; // for other than switch tile
  final ValueChanged<bool>? _onChanged; // for switch tile only
  final bool enabled;
  final bool selected;
  final bool _value; // for switch tile only
  final _SectionTileVariant _variant;

  const SectionTile({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.trailingIcon,
    this.color,
    this.selectedColor,
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
    this.description,
    this.icon,
    Widget? trailingIcon,
    this.color,
    this.selectedColor,
    this.enabled = true,
    this.selected = false,
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
    this.color,
    this.selectedColor,
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
    this.description,
    this.icon,
    required bool value,
    this.color,
    this.selectedColor,
    this.enabled = true,
    this.selected = false,
    void Function(bool)? onChanged,
  }) : _onChanged = onChanged,
       _value = value,
       _variant = _SectionTileVariant.toggle,
       trailingIcon = null,
       _onTap = null;

  @override
  Widget build(BuildContext context) {
    final titleText = DefaultTextStyle(
      style: context.textTheme.bodyMedium!.copyWith(color: enabled ? null : context.theme.disabledColor),
      child: title,
    );

    Widget? subtitleText;

    if (description != null) {
      subtitleText = DefaultTextStyle(
        style: context.textTheme.bodySmall!.copyWith(
          color: enabled ? context.colors.secondary : context.theme.disabledColor,
        ),
        child: description!,
      );
    }

    final defaultTileColor = context.theme.canvasColor;
    final defaultSelectedTileColor = defaultTileColor.darken(8);

    if (_variant == _SectionTileVariant.check) {
      return CheckboxListTile(
        key: key,
        title: titleText,
        subtitle: subtitleText,
        secondary: icon,
        value: _value,
        tristate: false,
        onChanged: (value) => _onChanged?.call(value ?? false),
        tileColor: color ?? defaultTileColor,
        selectedTileColor: selectedColor ?? defaultSelectedTileColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(_kSmallRadius)),
        enabled: enabled,
        selected: selected,
      );
    }

    if (_variant == _SectionTileVariant.toggle) {
      return SwitchListTile(
        key: key,
        title: titleText,
        subtitle: subtitleText,
        secondary: icon,
        value: _value,
        onChanged: _onChanged,
        tileColor: color ?? defaultTileColor,
        selectedTileColor: selectedColor ?? defaultSelectedTileColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(_kSmallRadius)),
        selected: selected,
      );
    }

    return ListTile(
      title: titleText,
      subtitle: subtitleText,
      leading: icon,
      trailing: trailingIcon,
      onTap: _onTap,
      enabled: enabled,
      tileColor: color ?? defaultTileColor,
      selectedTileColor: selectedColor ?? defaultSelectedTileColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(_kSmallRadius)),
      selected: selected,
    );
  }
}
