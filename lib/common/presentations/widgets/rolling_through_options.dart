import 'package:flutter/material.dart';
import 'package:invesly/common/presentations/animations/fade_in.dart';
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
    this.trailing,
    this.decoration,
  });

  final T? value;
  final ValueChanged<T>? onChanged;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final List<T> options;
  final Widget Function(T value) builder;
  final BoxDecoration? decoration;

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
    Widget content = FadeIn(key: ValueKey(effectiveValue), from: Offset(0.0, 0.4), child: builder(effectiveValue));

    if (leading != null || trailing != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ?leading,
          Expanded(child: content),
          ?trailing,
        ],
      );
    }

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    if (decoration != null) {
      content = DecoratedBox(decoration: decoration!, child: content);
    }

    return GestureDetector(
      onTap: onChanged != null ? _handleChange : null,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }
}

Widget _kDefaultValueToWidget(Object value) => Text(value.toString());
