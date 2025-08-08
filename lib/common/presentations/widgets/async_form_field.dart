import 'dart:async';

// import 'package:animate_do/animate_do.dart';

import 'package:invesly/common/presentations/animations/fade_in.dart';
import 'package:invesly/common/presentations/animations/shake.dart';
import 'package:invesly/common_libs.dart';

class AsyncFormField<T> extends FormField<T> {
  AsyncFormField({
    super.key,
    super.initialValue,
    FutureOr<T?> Function()? onTapCallback,
    // this.onChanged,
    super.forceErrorText,
    super.onSaved,
    this.onChanged,
    super.enabled = true,
    super.validator,
    AutovalidateMode? autovalidateMode,
    super.errorBuilder,
    required Widget Function(T? value) childBuilder,
    EdgeInsetsGeometry padding = AppConstants.formFieldContentPadding,
    AlignmentGeometry contentAlignment = Alignment.centerLeft,
    super.restorationId,
  }) : super(
         autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
         builder: (FormFieldState<T> field) {
           //  final state = field as _AsyncFormFieldState;
           final theme = Theme.of(field.context);

           final colors = theme.colorScheme;
           final textTheme = theme.textTheme;

           final errorText = field.errorText;
           final hasError = errorText != null && errorText.isNotEmpty;

           Widget? error;
           if (hasError && errorBuilder != null) {
             error = errorBuilder(field.context, errorText);
           }

           TextStyle errorStyle = textTheme.bodySmall ?? const TextStyle();
           errorStyle = errorStyle.copyWith(color: colors.error).merge(theme.inputDecorationTheme.errorStyle);

           return Shake(
             shake: hasError,
             //  duration: const Duration(milliseconds: 500),
             child: Column(
               mainAxisSize: MainAxisSize.min,
               crossAxisAlignment: CrossAxisAlignment.start,
               spacing: 4.0,
               children: <Widget>[
                 Tappable(
                   onTap: () {
                     if (onTapCallback == null) return;

                     final result = onTapCallback.call();
                     if (result is Future<T?>) {
                       result.then((value) => field.didChange(value));
                     } else {
                       field.didChange(result);
                     }
                   },
                   childAlignment: contentAlignment,
                   padding: padding,
                   bgColor: hasError ? colors.errorContainer : colors.primaryContainer,
                   child: childBuilder(field.value),
                 ),
                 if (hasError)
                   Padding(
                     padding: EdgeInsets.only(horizontal: padding.),
                     child: _ErrorViewer(error: error, errorText: errorText, errorStyle: errorStyle),
                   ),
               ],
             ),
           );
         },
       );

  final ValueChanged<T?>? onChanged;

  @override
  FormFieldState<T> createState() => _AsyncFormFieldState();
}

class _AsyncFormFieldState<T> extends FormFieldState<T> {
  AsyncFormField<T> get _formField => widget as AsyncFormField<T>;

  bool isShaked = false;

  @override
  void didChange(T? value) {
    super.didChange(value);
    // Call the onChanged callback if provided
    _formField.onChanged?.call(value);
  }
}

class _ErrorViewer extends StatefulWidget {
  const _ErrorViewer({this.textAlign, this.error, this.errorText, this.errorStyle, this.errorMaxLines});

  final TextAlign? textAlign;
  final Widget? error;
  final String? errorText;
  final TextStyle? errorStyle;
  final int? errorMaxLines;

  @override
  _ErrorViewerState createState() => _ErrorViewerState();
}

class _ErrorViewerState extends State<_ErrorViewer> with SingleTickerProviderStateMixin {
  // If the height of this widget and the counter are zero ("empty") at
  // layout time, no space is allocated for the subtext.
  static const Widget empty = SizedBox.shrink();

  late AnimationController _controller;
  bool get _hasError => widget.errorText != null || widget.error != null;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 167), vsync: this);
    if (_hasError) {
      _controller.value = 1.0;
    }
    // _controller.addListener(_handleChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_ErrorViewer oldWidget) {
    super.didUpdateWidget(oldWidget);

    final Widget? newError = widget.error;
    final String? newErrorText = widget.errorText;
    final Widget? oldError = oldWidget.error;
    final String? oldErrorText = oldWidget.errorText;

    final bool errorStateChanged = (newError != null) != (oldError != null);
    final bool errorTextStateChanged = (newErrorText != null) != (oldErrorText != null);

    if (errorStateChanged || errorTextStateChanged) {
      if (newError != null || newErrorText != null) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  Widget _buildError() {
    assert(widget.error != null || widget.errorText != null);
    return FadeIn(
      from: Offset(0.0, -0.25),
      fade: _hasError,
      child:
          widget.error ??
          Text(
            widget.errorText!,
            style: widget.errorStyle,
            textAlign: widget.textAlign,
            overflow: TextOverflow.ellipsis,
            maxLines: widget.errorMaxLines,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildError();
    }

    return empty;
  }
}
