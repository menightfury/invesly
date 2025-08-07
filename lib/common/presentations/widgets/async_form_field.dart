import 'dart:async';
import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:invesly/common/extensions/num_extension.dart';
import 'package:invesly/common/presentations/animations/shake.dart';
import 'package:invesly/common_libs.dart';

import '../components/tappable.dart';

class AsyncFormField<T> extends FormField<T> {
  AsyncFormField({
    super.key,
    super.initialValue,
    FutureOr<T?> Function()? onTapCallback,
    // this.onChanged,
    super.forceErrorText,
    super.onSaved,
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

           //  InputDecoration effectiveDecoration = (decoration ?? const InputDecoration()).applyDefaults(
           //    Theme.of(field.context).inputDecorationTheme,
           //  );

           final errorText = field.errorText;
           final hasError = errorText != null;

           Widget? error;
           if (errorText != null && errorBuilder != null) {
             error = errorBuilder(field.context, errorText);
           }

           // void onChangedHandler(String value) {
           //   field.didChange(value);
           //   onChanged?.call(value);
           // }

           TextStyle errorStyle = textTheme.bodySmall ?? const TextStyle();
           errorStyle = errorStyle.copyWith(color: colors.error).merge(theme.inputDecorationTheme.errorStyle);

           return ShakeX(
             animate: hasError,
             duration: const Duration(milliseconds: 500),
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
                       result.then((value) {
                         $logger.w(value);
                         field.didChange(value);
                       });
                     } else {
                       field.didChange(result);
                     }
                   },
                   childAlignment: contentAlignment,
                   padding: padding,
                   bgColor: hasError ? colors.errorContainer : colors.primaryContainer,
                   child: childBuilder(initialValue),
                 ),
                 if (hasError)
                   Padding(
                     padding: padding,
                     child: _ErrorViewer(error: error, errorText: errorText, errorStyle: errorStyle),
                   ),
               ],
             ),
           );
         },
       );

  // final ValueChanged<String>? onChanged;

  @override
  FormFieldState<T> createState() => _AsyncFormFieldState();
}

class _AsyncFormFieldState<T> extends FormFieldState<T> {
  //
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

  // void _handleChange() {
  //   setState(() {
  //     // The _controller's value has changed.
  //   });
  // }

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
    return FadeInDown(
      // manualTrigger: true,
      // controller: (controller) => _controller = controller,
      animate: _hasError,
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
    // if (_controller.isDismissed) {
    //   return empty;
    // }

    // if (_controller.isCompleted) {
    //   if (_hasError) {
    //     return _buildError();
    //   }
    //   return empty;
    // }

    if (_hasError) {
      return _buildError();
    }

    return empty;
  }
}
