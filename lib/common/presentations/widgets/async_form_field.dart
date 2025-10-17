import 'dart:async';

import 'package:invesly/common/presentations/animations/fade_in.dart';
import 'package:invesly/common/presentations/animations/shake.dart';
import 'package:invesly/common_libs.dart';

class AsyncFormField<T> extends FormField<T> {
  AsyncFormField({
    super.key,
    super.initialValue,
    FutureOr<T?> Function(T? value)? onTapCallback,
    super.forceErrorText,
    super.onSaved,
    this.onChanged,
    super.enabled = true,
    super.validator,
    AutovalidateMode? autovalidateMode,
    super.errorBuilder,
    required Widget Function(T? value) childBuilder,
    Widget? leading,
    Widget? trailing,
    EdgeInsetsGeometry padding = AppConstants.formFieldContentPadding,
    AlignmentGeometry contentAlignment = Alignment.centerLeft,
    Color? color,
    Color? errorColor, // TODO: Change to material state color
    super.restorationId,
  }) : super(
         autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
         builder: (FormFieldState<T> field) {
           //  final state = field as _AsyncFormFieldState;
           final theme = Theme.of(field.context);

           final colors = theme.colorScheme;
           final textTheme = theme.textTheme;

           final errorText = field.errorText;

           TextStyle errorStyle = textTheme.bodySmall ?? const TextStyle();
           errorStyle = errorStyle.copyWith(color: colors.error).merge(theme.inputDecorationTheme.errorStyle);

           Widget? error;
           if (errorText != null) {
             error =
                 errorBuilder?.call(field.context, errorText) ??
                 Text(errorText, style: errorStyle, overflow: TextOverflow.ellipsis, maxLines: 1);
           }

           final hasError = errorText != null && error != null;

           return Column(
             mainAxisSize: MainAxisSize.min,
             crossAxisAlignment: CrossAxisAlignment.start,
             spacing: 4.0,
             children: <Widget>[
               Shake(
                 shake: hasError,
                 child: Tappable(
                   onTap: () {
                     if (onTapCallback == null) return;

                     final result = onTapCallback.call(field.value);
                     if (result is Future<T?>) {
                       result.then((value) => field.didChange(value));
                     } else {
                       field.didChange(result);
                     }
                   },
                   childAlignment: contentAlignment,
                   padding: padding,
                   leading: leading,
                   trailing: trailing,
                   color: hasError ? errorColor ?? colors.errorContainer : color ?? colors.primaryContainer,
                   child: childBuilder(field.value),
                 ),
               ),

               //  if (hasError)
               Padding(
                 padding: padding.resolve(TextDirection.ltr).copyWith(top: 0.0, bottom: 0.0),
                 child: FadeIn(from: Offset(0.0, -0.25), fadeIn: hasError, child: error ?? SizedBox.shrink()),
               ),
             ],
           );
         },
       );

  final ValueChanged<T?>? onChanged;

  @override
  FormFieldState<T> createState() => _AsyncFormFieldState();
}

class _AsyncFormFieldState<T> extends FormFieldState<T> {
  AsyncFormField<T> get _formField => widget as AsyncFormField<T>;

  @override
  void didChange(T? value) {
    super.didChange(value);
    // Call the onChanged callback if provided
    _formField.onChanged?.call(value);
  }

  @override
  void didUpdateWidget(AsyncFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setValue(widget.initialValue);
    }
  }
}
