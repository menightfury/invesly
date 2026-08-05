// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:intl/intl.dart';

import 'package:invesly/common_libs.dart';

const _kButtonSpacing = 2.0;
const _kButtonHeight = 56.0;
const _kButtonBorderRadius = BorderRadius.all(Radius.circular(4.0));

enum CalculatorOperator {
  add('+'),
  subtract('-'),
  multiply('×'), // \u00D7
  divide('÷');

  final String symbol;

  const CalculatorOperator(this.symbol);

  @override
  String toString() => symbol;

  // static CalculatorOperator? fromString(String symbol) {
  //   return switch (symbol) {
  //     '+' => CalculatorOperator.add,
  //     '-' => CalculatorOperator.subtract,
  //     '*' || 'x' || 'X' => CalculatorOperator.multiply,
  //     '/' || '÷' => CalculatorOperator.divide,
  //     _ => null,
  //   };
  // }

  double apply(double a, double b) {
    return switch (this) {
      add => a + b,
      subtract => a - b,
      multiply => a * b,
      divide => a / b,
    };
  }
}

extension CalculatorExtensions on String {
  /// Check if the string contains decimal
  bool get hasDecimal => contains('.');

  /// Check if the string is zero or empty
  bool get isZeroOrEmpty => isEmpty || this == '0';

  /// Check if the string is neither zero nor empty
  bool get isNotZeroOrEmpty => !isZeroOrEmpty;
}

class CalculatorExpression extends Equatable {
  const CalculatorExpression({this.left, this.operator, this.right});

  final String? left;
  final CalculatorOperator? operator;
  final String? right;

  @override
  String toString() {
    if (operator == null) return right ?? '';
    return '${left ?? '0'} $operator ${right ?? ''}';
  }

  @override
  List<Object?> get props => [left, operator, right];

  CalculatorExpression copyWith({
    String? Function()? left,
    CalculatorOperator? Function()? operator,
    String? Function()? right,
  }) {
    return CalculatorExpression(
      left: left != null ? left.call() : this.left,
      operator: operator != null ? operator.call() : this.operator,
      right: right != null ? right.call() : this.right,
    );
  }
}

class InveslyCalculatorWidget extends StatefulWidget {
  const InveslyCalculatorWidget({super.key, this.initialAmount, this.onPressed, this.onConfirm});

  final num? initialAmount;

  /// Callback when the expression changes. It will return the left operand, operator,
  /// right operand and the result of the calculation.
  final void Function(CalculatorExpression? expression, num? result)? onPressed;

  /// Callback when the result is confirmed. It will return the result of the calculation.
  final ValueChanged<num?>? onConfirm;

  static Future<num?> showModal(BuildContext context, [num? initialAmount]) async {
    return await showModalBottomSheet<num>(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: _InveslyCalculatorWidgetWithResult(
            initialAmount: initialAmount,
            onConfirm: (value) => Navigator.maybePop<num>(context, value),
          ),
        );
      },
    );
  }

  @override
  State<InveslyCalculatorWidget> createState() => _InveslyCalculatorWidgetState();
}

class _InveslyCalculatorWidgetState extends State<InveslyCalculatorWidget> {
  // final FocusNode _focusNode = FocusNode();
  // late FocusAttachment _focusAttachment;

  late final ValueNotifier<String?> _leftOperand;
  late final ValueNotifier<String?> _rightOperand;
  late final ValueNotifier<CalculatorOperator?> _operator;
  final ValueNotifier<CalculatorExpression> _expression = ValueNotifier(CalculatorExpression());

  @override
  void initState() {
    super.initState();
    _leftOperand = ValueNotifier(null)..addListener(_handleExpressionChanged);
    _rightOperand = ValueNotifier(widget.initialAmount?.toString())..addListener(_handleExpressionChanged);
    _operator = ValueNotifier(null)..addListener(_handleExpressionChanged);

    // _focusAttachment = _focusNode.attach(
    //   context,
    //   onKeyEvent: (node, event) {
    //     bool keyIsPressed = event is KeyDownEvent || event is KeyRepeatEvent;

    //     if (!keyIsPressed) {
    //       return KeyEventResult.handled;
    //     }

    //     final key = event.logicalKey;
    //     if ([
    //       LogicalKeyboardKey.digit0,
    //       LogicalKeyboardKey.digit1,
    //       LogicalKeyboardKey.digit2,
    //       LogicalKeyboardKey.digit3,
    //       LogicalKeyboardKey.digit4,
    //       LogicalKeyboardKey.digit5,
    //       LogicalKeyboardKey.digit6,
    //       LogicalKeyboardKey.digit7,
    //       LogicalKeyboardKey.digit8,
    //       LogicalKeyboardKey.digit9,
    //       LogicalKeyboardKey.numpad0,
    //       LogicalKeyboardKey.numpad1,
    //       LogicalKeyboardKey.numpad2,
    //       LogicalKeyboardKey.numpad3,
    //       LogicalKeyboardKey.numpad4,
    //       LogicalKeyboardKey.numpad5,
    //       LogicalKeyboardKey.numpad6,
    //       LogicalKeyboardKey.numpad7,
    //       LogicalKeyboardKey.numpad8,
    //       LogicalKeyboardKey.numpad9,
    //     ].contains(key)) {
    //       final number = int.tryParse(key.keyLabel);
    //       if (number != null) {
    //         cubit.handleNumberPressed(number);
    //       }
    //     } else if ([
    //       LogicalKeyboardKey.add,
    //       LogicalKeyboardKey.numpadAdd,
    //       LogicalKeyboardKey.minus,
    //       LogicalKeyboardKey.numpadSubtract,
    //       LogicalKeyboardKey.numpadMultiply,
    //       LogicalKeyboardKey.slash,
    //       LogicalKeyboardKey.numpadDivide,
    //     ].contains(key)) {
    //       final operator = CalculatorOperator.fromString(key.keyLabel);
    //       if (operator != null) {
    //         handleOperatorPressed(operator);
    //       }
    //     } else if ([
    //       LogicalKeyboardKey.period,
    //       LogicalKeyboardKey.numpadDecimal,
    //       LogicalKeyboardKey.comma,
    //     ].contains(key)) {
    //       handleDecimalPressed();
    //     } else if (key == LogicalKeyboardKey.backspace) {
    //       handleBackspacePressed();
    //     } else if (key == LogicalKeyboardKey.delete) {
    //       handleClearPressed();
    //     } else if (key == LogicalKeyboardKey.enter) {
    //       calculate();
    //     }

    //     return KeyEventResult.handled;
    //   },
    // );

    // _focusNode.requestFocus();
  }

  void _setLeftOperand([String? value]) {
    _leftOperand.value = value;
  }

  void _setRightOperand([String? value]) {
    _rightOperand.value = value;
  }

  void _setOperator([CalculatorOperator? value]) {
    _operator.value = value;
  }

  String? get _left => _leftOperand.value?.trim();
  String? get _right => _rightOperand.value?.trim();

  /// Handle number (0-9) pressed
  /// If the expression has only zero, whole expression will be replaced, (only if the number tapped is not zero)
  /// For all other cases, the number tapped will be appended
  void _handleNumberPressed(int number) {
    String? right = _right;
    if (right == null || right == '0') {
      if (number == 0) return;

      right = '';
    }
    _setRightOperand('$right$number');

    // Expression approach
    _expression.value = _expression.value.copyWith(right: () => '$right$number');
  }

  /// Handle decimal (.) pressed.
  /// If the expression has a decimal, nothing will happen.
  /// If the expression is empty, a '0' will be prefixed
  void _handleDecimalPressed() {
    String? right = _right;
    if (right?.hasDecimal == true) return;

    if (right?.isEmpty == true) {
      right = '0';
    }
    _setRightOperand('$right.');
  }

  /// Handle operator (+, -, ×, ÷) pressed.
  /// Existing operator will be replaced with the new one.
  /// Left operand will be calculated (only if right operand is not empty).
  /// Right operand be set to empty.
  void _handleOperatorPressed(CalculatorOperator operator) {
    String? left = _left;
    if (_right?.isZeroOrEmpty == true) {
      if (left?.isZeroOrEmpty == true) left = '0';
    } else {
      if (left?.isZeroOrEmpty == true) {
        left = _right;
      } else {
        left = _result.toString();
      }
    }
    _setLeftOperand(left);
    _setRightOperand();
    _setOperator(operator);
  }

  /// Handle clearing screen
  void _handleClearPressed() {
    _setLeftOperand();
    _setRightOperand();
    _setOperator();
  }

  /// Handle backspace (delete last character)
  void handleBackspacePressed() {
    String? right = _right;
    if (right?.isEmpty == true) return;
    right = right?.substring(0, right.length - 1);
    _setRightOperand(right?.isEmpty == true ? '0' : right);
  }

  /// Handle percentage pressed
  void handlePercentagePressed() {}

  /// Calculate or Submit result
  void _calculate() {
    if (_left?.isEmpty == true || _operator.value == null) return;

    _setLeftOperand();
    _setRightOperand('$_result');
    _setOperator();

    widget.onConfirm?.call(_result);
  }

  double get _result {
    final right = _right != null ? double.tryParse(_right!) : null;
    if (_operator.value == null) return right ?? 0.0;

    final left = _left != null ? double.tryParse(_left!) : null;
    return _operator.value!.apply(left ?? 0.0, right ?? 0.0);
  }

  void _handleExpressionChanged() {
    final expression = CalculatorExpression(left: _left, right: _right, operator: _operator.value);
    widget.onPressed?.call(expression, _result);
  }

  @override
  void dispose() {
    _leftOperand.dispose();
    _rightOperand.dispose();
    _operator.dispose();
    // _focusAttachment.detach();
    // _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;

    return TextFieldTapRegion(
      child: Column(
        spacing: _kButtonSpacing,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            spacing: _kButtonSpacing,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // ~ All clear
              _CalculatorButton(
                onPressed: _handleClearPressed,
                label: 'AC',
                textColor: themeColor.onErrorContainer,
                bgColor: themeColor.errorContainer,
                borderRadius: _kButtonBorderRadius.copyWith(topLeft: iButtonBorderRadius.topLeft),
              ),

              // ~ Clear
              _CalculatorButton(
                onPressed: handleBackspacePressed,
                icon: const Icon(Icons.backspace_rounded),
                textColor: themeColor.onErrorContainer,
                bgColor: themeColor.errorContainer,
              ),

              // ~ Percentage
              _CalculatorButton(onPressed: handlePercentagePressed, label: '%'),

              // ~ Add
              _CalculatorButton(
                onPressed: () => _handleOperatorPressed(CalculatorOperator.add),
                label: CalculatorOperator.add.symbol,
                textColor: themeColor.onSecondary,
                bgColor: themeColor.secondary,
                borderRadius: _kButtonBorderRadius.copyWith(topRight: iButtonBorderRadius.topRight),
              ),
            ],
          ),

          Row(
            spacing: _kButtonSpacing,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // ~ Digit 1
              _CalculatorButton(onPressed: () => _handleNumberPressed(1), label: '1'),

              // ~ Digit 2
              _CalculatorButton(onPressed: () => _handleNumberPressed(2), label: '2'),

              // ~ Digit 3
              _CalculatorButton(onPressed: () => _handleNumberPressed(3), label: '3'),

              // ~ Subtract
              _CalculatorButton(
                onPressed: () => _handleOperatorPressed(CalculatorOperator.subtract),
                label: CalculatorOperator.subtract.symbol,
                textColor: themeColor.onSecondary,
                bgColor: themeColor.secondary,
              ),
            ],
          ),

          Row(
            spacing: _kButtonSpacing,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // ~ Digit 4
              _CalculatorButton(onPressed: () => _handleNumberPressed(4), label: '4'),

              // ~ Digit 5
              _CalculatorButton(onPressed: () => _handleNumberPressed(5), label: '5'),

              // ~ Digit 6
              _CalculatorButton(onPressed: () => _handleNumberPressed(6), label: '6'),

              // ~ Multiplication
              _CalculatorButton(
                onPressed: () => _handleOperatorPressed(CalculatorOperator.multiply),
                label: CalculatorOperator.multiply.symbol,
                textColor: themeColor.onSecondary,
                bgColor: themeColor.secondary,
              ),
            ],
          ),

          Row(
            spacing: _kButtonSpacing,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // ~ Digit 7
              _CalculatorButton(onPressed: () => _handleNumberPressed(7), label: '7'),

              // ~ Digit 8
              _CalculatorButton(onPressed: () => _handleNumberPressed(8), label: '8'),

              // ~ Digit 9
              _CalculatorButton(onPressed: () => _handleNumberPressed(9), label: '9'),

              // ~ Divide
              _CalculatorButton(
                onPressed: () => _handleOperatorPressed(CalculatorOperator.divide),
                label: CalculatorOperator.divide.symbol,
                textColor: themeColor.onSecondary,
                bgColor: themeColor.secondary,
              ),
            ],
          ),

          Row(
            spacing: _kButtonSpacing,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // ~ Decimal
              ValueListenableBuilder<String?>(
                valueListenable: _rightOperand,
                builder: (context, right, _) {
                  return _CalculatorButton(
                    disabled: right?.hasDecimal ?? false,
                    onPressed: () => _handleDecimalPressed(),
                    label: '.',
                    borderRadius: _kButtonBorderRadius.copyWith(bottomLeft: iButtonBorderRadius.bottomLeft),
                  );
                },
              ),

              // ~ Digit 0
              _CalculatorButton(onPressed: () => _handleNumberPressed(0), label: '0'),

              // ~ Equal
              ValueListenableBuilder(
                valueListenable: _leftOperand,
                builder: (context, left, _) {
                  return _CalculatorButton(
                    onPressed: _calculate,
                    label: left == null ? null : '=',
                    icon: left == null ? Icon(Icons.check_rounded) : null,
                    flex: 2,
                    textColor: themeColor.onPrimary,
                    bgColor: themeColor.primary,
                    borderRadius: _kButtonBorderRadius.copyWith(bottomRight: iButtonBorderRadius.bottomRight),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

///
class _InveslyCalculatorWidgetWithResult extends StatefulWidget {
  const _InveslyCalculatorWidgetWithResult({super.key, this.initialAmount, this.onConfirm});

  final num? initialAmount;

  /// Callback when the result is confirmed. It will return the result of the calculation.
  final ValueChanged<num>? onConfirm;

  @override
  State<_InveslyCalculatorWidgetWithResult> createState() => __InveslyCalculatorWidgetWithResultState();
}

class __InveslyCalculatorWidgetWithResultState extends State<_InveslyCalculatorWidgetWithResult> {
  late final ValueNotifier<String?> _leftOperand;
  late final ValueNotifier<String?> _rightOperand;
  late final ValueNotifier<CalculatorOperator?> _operator;

  @override
  void initState() {
    super.initState();
    _leftOperand = ValueNotifier(null);
    _rightOperand = ValueNotifier(widget.initialAmount?.toString());
    _operator = ValueNotifier(null);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // ~ Result
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              spacing: 4.0,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                SizedBox(
                  height: 30.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 4.0,
                    children: <Widget>[
                      ValueListenableBuilder<String?>(
                        valueListenable: _leftOperand,
                        builder: (_, leftOperandValue, _) {
                          return Text(
                            leftOperandValue ?? '',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
                          );
                        },
                      ),
                      ValueListenableBuilder<CalculatorOperator?>(
                        valueListenable: _operator,
                        builder: (_, operatorValue, _) {
                          return Text(
                            operatorValue?.symbol ?? '',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                ValueListenableBuilder<String?>(
                  valueListenable: _rightOperand,
                  builder: (_, rightOperandValue, _) {
                    return _NumberDisplayer(rightOperandValue ?? '0');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),
          const Divider(),

          // ~ Calculator buttons
          InveslyCalculatorWidget(
            onPressed: (expr, result) {
              _leftOperand.value = expr?.left;
              _rightOperand.value = expr?.right;
              _operator.value = expr?.operator;
            },
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
  final double height;

  const _CalculatorButton({
    this.flex = 1,
    this.label,
    this.icon,
    required this.onPressed,
    this.textColor,
    this.bgColor,
    this.disabled = false,
    this.borderRadius = _kButtonBorderRadius,
    this.height = _kButtonHeight,
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
          fixedSize: WidgetStateProperty.all(Size.fromHeight(height)),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.disabled)) {
              return bgColor?.withAlpha(100) ?? theme.disabledColor;
            }
            return bgColor ?? theme.colorScheme.secondaryContainer;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.disabled)) {
              return textColor?.withAlpha(200) ?? Colors.black38;
            }
            return textColor ?? theme.colorScheme.onSecondaryContainer;
          }),
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: borderRadius)),
        ),
        child: child,
      ),
    );
  }
}

/// Display amount in decorated manners
class _NumberDisplayer extends StatelessWidget {
  const _NumberDisplayer(this.amount, [this.format]);

  final String amount;
  final RegExp? format;

  @override
  Widget build(BuildContext context) {
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
