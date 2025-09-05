import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/constants.dart';

import 'cubit/calculator_cubit.dart';

const _kButtonBorderRadius = BorderRadius.all(Radius.circular(4.0));

class InveslyCalculatorWidget extends StatelessWidget {
  const InveslyCalculatorWidget({super.key, this.initialAmount, this.onSubmit});

  final num? initialAmount;
  final ValueChanged<num>? onSubmit;

  static Future<num?> showModal(BuildContext context, [num? initialAmount]) async {
    return await showModalBottomSheet<num>(
      context: context,
      // enableDrag: false,
      // isScrollControlled: true,
      builder: (context) {
        return InveslyCalculatorWidget(
          initialAmount: initialAmount,
          onSubmit: (value) => Navigator.maybePop<num>(context, value),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CalculatorCubit(initialValue: initialAmount),
      child: _InveslyCalculatorWidget(onSubmit: onSubmit),
    );
  }
}

class _InveslyCalculatorWidget extends StatefulWidget {
  const _InveslyCalculatorWidget({super.key, this.onSubmit});

  final ValueChanged<double>? onSubmit;

  @override
  State<_InveslyCalculatorWidget> createState() => __InveslyCalculatorWidgetState();
}

class __InveslyCalculatorWidgetState extends State<_InveslyCalculatorWidget> {
  final FocusNode _focusNode = FocusNode();
  late FocusAttachment _focusAttachment;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<CalculatorCubit>();

    _focusAttachment = _focusNode.attach(
      context,
      onKeyEvent: (node, event) {
        bool keyIsPressed = event is KeyDownEvent || event is KeyRepeatEvent;

        if (!keyIsPressed) {
          return KeyEventResult.handled;
        }

        final key = event.logicalKey;
        if ([
          LogicalKeyboardKey.digit0,
          LogicalKeyboardKey.digit1,
          LogicalKeyboardKey.digit2,
          LogicalKeyboardKey.digit3,
          LogicalKeyboardKey.digit4,
          LogicalKeyboardKey.digit5,
          LogicalKeyboardKey.digit6,
          LogicalKeyboardKey.digit7,
          LogicalKeyboardKey.digit8,
          LogicalKeyboardKey.digit9,
          LogicalKeyboardKey.numpad0,
          LogicalKeyboardKey.numpad1,
          LogicalKeyboardKey.numpad2,
          LogicalKeyboardKey.numpad3,
          LogicalKeyboardKey.numpad4,
          LogicalKeyboardKey.numpad5,
          LogicalKeyboardKey.numpad6,
          LogicalKeyboardKey.numpad7,
          LogicalKeyboardKey.numpad8,
          LogicalKeyboardKey.numpad9,
        ].contains(key)) {
          final number = int.tryParse(key.keyLabel);
          if (number != null) {
            cubit.handleNumberPressed(number);
          }
        } else if ([
          LogicalKeyboardKey.add,
          LogicalKeyboardKey.numpadAdd,
          LogicalKeyboardKey.minus,
          LogicalKeyboardKey.numpadSubtract,
          LogicalKeyboardKey.numpadMultiply,
          LogicalKeyboardKey.slash,
          LogicalKeyboardKey.numpadDivide,
        ].contains(key)) {
          final operator = CalculatorOperator.fromString(key.keyLabel);
          if (operator != null) {
            cubit.handleOperatorPressed(operator);
          }
        } else if ([
          LogicalKeyboardKey.period,
          LogicalKeyboardKey.numpadDecimal,
          LogicalKeyboardKey.comma,
        ].contains(key)) {
          cubit.handleDecimalPressed();
        } else if (key == LogicalKeyboardKey.backspace) {
          cubit.handleBackspacePressed();
        } else if (key == LogicalKeyboardKey.delete) {
          cubit.handleClearPressed();
        } else if (key == LogicalKeyboardKey.enter) {
          cubit.calculate();
        }

        return KeyEventResult.handled;
      },
    );

    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusAttachment.detach();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;
    _focusAttachment.reparent();
    final cubit = context.read<CalculatorCubit>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              spacing: 4.0,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                // ~ Left operand and operator
                SizedBox(
                  height: 30.0, // To avoid layout shift when left operand is empty
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 4.0,
                    children: <Widget>[
                      BlocSelector<CalculatorCubit, CalculatorState, String>(
                        selector: (state) => state.leftOperand,
                        builder: (_, data) {
                          return Text(
                            data,
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
                          );
                        },
                      ),

                      BlocSelector<CalculatorCubit, CalculatorState, CalculatorOperator?>(
                        selector: (state) => state.operator,
                        builder: (_, data) {
                          return Text(
                            data?.symbol ?? '',
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // ~ Right operand
                BlocSelector<CalculatorCubit, CalculatorState, String>(
                  selector: (state) => state.rightOperand,
                  builder: (_, rightOperand) {
                    return _NumberDisplayer(num.tryParse(rightOperand) ?? 0);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),
          const Divider(),

          // ~ Buttons
          Column(
            spacing: 2.0,
            children: <Widget>[
              Row(
                spacing: 2.0,
                children: <Widget>[
                  _CalculatorButton(
                    onPressed: cubit.handleToggleSignPressed,
                    icon: const Icon(Icons.exposure_rounded),
                    bgColor: themeColor.primary,
                    textColor: themeColor.onPrimary,
                    borderRadius: _kButtonBorderRadius.copyWith(topLeft: AppConstants.buttonBorderRadius.topLeft),
                  ),
                  _CalculatorButton(
                    onPressed: cubit.handleBackspacePressed,
                    icon: const Icon(Icons.backspace_rounded),
                    textColor: themeColor.onErrorContainer,
                    bgColor: themeColor.errorContainer,
                  ),
                  _CalculatorButton(
                    onPressed: cubit.handleClearPressed,
                    label: 'AC',
                    textColor: themeColor.onErrorContainer,
                    bgColor: themeColor.errorContainer,
                  ),
                  _CalculatorButton(
                    onPressed: () => cubit.handleOperatorPressed(CalculatorOperator.divide),
                    label: CalculatorOperator.divide.symbol,
                    textColor: themeColor.onPrimary,
                    bgColor: themeColor.primary,
                    borderRadius: _kButtonBorderRadius.copyWith(topRight: AppConstants.buttonBorderRadius.topRight),
                  ),
                ],
              ),
              Row(
                spacing: 2.0,
                children: <Widget>[
                  _CalculatorButton(onPressed: () => cubit.handleNumberPressed(1), label: '1'),
                  _CalculatorButton(onPressed: () => cubit.handleNumberPressed(2), label: '2'),
                  _CalculatorButton(onPressed: () => cubit.handleNumberPressed(3), label: '3'),
                  _CalculatorButton(
                    onPressed: () => cubit.handleOperatorPressed(CalculatorOperator.multiply),
                    label: CalculatorOperator.multiply.symbol,
                    textColor: themeColor.onPrimary,
                    bgColor: themeColor.primary,
                  ),
                ],
              ),
              Row(
                spacing: 2.0,
                children: <Widget>[
                  _CalculatorButton(onPressed: () => cubit.handleNumberPressed(4), label: '4'),
                  _CalculatorButton(onPressed: () => cubit.handleNumberPressed(5), label: '5'),
                  _CalculatorButton(onPressed: () => cubit.handleNumberPressed(6), label: '6'),
                  _CalculatorButton(
                    onPressed: () => cubit.handleOperatorPressed(CalculatorOperator.subtract),
                    label: CalculatorOperator.subtract.symbol,
                    textColor: themeColor.onPrimary,
                    bgColor: themeColor.primary,
                  ),
                ],
              ),
              Row(
                spacing: 2.0,
                children: <Widget>[
                  _CalculatorButton(onPressed: () => cubit.handleNumberPressed(7), label: '7'),
                  _CalculatorButton(onPressed: () => cubit.handleNumberPressed(8), label: '8'),
                  _CalculatorButton(onPressed: () => cubit.handleNumberPressed(9), label: '9'),
                  _CalculatorButton(
                    onPressed: () => cubit.handleOperatorPressed(CalculatorOperator.add),
                    label: CalculatorOperator.add.symbol,
                    bgColor: themeColor.primary,
                    textColor: themeColor.onPrimary,
                  ),
                ],
              ),
              Row(
                spacing: 2.0,
                children: <Widget>[
                  BlocSelector<CalculatorCubit, CalculatorState, bool>(
                    selector: (state) => state.rightOperand.hasDecimal,
                    builder: (context, hasDecimal) {
                      return _CalculatorButton(
                        disabled: hasDecimal,
                        onPressed: () => cubit.handleDecimalPressed(),
                        label: '.',
                        borderRadius: _kButtonBorderRadius.copyWith(
                          bottomLeft: AppConstants.buttonBorderRadius.bottomLeft,
                        ),
                      );
                    },
                  ),
                  _CalculatorButton(onPressed: () => cubit.handleNumberPressed(0), label: '0'),
                  BlocBuilder<CalculatorCubit, CalculatorState>(
                    // buildWhen: (previous, current) {
                    //   return (previous.leftOperand != current.leftOperand &&
                    //           (current.leftOperand.isZeroOrEmpty || previous.leftOperand.isZeroOrEmpty)) ||
                    //       (previous.rightOperand != current.rightOperand &&
                    //           (current.rightOperand.isZeroOrEmpty || previous.rightOperand.isZeroOrEmpty));
                    // },
                    builder: (context, state) {
                      debugPrint('Rebuilding submit button');
                      return _CalculatorButton(
                        disabled: state.leftOperand.isZeroOrEmpty && state.rightOperand.isZeroOrEmpty,
                        onPressed: () {
                          if (state.leftOperand.isNotZeroOrEmpty && state.operator != null) {
                            cubit.calculate();
                          }

                          // XOR operation
                          if (state.leftOperand.isZeroOrEmpty ^ state.rightOperand.isZeroOrEmpty) {
                            $logger.w(state.rightOperand);
                            widget.onSubmit?.call(double.tryParse(state.rightOperand) ?? 0.0);
                          }
                        },
                        label: (state.leftOperand.isZeroOrEmpty || state.rightOperand.isZeroOrEmpty) ? null : '=',
                        icon: (state.leftOperand.isZeroOrEmpty || state.rightOperand.isZeroOrEmpty)
                            ? Icon(Icons.check_rounded)
                            : null,
                        flex: 2,
                        textColor: themeColor.onPrimary,
                        bgColor: themeColor.primary,
                        borderRadius: _kButtonBorderRadius.copyWith(
                          bottomRight: AppConstants.buttonBorderRadius.bottomRight,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalculatorButton extends StatelessWidget {
  final String? label;
  final Widget? icon;
  final Color? textColor;
  final Color? bgColor;
  final VoidCallback? onPressed;
  final int flex;
  final bool disabled;
  final BorderRadius borderRadius;

  const _CalculatorButton({
    this.flex = 1,
    this.label,
    this.icon,
    required this.onPressed,
    this.textColor,
    this.bgColor,
    this.disabled = false,
    this.borderRadius = _kButtonBorderRadius,
  }) : assert(icon != null || label != null, "Either label or icon has to be assigned"),
       assert(label == null || icon == null, "Both label and icon can't be assigned");

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = icon ?? Text(label!, style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600));

    return Expanded(
      flex: flex,
      child: TextButton(
        onPressed: disabled ? null : onPressed,
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size.fromHeight(56.0)),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.disabled)) {
              return bgColor?.withAlpha(100) ?? theme.disabledColor;
            }
            return bgColor ?? theme.colorScheme.primaryContainer;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.disabled)) {
              return textColor?.withAlpha(200) ?? Colors.black38;
            }
            return textColor ?? theme.colorScheme.onPrimaryContainer;
          }),
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: borderRadius)),
        ),
        // style: TextButton.styleFrom(
        //   minimumSize: const Size.fromHeight(56.0),
        //   backgroundColor: bgColor ?? theme.colorScheme.primaryContainer,
        //   foregroundColor: textColor ?? theme.colorScheme.onPrimaryContainer,
        //   disabledBackgroundColor: bgColor?.withAlpha(100) ?? theme.disabledColor,
        //   disabledForegroundColor: textColor?.withAlpha(200) ?? Colors.black38,
        //   padding: EdgeInsets.zero,
        //   shape: RoundedRectangleBorder(borderRadius: borderRadius),
        // ),
        child: child,
      ),
    );
  }
}

/// Display amount in decorated manners
class _NumberDisplayer extends StatelessWidget {
  const _NumberDisplayer(this.amount, [this.format]);

  final num amount;
  final RegExp? format;

  @override
  Widget build(BuildContext context) {
    $logger.d('Building number displayer for $amount');
    final parts = amount.toString().split('.');
    // final data = NumberFormat.decimalPattern('en_IN').format(amount);
    // final fData = formatAmount(data);
    final integer = int.tryParse(parts[0]) ?? 0;

    return Text.rich(
      TextSpan(
        style: const TextStyle(fontSize: 36.0),
        children: <TextSpan>[
          // Integer part
          TextSpan(text: NumberFormat.decimalPattern('en_IN').format(integer)),

          if (parts.length > 1) ...[
            // Decimal separator
            TextSpan(text: '.'),
            // Decimal part
            TextSpan(text: parts[1], style: TextStyle(fontSize: 28.0)),
          ],
          // TextSpan(
          //   text: parts[1] ?? '',
          //   style: TextStyle(fontSize: 72.0, color: color),
          // ),
          // if (fData.length > 2) TextSpan(text: fData.sublist(2).where((e) => e != null).join()),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
