// import 'dart:math' as math;

import 'package:invesly/common/extensions/color_extension.dart';
import 'package:invesly/common_libs.dart';

// const _kBorderRadius = AppConstants.tileBorderRadius;
const _kBigRadius = Radius.circular(16.0);
const _kSmallRadius = Radius.circular(4.0);

enum _SectionVariant { scrollable, fixed }

class Section extends StatelessWidget {
  Section({
    super.key,
    this.title,
    this.subTitle,
    this.icon,
    this.trailingIcon,
    required List<Widget> tiles,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
  }) : assert(tiles.isNotEmpty),
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
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
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
  final EdgeInsetsGeometry padding;

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

    late final Widget tileContainer;
    if (_variant == _SectionVariant.scrollable) {
      tileContainer = Expanded(
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
      tileContainer = Column(
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
      tileContainer = SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.all(_kSmallRadius),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2.0,
          children: <Widget>[
            if (title != null)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer.darken(5),
                  borderRadius: BorderRadius.vertical(top: _kBigRadius, bottom: _kSmallRadius),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      spacing: 16.0,
                      children: <Widget>[
                        ?icon,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[titleText, subtitleText],
                          ),
                        ),
                        ?trailingIcon,
                      ],
                    ),
                  ),
                ),
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
  final Widget? subtitle;
  final double? titleSpacing;
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
    this.subtitle,
    this.titleSpacing,
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
    this.subtitle,
    this.titleSpacing,
    this.icon,
    this.trailingIcon,
    this.color,
    this.selectedColor,
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
    this.titleSpacing,
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
    this.subtitle,
    this.titleSpacing,
    this.icon,
    required bool value,
    this.color,
    this.selectedColor,
    this.enabled = true,
    this.selected = false,
    void Function(bool)? onChanged,
  }) : _onChanged = onChanged,
       _value = value,
       _variant = _SectionTileVariant.check,
       trailingIcon = null,
       _onTap = null;

  @override
  Widget build(BuildContext context) {
    final titleText = DefaultTextStyle(
      style: context.textTheme.bodyMedium!.copyWith(color: enabled ? null : context.theme.disabledColor),
      overflow: TextOverflow.ellipsis,
      child: title,
    );

    Widget? subtitleText;
    if (subtitle != null) {
      subtitleText = DefaultTextStyle(
        style: context.textTheme.bodySmall!.copyWith(
          color: enabled ? context.colors.secondary : context.theme.disabledColor,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        child: subtitle!,
      );
    }

    final defaultTileColor = context.theme.canvasColor;

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
      onTap: _onChanged != null ? () => _onChanged.call(!_value) : _onTap,
      child: ColoredBox(
        color: color ?? defaultTileColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              spacing: 16.0,
              children: <Widget>[
                ?icon,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: titleSpacing ?? 0.0,
                    children: <Widget>[titleText, ?subtitleText],
                  ),
                ),
                ?effectiveTrailingIcon,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
