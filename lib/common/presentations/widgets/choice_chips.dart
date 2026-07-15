import 'package:flutter/foundation.dart';
import 'package:invesly/common/extensions/color_extension.dart';
// import 'dart:math' as math;

import 'package:invesly/common_libs.dart';

class InveslyChoiceChips<T> extends StatelessWidget {
  /// Single-select choice chips
  InveslyChoiceChips({
    super.key,
    required this.options,
    T? selected,
    ValueChanged<T?>? onChanged,
    this.clearable = false,
    this.color,
    this.chipSpacing = 2.0,
    // this.wrapped = true,
    this.showCheckmark = true,
    this.extended = false,
    // this.onDeleted,
    // this.deleteIcon,
    this.padding = const EdgeInsetsGeometry.all(8.0),
    required this.labelBuilder,
    this.iconBuilder,
  }) : multiselect = false,
       _selected = selected == null ? const {} : {selected},
       onChanged = onChanged != null ? ((Set<T> values) => onChanged.call(values.firstOrNull)) : null,
       assert(options.isNotEmpty),
       assert(selected != null || clearable);

  /// Multi-select choice chips
  const InveslyChoiceChips.multi({
    super.key,
    required this.options,
    Set<T>? selected,
    this.onChanged,
    this.clearable = false,
    this.color,
    this.chipSpacing = 2.0,
    // this.wrapped = true,
    this.showCheckmark = true,
    this.extended = false,
    // this.onDeleted,
    // this.deleteIcon,
    this.padding = const EdgeInsetsGeometry.all(8.0),
    required this.labelBuilder,
    this.iconBuilder,
  }) : multiselect = true,
       _selected = selected ?? const {},
       assert(options.length > 0),
       assert((selected != null && selected.length > 0) || clearable);

  final List<T> options;
  final ValueChanged<Set<T>>? onChanged;
  final Set<T> _selected;

  /// Empty selection is allowed or not, default is false i.e. not allowed
  final bool clearable;
  final WidgetStateColor? color;
  final double chipSpacing;
  final bool multiselect;
  // final bool wrapped;
  final bool showCheckmark;
  // final ValueChanged<T>? onDeleted;
  // final Widget? deleteIcon;
  final EdgeInsetsGeometry? padding;
  final bool extended;
  final Widget Function(BuildContext context, T value) labelBuilder;
  final Widget Function(BuildContext context, T value)? iconBuilder;

  bool get _enabled => onChanged != null;

  void _handleChanged(bool isSelected, T optionValue) {
    // Copied from segmented value
    if (!_enabled) {
      return;
    }
    final bool onlySelectedSegment = _selected.length == 1 && _selected.contains(optionValue);
    final bool validChange = clearable || !onlySelectedSegment;

    if (validChange) {
      final bool toggle = multiselect || (clearable && onlySelectedSegment);
      final Set<T> pressedOption = <T>{optionValue};
      late final Set<T> updatedOption;
      if (toggle) {
        updatedOption = _selected.contains(optionValue)
            ? _selected.difference(pressedOption)
            : _selected.union(pressedOption);
      } else {
        updatedOption = pressedOption;
      }
      if (!setEquals(updatedOption, _selected)) {
        onChanged?.call(updatedOption);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final childCount = options.length;

    final chips = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: chipSpacing,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(childCount, (index) {
        final value = options[index];
        final isSelected = _selected.contains(value);
        final isFirst = index == 0;
        final isLast = index == childCount - 1;

        // final textTheme = context.textTheme;
        BorderRadius chipRadius = iTileBorderRadius;

        if (isFirst) {
          chipRadius = chipRadius.copyWith(
            topLeft: iCardBorderRadius.topLeft,
            bottomLeft: iCardBorderRadius.bottomLeft,
          );
        }

        if (isLast) {
          chipRadius = chipRadius.copyWith(
            topRight: iCardBorderRadius.topRight,
            bottomRight: iCardBorderRadius.bottomRight,
          );
        }

        final chip = FilterChip(
          selected: isSelected,
          onSelected: _enabled ? (selected) => _handleChanged(selected, value) : null,
          label: Center(child: labelBuilder(context, value)),
          avatar: isSelected && showCheckmark ? null : iconBuilder?.call(context, value),
          color: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return colors.primary;
            return colors.primaryContainer;
          }),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          // onDeleted: onDeleted != null ? () => onDeleted!(option.value) : null,
          // deleteIcon: deleteIcon,
          showCheckmark: showCheckmark,
          checkmarkColor: colors.onPrimary,
          clipBehavior: Clip.antiAlias,
          labelStyle: TextStyle(
            fontWeight: FontWeight.normal,
            color: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return colors.onPrimary;
              return colors.primary;
            }),
            overflow: TextOverflow.ellipsis,
          ),
          padding: padding,
          avatarBoxConstraints: BoxConstraints.tightFor(width: 20.0, height: 20.0),
          side: WidgetStateBorderSide.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return BorderSide(color: colors.primary);
            return BorderSide(color: colors.primaryContainer.darken(20));
          }),
          shape: RoundedRectangleBorder(borderRadius: chipRadius),
        );

        if (extended) {
          return Expanded(child: chip);
        }

        return chip;
      }).toList(),
    );

    if (extended) {
      return chips;
    }

    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: chips);
  }
}
