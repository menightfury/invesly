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
  }) : multiselect = false,
       _selected = selected == null ? const {} : {selected},
       onChanged = onChanged != null ? ((Set<T> values) => onChanged.call(values.firstOrNull)) : null,
       assert(options.isNotEmpty),
       assert(selected != null || clearable);

  final List<InveslyChipData<T>> options;
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
    // if (wrapped) {
    //   return Wrap(
    //     spacing: chipSpacing,
    //     runSpacing: chipSpacing,
    //     crossAxisAlignment: WrapCrossAlignment.center,
    //     children: List.generate(options.length, (index) {
    //       return _buildItem(context, options[index]);
    //     }).toList(),
    //   );
    // }

    // final childCount = math.max(0, options.length * 2 - 1);

    final childCount = options.length;
    // return SingleChildScrollView(
    //   scrollDirection: Axis.horizontal,
    //   clipBehavior: Clip.none,
    //   physics: const BouncingScrollPhysics(),
    // padding: const EdgeInsets.symmetric(horizontal: 16.0),
    // child:
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: chipSpacing,
      children: List.generate(childCount, (index) {
        // final itemIndex = index ~/ 2;
        // if (index.isEven) {
        return Expanded(
          child: _buildItem(context, options[index], isFirst: index == 0, isLast: index == childCount - 1),
        );
        // }
        // return SizedBox(width: chipSpacing);
      }).toList(),
      // ),
    );
  }

  Widget _buildItem(BuildContext context, InveslyChipData<T> option, {bool? isFirst, bool? isLast}) {
    final isSelected = _selected.contains(option.value);

    // final textTheme = context.textTheme;
    BorderRadius tileRadius = iTileBorderRadius;

    if (isFirst ?? false) {
      tileRadius = tileRadius.copyWith(topLeft: iCardBorderRadius.topLeft, bottomLeft: iCardBorderRadius.bottomLeft);
    }

    if (isLast ?? false) {
      tileRadius = tileRadius.copyWith(
        topRight: iCardBorderRadius.topRight,
        bottomRight: iCardBorderRadius.bottomRight,
      );
    }

    return FilterChip(
      selected: isSelected,
      onSelected: _enabled ? (isSelected) => _handleChanged(isSelected, option.value) : null,
      label: SizedBox(width: double.infinity, child: option.label),
      // avatar: option.icon,
      // avatar: SizedBox(),
      color: color,
      // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      // onDeleted: onDeleted != null ? () => onDeleted!(option.value) : null,
      // deleteIcon: deleteIcon,
      showCheckmark: showCheckmark,
      clipBehavior: Clip.antiAlias,
      labelStyle: TextStyle(fontWeight: FontWeight.normal),
      labelPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: tileRadius),
      padding: iFormFieldContentPadding,
    );
  }
}
