import 'package:flutter/foundation.dart';
import 'dart:math' as math;

import 'package:invesly/common_libs.dart';

class InveslyChipData<T> {
  const InveslyChipData({required this.value, required this.label, this.icon});

  final T value;
  final Widget label;
  final Widget? icon;
}

class InveslyChoiceChips<T> extends StatelessWidget {
  /// Multi-select choice chips
  InveslyChoiceChips({
    super.key,
    required this.options,
    // this.optionsBuilder,
    required this.selected,
    this.onChanged,
    this.clearable = false,
    this.color,
    this.chipSpacing = 8.0,
    this.wrapped = true,
    this.showCheckmark = true,
    this.onDeleted,
    this.deleteIcon,
  }) : multiselect = true,
       assert(options.isNotEmpty),
       assert(selected.isNotEmpty || clearable);

  /// Single-select choice chips
  InveslyChoiceChips.single({
    super.key,
    required this.options,
    // this.optionsBuilder,
    T? selected,
    ValueChanged<T?>? onChanged,
    this.clearable = false,
    this.color,
    this.chipSpacing = 8.0,
    this.wrapped = true,
    this.showCheckmark = true,
    this.onDeleted,
    this.deleteIcon,
  }) : multiselect = false,
       selected = {selected}.whereType<T>().toSet(),
       onChanged = onChanged != null ? ((Set<T> values) => onChanged.call(values.firstOrNull)) : null,
       assert(options.isNotEmpty),
       assert(selected != null || clearable);

  final List<InveslyChipData<T>> options;
  // final WidgetBuilder? optionsBuilder;
  final ValueChanged<Set<T>>? onChanged;
  final Set<T> selected;

  /// empty selection is allowed or not, default is false i.e. not allowed
  final bool clearable;
  final WidgetStateColor? color;
  final double chipSpacing;
  final bool multiselect;
  final bool wrapped;
  final bool showCheckmark;
  final ValueChanged<T>? onDeleted;
  final Widget? deleteIcon;

  bool get _enabled => onChanged != null;

  void _handleChanged(bool isSelected, T optionValue) {
    // Copied from segmented value
    if (!_enabled) {
      return;
    }
    final bool onlySelectedSegment = selected.length == 1 && selected.contains(optionValue);
    final bool validChange = clearable || !onlySelectedSegment;

    if (validChange) {
      final bool toggle = multiselect || (clearable && onlySelectedSegment);
      final Set<T> pressedOption = <T>{optionValue};
      late final Set<T> updatedOption;
      if (toggle) {
        updatedOption = selected.contains(optionValue)
            ? selected.difference(pressedOption)
            : selected.union(pressedOption);
      } else {
        updatedOption = pressedOption;
      }
      if (!setEquals(updatedOption, selected)) {
        onChanged?.call(updatedOption);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (wrapped) {
      return Wrap(
        spacing: chipSpacing,
        runSpacing: chipSpacing,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: List.generate(options.length, (index) {
          return _buildItem(context, options[index]);
        }).toList(),
      );
    }

    final childCount = math.max(0, options.length * 2 - 1);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(childCount, (index) {
          final itemIndex = index ~/ 2;
          if (index.isEven) {
            return _buildItem(context, options[itemIndex]);
          }
          return SizedBox(width: chipSpacing);
        }).toList(),
      ),
    );
  }

  Widget _buildItem(BuildContext context, InveslyChipData<T> option) {
    final isSelected = selected.contains(option.value);

    return FilterChip(
      selected: isSelected,
      onSelected: _enabled ? (isSelected) => _handleChanged(isSelected, option.value) : null,
      label: option.label,
      avatar: isSelected ? null : option.icon,
      color: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onDeleted: onDeleted != null ? () => onDeleted!(option.value) : null,
      deleteIcon: deleteIcon,
      showCheckmark: showCheckmark,
      clipBehavior: Clip.antiAlias,
    );
  }
}
