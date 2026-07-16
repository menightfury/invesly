import 'package:flutter/material.dart';
import 'package:invesly/common/presentations/animations/fade_in.dart';
import 'package:invesly/common/presentations/widgets/tappable.dart';
import 'package:invesly/constants.dart';

class RollingThroughOptions<T extends Object> extends StatelessWidget {
  const RollingThroughOptions({
    super.key,
    this.value,
    required this.options,
    this.builder = _kDefaultValueToWidget,
    this.onChanged,
    this.padding = iFormFieldContentPadding,
    this.leading,
    this.color,
  });

  final T? value;
  final ValueChanged<T>? onChanged;
  final Widget? leading;
  final EdgeInsetsGeometry padding;
  final List<T> options;
  final Widget Function(T value) builder;
  final Color? color;

  int get index {
    // int index = 0;
    if (value != null) {
      final i = options.indexOf(value!);
      if (i > 0 && i < options.length) return i;
    }

    return 0;
  }

  void _handleChange() {
    final i = index;
    final nextIndex = i < (options.length - 1) ? i + 1 : 0;
    final nextValue = options.elementAt(nextIndex);
    onChanged!.call(nextValue);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveValue = options.elementAt(index);
    return Tappable(
      childAlignment: AlignmentGeometry.centerLeft,
      onTap: onChanged != null ? _handleChange : null,
      padding: padding,
      leading: leading,
      trailing: const Icon(Icons.unfold_more_rounded),
      color: color,
      child: FadeIn(key: ValueKey(effectiveValue), from: Offset(0.0, 0.4), child: builder(effectiveValue)),
    );
  }
}

Widget _kDefaultValueToWidget(Object value) => Text(value.toString());
