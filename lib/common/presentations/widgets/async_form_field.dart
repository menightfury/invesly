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
    EdgeInsetsGeometry padding = iFormFieldContentPadding,
    AlignmentGeometry contentAlignment = Alignment.centerLeft,
    WidgetStateColor? color,
    super.restorationId,
  }) : super(
         autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
         builder: (FormFieldState<T> fieldState) {
           final state = fieldState as _AsyncFormFieldState;
           final theme = Theme.of(state.context);

           final colors = theme.colorScheme;
           final textTheme = theme.textTheme;

           final errorText = state.errorText;

           TextStyle errorStyle = textTheme.bodySmall ?? const TextStyle();
           errorStyle = errorStyle.copyWith(color: colors.error).merge(theme.inputDecorationTheme.errorStyle);

           Widget? error;
           if (errorText != null) {
             error =
                 errorBuilder?.call(state.context, errorText) ??
                 Text(errorText, style: errorStyle, overflow: TextOverflow.ellipsis, maxLines: 1);
           }

           //  final hasError = errorText != null && error != null;

           return Column(
             mainAxisSize: MainAxisSize.min,
             crossAxisAlignment: CrossAxisAlignment.start,
             spacing: 4.0,
             children: <Widget>[
               Shake(
                 shake: state.hasError,
                 child: Tappable(
                   onTap: enabled
                       ? () {
                           if (onTapCallback == null) return;

                           final result = onTapCallback.call(state.value);
                           if (result is Future<T?>) {
                             result.then((value) => state.didChange(value));
                           } else {
                             state.didChange(result);
                           }
                         }
                       : null,
                   childAlignment: contentAlignment,
                   padding: padding,
                   leading: leading,
                   trailing: trailing,
                   color:
                       color?.resolve(state.widgetState) ??
                       WidgetStateProperty.resolveAs(state.defaultColor, state.widgetState),
                   child: childBuilder(state.value),
                 ),
               ),

               //  if (hasError)
               Padding(
                 padding: padding.resolve(TextDirection.ltr).copyWith(top: 0.0, bottom: 0.0),
                 child: FadeIn(from: Offset(0.0, -0.25), fadeIn: state.hasError, child: error ?? SizedBox.shrink()),
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

  Set<WidgetState> get widgetState => <WidgetState>{
    if (!_formField.enabled) WidgetState.disabled,
    // if (isFocused) WidgetState.focused,
    // if (isHovering) WidgetState.hovered,
    if (hasError) WidgetState.error,
  };

  Color get defaultColor => WidgetStateColor.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return Colors.black12;
    }

    if (states.contains(WidgetState.error)) {
      return context.colors.errorContainer;
    }

    return context.colors.primaryContainer;
  });

  @override
  void didChange(T? value) {
    super.didChange(value);
    validate();
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
