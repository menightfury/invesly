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
  });

  final T? value;
  final ValueChanged<T>? onChanged;
  final Widget? leading;
  final EdgeInsetsGeometry padding;
  final List<T> options;
  final Widget Function(T value) builder;

  @override
  Widget build(BuildContext context) {
    int index = 0;
    if (value != null) {
      final i = options.indexOf(value!);
      if (i > 0 && i < options.length) index = i;
    }
    final effectiveValue = options.elementAt(index);
    return Tappable(
      // contentAlignment: Alignment.center,
      onTap: onChanged != null
          ? () {
              final nextIndex = index < (options.length - 1) ? index + 1 : 0;
              final nextValue = options.elementAt(nextIndex);
              onChanged!.call(nextValue);
            }
          : null,
      padding: padding,
      leading: leading,
      trailing: const Icon(Icons.unfold_more_rounded),
      child: FadeIn(from: Offset(0.0, 0.4), child: builder(effectiveValue)),
    );
  }
}

Widget _kDefaultValueToWidget(Object value) => Text(value.toString());
