import 'package:flutter/foundation.dart';
// import 'dart:math' as math;

import 'package:invesly/common_libs.dart';

class InveslyChipData<T> {
  const InveslyChipData({required this.value, required this.label, this.icon});

  final T value;
  final Widget label;
  final Widget? icon;
}

class InveslyChoiceChips<T> extends StatelessWidget {
  /// Multi-select choice chips
  const InveslyChoiceChips({
    super.key,
    required this.options,
    Set<T>? selected,
    this.onChanged,
    this.clearable = false,
    this.color,
    this.chipSpacing = 2.0,
    this.wrapped = true,
    this.showCheckmark = true,
    // this.onDeleted,
    // this.deleteIcon,
    required this.labelBuilder,
    this.iconBuilder,
  }) : multiselect = true,
       _selected = selected ?? const {},
       assert(options.length > 0),
       assert((selected != null && selected.length > 0) || clearable);

  /// Single-select choice chips
  InveslyChoiceChips.single({
    super.key,
    required this.options,
    T? selected,
    ValueChanged<T?>? onChanged,
    this.clearable = false,
    this.color,
    this.chipSpacing = 2.0,
    this.wrapped = true,
    this.showCheckmark = true,
    // this.onDeleted,
    // this.deleteIcon,
    required this.labelBuilder,
    this.iconBuilder,
  }) : multiselect = false,
       _selected = selected == null ? const {} : {selected},
       onChanged = onChanged != null ? ((Set<T> values) => onChanged.call(values.firstOrNull)) : null,
       assert(options.isNotEmpty),
       assert(selected != null || clearable);

  final List<T> options;
  final ValueChanged<Set<T>>? onChanged;
  final Set<T> _selected;

  /// Empty selection is allowed or not, default is false i.e. not allowed
  final bool clearable;
  final WidgetStateColor? color;
  final double chipSpacing;
  final bool multiselect;
  final bool wrapped;
  final bool showCheckmark;
  // final ValueChanged<T>? onDeleted;
  // final Widget? deleteIcon;
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: chipSpacing,
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

        return FilterChip(
          selected: isSelected,
          onSelected: _enabled ? (selected) => _handleChanged(selected, value) : null,
          label: Center(child: labelBuilder(context, value)),
          avatar: isSelected ? null : iconBuilder?.call(context, value),
          color: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return colors.primary;
            return colors.primaryContainer;
          }),
          // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          // onDeleted: onDeleted != null ? () => onDeleted!(option.value) : null,
          // deleteIcon: deleteIcon,
          showCheckmark: showCheckmark,
          checkmarkColor: colors.onPrimary,
          clipBehavior: Clip.antiAlias,
          labelStyle: TextStyle(
            fontWeight: FontWeight.normal,
            color: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return colors.onPrimary;
              return colors.onPrimaryContainer;
            }),
          ),
          // labelPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: chipRadius),

          // padding: EdgeInsets.zero,
        );
      }).toList(),
      // ),
    );
  }
}
