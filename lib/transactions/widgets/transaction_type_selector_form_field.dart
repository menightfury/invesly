import 'package:flutter/material.dart';
import 'package:invesly/common/presentations/animations/fade_in.dart';
import 'package:invesly/common/presentations/widgets/async_form_field.dart';
import 'package:invesly/constants.dart';
import 'package:invesly/transactions/model/transaction_model.dart';

class TransactionTypeSelectorFormField extends StatelessWidget {
  const TransactionTypeSelectorFormField({
    super.key,
    this.initialValue,
    this.onChanged,
    this.padding = AppConstants.formFieldContentPadding,
    this.leading,
  });

  final TransactionType? initialValue;
  final ValueChanged<TransactionType?>? onChanged;
  final Widget? leading;
  final EdgeInsetsGeometry padding;
  final _types = TransactionType.values;

  @override
  Widget build(BuildContext context) {
    return AsyncFormField<TransactionType>(
      // contentAlignment: Alignment.center,
      initialValue: initialValue ?? _types.elementAt(0),
      onTapCallback: (value) {
        int index = 0;
        if (value != null) {
          final i = _types.indexOf(value);
          if (i > 0 && i < _types.length) index = i;
        }
        final nextIndex = index < (_types.length - 1) ? index + 1 : 0;
        return _types.elementAt(nextIndex);
      },
      onChanged: onChanged,
      padding: padding,
      leading: leading,
      trailing: Icon(Icons.unfold_more_rounded),
      childBuilder: (value) {
        return FadeIn(key: ValueKey(value), from: Offset(0.0, 0.4), child: Text(value!.name.toUpperCase()));
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
