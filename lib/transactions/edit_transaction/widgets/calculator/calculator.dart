import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:invesly/constants.dart';

import 'cubit/calculator_cubit.dart';

const _kButtonBorderRadius = BorderRadius.all(Radius.circular(4.0));

class InveslyCalculatorWidget extends StatelessWidget {
  const InveslyCalculatorWidget({super.key, this.initialAmount, this.onSubmit});

  final num? initialAmount;
  final ValueChanged<double>? onSubmit;

  static Future<double?> showModal(BuildContext context, [num? initialAmount]) async {
    return await showModalBottomSheet<double>(
      context: context,
      // enableDrag: false,
      // isScrollControlled: true,
      builder: (context) {
        return InveslyCalculatorWidget(
          initialAmount: initialAmount,
          onSubmit: (value) => Navigator.maybePop<double>(context, value),
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
            cubit.handleNumber(number);
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
            cubit.handleOperator(operator);
          }
        } else if ([
          LogicalKeyboardKey.period,
          LogicalKeyboardKey.numpadDecimal,
          LogicalKeyboardKey.comma,
        ].contains(key)) {
          cubit.handleDecimal();
        } else if (key == LogicalKeyboardKey.backspace) {
          cubit.handleBackspace();
        } else if (key == LogicalKeyboardKey.delete) {
          cubit.handleClear();
        } else if (key == LogicalKeyboardKey.enter) {
          cubit.calculateOrSubmit();
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 4.0,
                  children: [
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

                // ~ Right operand
                BlocSelector<CalculatorCubit, CalculatorState, String>(
                  selector: (state) => state.rightOperand,
                  builder: (_, rightOperand) {
                    return _NumberDisplayer(double.tryParse(rightOperand) ?? 0.0);
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
                    onPressed: cubit.handleToggleSign,
                    icon: const Icon(Icons.exposure_rounded),
                    bgColor: themeColor.primary,
                    textColor: themeColor.onPrimary,
                    borderRadius: _kButtonBorderRadius.copyWith(topLeft: AppConstants.buttonBorderRadius.topLeft),
                  ),
                  _CalculatorButton(
                    onPressed: cubit.handleBackspace,
                    icon: const Icon(Icons.backspace_rounded),
                    textColor: themeColor.onErrorContainer,
                    bgColor: themeColor.errorContainer,
                  ),
                  _CalculatorButton(
                    onPressed: cubit.handleClear,
                    label: 'AC',
                    textColor: themeColor.onErrorContainer,
                    bgColor: themeColor.errorContainer,
                  ),
                  _CalculatorButton(
                    onPressed: () => cubit.handleOperator(CalculatorOperator.divide),
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
                  _CalculatorButton(onPressed: () => cubit.handleNumber(1), label: '1'),
                  _CalculatorButton(onPressed: () => cubit.handleNumber(2), label: '2'),
                  _CalculatorButton(onPressed: () => cubit.handleNumber(3), label: '3'),
                  _CalculatorButton(
                    onPressed: () => cubit.handleOperator(CalculatorOperator.multiply),
                    label: CalculatorOperator.multiply.symbol,
                    textColor: themeColor.onPrimary,
                    bgColor: themeColor.primary,
                  ),
                ],
              ),
              Row(
                spacing: 2.0,
                children: <Widget>[
                  _CalculatorButton(onPressed: () => cubit.handleNumber(4), label: '4'),
                  _CalculatorButton(onPressed: () => cubit.handleNumber(5), label: '5'),
                  _CalculatorButton(onPressed: () => cubit.handleNumber(6), label: '6'),
                  _CalculatorButton(
                    onPressed: () => cubit.handleOperator(CalculatorOperator.subtract),
                    label: CalculatorOperator.subtract.symbol,
                    textColor: themeColor.onPrimary,
                    bgColor: themeColor.primary,
                  ),
                ],
              ),
              Row(
                spacing: 2.0,
                children: <Widget>[
                  _CalculatorButton(onPressed: () => cubit.handleNumber(7), label: '7'),
                  _CalculatorButton(onPressed: () => cubit.handleNumber(8), label: '8'),
                  _CalculatorButton(onPressed: () => cubit.handleNumber(9), label: '9'),
                  _CalculatorButton(
                    onPressed: () => cubit.handleOperator(CalculatorOperator.add),
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
                        onPressed: () => cubit.handleDecimal(),
                        label: '.',
                        borderRadius: _kButtonBorderRadius.copyWith(
                          bottomLeft: AppConstants.buttonBorderRadius.bottomLeft,
                        ),
                      );
                    },
                  ),
                  _CalculatorButton(onPressed: () => cubit.handleNumber(0), label: '0'),
                  BlocBuilder<CalculatorCubit, CalculatorState>(
                    buildWhen: (previous, current) {
                      return (previous.leftOperand != current.leftOperand &&
                              (current.leftOperand.isZeroOrEmpty || previous.leftOperand.isZeroOrEmpty)) ||
                          (previous.rightOperand != current.rightOperand &&
                              (current.rightOperand.isZeroOrEmpty || previous.rightOperand.isZeroOrEmpty));
                    },
                    builder: (context, state) {
                      debugPrint('Rebuilding submit button');
                      return _CalculatorButton(
                        disabled: state.leftOperand.isZeroOrEmpty && state.rightOperand.isZeroOrEmpty,
                        onPressed: () {
                          cubit.calculateOrSubmit();

                          // XOR operation
                          if (state.leftOperand.isZeroOrEmpty ^ state.rightOperand.isZeroOrEmpty) {
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
        style: TextButton.styleFrom(
          minimumSize: const Size.fromHeight(56.0),
          foregroundColor: textColor ?? theme.colorScheme.onPrimaryContainer,
          backgroundColor: bgColor ?? theme.colorScheme.primaryContainer,
          disabledForegroundColor: textColor?.withAlpha(200) ?? Colors.black38,
          disabledBackgroundColor: bgColor?.withAlpha(100) ?? theme.colorScheme.surface,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: child,
      ),
    );
  }
}

/// Display amount in decorated manners
class _NumberDisplayer extends StatelessWidget {
  const _NumberDisplayer(this.amount, [this.format]);

  final double amount;
  final RegExp? format;

  List<String?>? formatAmount(String data) {
    final match = format?.firstMatch(data);
    if (match == null) return null;

    final List<String?> strings = [];
    for (int i = 0; i < match.groupCount; i++) {
      strings.add(match.group(i + 1));
    }
    return strings;
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;
    final data = NumberFormat.decimalPattern('en_IN').format(amount);
    final fData = formatAmount(data);

    if (fData == null) {
      return Text(
        data,
        style: TextStyle(fontSize: 40.0, color: color),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Text.rich(
      TextSpan(
        text: fData[0] ?? '',
        style: TextStyle(fontSize: 40.0, color: color.withAlpha(125)),
        children: <TextSpan>[
          if (fData.length > 1)
            TextSpan(
              text: fData[1] ?? '',
              style: TextStyle(fontSize: 72.0, color: color),
            ),
          if (fData.length > 2) TextSpan(text: fData.sublist(2).where((e) => e != null).join()),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
