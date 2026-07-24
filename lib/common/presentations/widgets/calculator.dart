import 'package:intl/intl.dart';
import 'package:invesly/common_libs.dart';

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

class InveslyCalculatorWidget extends StatefulWidget {
  const InveslyCalculatorWidget({super.key, this.initialAmount, this.onPressed, this.onSubmit});

  final num? initialAmount;
  final void Function()? onPressed;
  final ValueChanged<num>? onSubmit;

  static Future<num?> showModal(BuildContext context, [num? initialAmount]) async {
    return await showModalBottomSheet<num>(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: InveslyCalculatorWidget(
            initialAmount: initialAmount,
            onSubmit: (value) => Navigator.maybePop<num>(context, value),
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

  static const _buttonSpacing = 2.0;

  late final ValueNotifier<String> _leftOperand;
  late final ValueNotifier<String> _rightOperand;
  late final ValueNotifier<CalculatorOperator?> _operator;

  static const String _defaultLeftOperand = '';
  static const String _defaultRightOperand = '0';
  static const CalculatorOperator? _defaultOperator = null;

  @override
  void initState() {
    super.initState();
    _leftOperand = ValueNotifier(_defaultLeftOperand);
    _rightOperand = ValueNotifier(_defaultRightOperand);
    _operator = ValueNotifier(_defaultOperator);

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
    // _focusAttachment.reparent();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // ~ Display
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
                    // ~ Left operand
                    ValueListenableBuilder<String>(
                      valueListenable: _leftOperand,
                      builder: (_, leftOperandValue, _) {
                        return Text(
                          leftOperandValue,
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
                        );
                      },
                    ),

                    // ~ Operator
                    ValueListenableBuilder<CalculatorOperator?>(
                      valueListenable: _operator,
                      builder: (_, operatorValue, _) {
                        return Text(
                          operatorValue?.symbol ?? '',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ~ Right operand
              ValueListenableBuilder<String>(
                valueListenable: _rightOperand,
                builder: (_, rightOperandValue, _) {
                  return _NumberDisplayer(rightOperandValue);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12.0),
        const Divider(),

        // ~ Buttons
        Column(
          spacing: _buttonSpacing,
          children: <Widget>[
            Row(
              spacing: _buttonSpacing,
              children: <Widget>[
                _CalculatorButton(
                  onPressed: _handleToggleSignPressed,
                  icon: const Icon(Icons.exposure_rounded),
                  bgColor: themeColor.primary,
                  textColor: themeColor.onPrimary,
                  borderRadius: _kButtonBorderRadius.copyWith(topLeft: iButtonBorderRadius.topLeft),
                ),
                _CalculatorButton(
                  onPressed: handleBackspacePressed,
                  icon: const Icon(Icons.backspace_rounded),
                  textColor: themeColor.onErrorContainer,
                  bgColor: themeColor.errorContainer,
                ),
                _CalculatorButton(
                  onPressed: _handleClearPressed,
                  label: 'AC',
                  textColor: themeColor.onErrorContainer,
                  bgColor: themeColor.errorContainer,
                ),
                _CalculatorButton(
                  onPressed: () => _handleOperatorPressed(CalculatorOperator.divide),
                  label: CalculatorOperator.divide.symbol,
                  textColor: themeColor.onPrimary,
                  bgColor: themeColor.primary,
                  borderRadius: _kButtonBorderRadius.copyWith(topRight: iButtonBorderRadius.topRight),
                ),
              ],
            ),
            Row(
              spacing: _buttonSpacing,
              children: <Widget>[
                _CalculatorButton(onPressed: () => _handleNumberPressed(1), label: '1'),
                _CalculatorButton(onPressed: () => _handleNumberPressed(2), label: '2'),
                _CalculatorButton(onPressed: () => _handleNumberPressed(3), label: '3'),
                _CalculatorButton(
                  onPressed: () => _handleOperatorPressed(CalculatorOperator.multiply),
                  label: CalculatorOperator.multiply.symbol,
                  textColor: themeColor.onPrimary,
                  bgColor: themeColor.primary,
                ),
              ],
            ),
            Row(
              spacing: _buttonSpacing,
              children: <Widget>[
                _CalculatorButton(onPressed: () => _handleNumberPressed(4), label: '4'),
                _CalculatorButton(onPressed: () => _handleNumberPressed(5), label: '5'),
                _CalculatorButton(onPressed: () => _handleNumberPressed(6), label: '6'),
                _CalculatorButton(
                  onPressed: () => _handleOperatorPressed(CalculatorOperator.subtract),
                  label: CalculatorOperator.subtract.symbol,
                  textColor: themeColor.onPrimary,
                  bgColor: themeColor.primary,
                ),
              ],
            ),
            Row(
              spacing: _buttonSpacing,
              children: <Widget>[
                _CalculatorButton(onPressed: () => _handleNumberPressed(7), label: '7'),
                _CalculatorButton(onPressed: () => _handleNumberPressed(8), label: '8'),
                _CalculatorButton(onPressed: () => _handleNumberPressed(9), label: '9'),
                _CalculatorButton(
                  onPressed: () => _handleOperatorPressed(CalculatorOperator.add),
                  label: CalculatorOperator.add.symbol,
                  bgColor: themeColor.primary,
                  textColor: themeColor.onPrimary,
                ),
              ],
            ),
            Row(
              spacing: _buttonSpacing,
              children: <Widget>[
                ValueListenableBuilder<String>(
                  valueListenable: _rightOperand,
                  builder: (context, rightOperandValue, _) {
                    return _CalculatorButton(
                      disabled: rightOperandValue.hasDecimal,
                      onPressed: () => _handleDecimalPressed(),
                      label: '.',
                      borderRadius: _kButtonBorderRadius.copyWith(bottomLeft: iButtonBorderRadius.bottomLeft),
                    );
                  },
                ),
                _CalculatorButton(onPressed: () => _handleNumberPressed(0), label: '0'),
                ListenableBuilder(
                  listenable: Listenable.merge([_leftOperand, _rightOperand, _operator]),
                  builder: (context, _) {
                    debugPrint('Rebuilding submit button');
                    final left = _left, right = _right;
                    return _CalculatorButton(
                      disabled: left.isZeroOrEmpty && right.isZeroOrEmpty,
                      onPressed: () {
                        if (left.isNotZeroOrEmpty && _operator.value != null) {
                          _calculate();
                        }

                        // XOR operation
                        if (left.isZeroOrEmpty ^ right.isZeroOrEmpty) {
                          $logger.w(right);
                          widget.onSubmit?.call(double.tryParse(right) ?? 0.0);
                        }
                      },
                      label: (left.isZeroOrEmpty || right.isZeroOrEmpty) ? null : '=',
                      icon: (left.isZeroOrEmpty || right.isZeroOrEmpty) ? Icon(Icons.check_rounded) : null,
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
      ],
    );
  }

  void _setLeftOperand(String value) {
    _leftOperand.value = value;
  }

  void _resetLeftOperand() {
    _leftOperand.value = _defaultLeftOperand;
  }

  void _setRightOperand(String value) {
    _rightOperand.value = value;
  }

  void _resetRightOperand() {
    _rightOperand.value = _defaultRightOperand;
  }

  void _setOperator(CalculatorOperator value) {
    _operator.value = value;
  }

  void _resetOperator() {
    _operator.value = _defaultOperator;
  }

  String get _left => _leftOperand.value.trim();
  String get _right => _rightOperand.value.trim();

  /// Right operand prefixed with - sign
  void _handleToggleSignPressed() {
    String right = _right;
    if (right.startsWith('-')) {
      _setRightOperand(right.substring(1));
      return;
    }
    _setRightOperand('-$right');
  }

  /// Handle number (0-9) pressed
  /// If the expression has only zero, whole expression will be replaced, (only if the number tapped is not zero)
  /// For all other cases, the number tapped will be appended
  void _handleNumberPressed(int number) {
    String right = _right;
    if (right == '0') {
      if (number == 0) return;

      right = '';
    }
    _setRightOperand('$right$number');
  }

  /// Handle decimal (.) pressed.
  /// If the expression has a decimal, nothing will happen.
  /// If the expression is empty, a '0' will be prefixed
  void _handleDecimalPressed() {
    String right = _right;
    if (right.hasDecimal) return;

    if (right.isEmpty) {
      right = '0';
    }
    _setRightOperand('$right.');
  }

  /// Handle operator (+, -, ×, ÷) pressed.
  /// Existing operator will be replaced with the new one.
  /// Left operand will be calculated (only if right operand is not empty).
  /// Right operand be set to empty.
  void _handleOperatorPressed(CalculatorOperator operator) {
    String left = _left;
    if (_right.isZeroOrEmpty) {
      if (_left.isZeroOrEmpty) left = '0';
    } else {
      if (_left.isZeroOrEmpty) {
        left = _right;
      } else {
        left = _result.toString();
      }
    }
    _setLeftOperand(left);
    _resetRightOperand();
    _setOperator(operator);
  }

  /// Handle clearing screen
  void _handleClearPressed() {
    _resetLeftOperand();
    _resetRightOperand();
    _resetOperator();
  }

  /// Handle backspace (delete last character)
  void handleBackspacePressed() {
    String right = _right;
    if (right.isEmpty) return;
    right = right.substring(0, right.length - 1);
    _setRightOperand(right.isEmpty ? '0' : right);
  }

  /// Calculate or Submit result
  void _calculate() {
    if (_left.isEmpty || _operator.value == null) return;

    _resetLeftOperand();
    _setRightOperand('$_result');
    _resetOperator();
  }

  double get _result {
    final left = double.tryParse(_left) ?? 0.0;
    final right = double.tryParse(_right) ?? 0.0;
    if (_operator.value == null) return right;

    return _operator.value!.apply(left, right);
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
