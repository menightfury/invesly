import 'package:flutter/material.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/common/presentations/animations/fade_in.dart';
import 'package:invesly/common/presentations/widgets/async_form_field.dart';
import 'package:invesly/constants.dart';

class GenreSelectorFormField extends StatelessWidget {
  const GenreSelectorFormField({
    super.key,
    this.initialValue,
    this.onChanged,
    this.padding = iFormFieldContentPadding,
    this.leading,
  });

  final AmcGenre? initialValue;
  final ValueChanged<AmcGenre?>? onChanged;
  final Widget? leading;
  final EdgeInsetsGeometry padding;
  final _genres = AmcGenre.values;

  @override
  Widget build(BuildContext context) {
    return AsyncFormField<AmcGenre>(
      // contentAlignment: Alignment.center,
      initialValue: initialValue ?? _genres.elementAt(0),
      onTapCallback: (value) {
        int index = 0;
        if (value != null) {
          final i = _genres.indexOf(value);
          if (i > 0 && i < _genres.length) index = i;
        }
        final nextIndex = index < (_genres.length - 1) ? index + 1 : 0;
        return _genres.elementAt(nextIndex);
      },
      onChanged: onChanged,
      padding: padding,
      leading: leading,
      trailing: Icon(Icons.unfold_more_rounded),
      childBuilder: (value) {
        return FadeIn(
          key: ValueKey(value),
          from: Offset(0.0, 0.4),
          child: Text(value!.title, overflow: TextOverflow.ellipsis),
        );
      },
      validator: (value) {
        if (value == null) {
          return 'Can\'t be empty';
        }
        return null;
      },
    );
  }
}
