// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:invesly/common/extensions/num_extension.dart';
// // import 'package:expressions/expressions.dart';
// import 'package:intl/intl.dart';

// class InveslyCalculatorWidget extends StatefulWidget {
//   const InveslyCalculatorWidget({super.key, required this.initialAmount, this.onSubmit});

//   final double initialAmount;
//   final ValueChanged<double>? onSubmit;

//   @override
//   State<InveslyCalculatorWidget> createState() => _InveslyCalculatorWidgetState();

//   static Future<double?> showCalculatorModalWidget(BuildContext context) async {
//     return await showModalBottomSheet<double>(
//       context: context,
//       showDragHandle: true,
//       // enableDrag: false,
//       // isScrollControlled: true,
//       builder: (context) {
//         return InveslyCalculatorWidget(
//           initialAmount: 7.8465,
//           onSubmit: (value) => Navigator.maybePop<double>(context, value),
//         );
//       },
//     );
//   }
// }

// class _InveslyCalculatorWidgetState extends State<InveslyCalculatorWidget> {
//   late String amountString;
//   late final ValueNotifier<String> _expression;
//   late final ValueNotifier<double> _result;

//   final FocusNode _focusNode = FocusNode();
//   late FocusAttachment _focusAttachment;

//   @override
//   void initState() {
//     super.initState();
//     final initialAmount = widget.initialAmount.toPrecision(2);
//     _expression = ValueNotifier<String>(initialAmount.toString());
//     _result = ValueNotifier<double>(initialAmount);

//     _focusAttachment = _focusNode.attach(
//       context,
//       onKeyEvent: (node, event) {
//         bool keyIsPressed = event is KeyDownEvent || event is KeyRepeatEvent;

//         if (!keyIsPressed) {
//           return KeyEventResult.handled;
//         }

//         final key = event.logicalKey;
//         if ([
//           LogicalKeyboardKey.digit0,
//           LogicalKeyboardKey.digit1,
//           LogicalKeyboardKey.digit2,
//           LogicalKeyboardKey.digit3,
//           LogicalKeyboardKey.digit4,
//           LogicalKeyboardKey.digit5,
//           LogicalKeyboardKey.digit6,
//           LogicalKeyboardKey.digit7,
//           LogicalKeyboardKey.digit8,
//           LogicalKeyboardKey.digit9,
//           LogicalKeyboardKey.numpad0,
//           LogicalKeyboardKey.numpad1,
//           LogicalKeyboardKey.numpad2,
//           LogicalKeyboardKey.numpad3,
//           LogicalKeyboardKey.numpad4,
//           LogicalKeyboardKey.numpad5,
//           LogicalKeyboardKey.numpad6,
//           LogicalKeyboardKey.numpad7,
//           LogicalKeyboardKey.numpad8,
//           LogicalKeyboardKey.numpad9,
//         ].contains(key)) {
//           final number = int.tryParse(key.keyLabel);
//           if (number != null) {
//             handleNumber(number);
//           }
//         } else if ([
//           LogicalKeyboardKey.add,
//           LogicalKeyboardKey.numpadAdd,
//           LogicalKeyboardKey.minus,
//           LogicalKeyboardKey.numpadSubtract,
//           LogicalKeyboardKey.numpadMultiply,
//           LogicalKeyboardKey.slash,
//           LogicalKeyboardKey.numpadDivide,
//         ].contains(key)) {
//           final operator = CalculatorOperator.fromString(key.keyLabel);
//           if (operator != null) {
//             handleOperator(operator);
//           }
//         } else if ([
//           LogicalKeyboardKey.period,
//           LogicalKeyboardKey.numpadDecimal,
//           LogicalKeyboardKey.comma,
//         ].contains(key)) {
//           handleDecimal();
//         } else if (key == LogicalKeyboardKey.backspace) {
//           handleBackspace();
//         } else if (key == LogicalKeyboardKey.delete) {
//           handleClear();
//         } else if (key == LogicalKeyboardKey.enter) {
//           submitAmount();
//         }

//         return KeyEventResult.handled;
//       },
//     );

//     _focusNode.requestFocus();
//   }

//   @override
//   void dispose() {
//     _expression.dispose();
//     _result.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }

//   String get expression => _expression.value.trim();
//   String? get lastChar => _expression.value.isEmpty ? null : _expression.value[_expression.value.length - 1];

//   double get valueToNumber {
//     if (amountString.trim() == '') {
//       return 0;
//     } else if (amountString.trim() == '-' || amountString.trim() == '-0') {
//       return -0;
//     }

//     return evaluateExpression(amountString).toPrecision(2);
//   }

//   double evaluateExpression(String expression) {
//     // Remove any whitespace from the input string
//     expression = expression.replaceAll(' ', '');

//     // Handle negative sign at the start of the expression
//     if (expression.startsWith('-')) {
//       expression = '0$expression'; // Prepend 0 to allow for correct parsing, e.g., "-3+4" becomes "0-3+4"
//     }

//     // Ignore trailing operators by removing them if present
//     while (expression.isNotEmpty && CalculatorOperator.fromString(expression[expression.length - 1]) != null) {
//       expression = expression.substring(0, expression.length - 1);
//     }

//     if (expression.isEmpty) {
//       throw ArgumentError('Invalid expression: no numbers found.');
//     }

//     final tokens = splitExprByNumbersAndOperator(expression);

//     List<String> postfix = _infixToPostfix(tokens);
//     return _evaluatePostfix(postfix);
//   }

//   List<String> get splitExprByOperator {
//     if (expression.isEmpty) return [];

//     final operators = CalculatorOperator.getAllSymbols().join("|\\");
//     // ignore: prefer_interpolation_to_compose_strings
//     return expression.split(r'' + operators + '');
//   }

//   List<String> get lastNumberOfExpression {
//     if (expression.isEmpty) return [];

//     final operators = CalculatorOperator.getAllSymbols().join("|\\");
//     // ignore: prefer_interpolation_to_compose_strings
//     return expression.split(r'' + operators + '');
//   }

//   List<String> splitExprByNumbersAndOperator(String expression) {
//     final operators = CalculatorOperator.getAllSymbols().join("|\\");
//     // ignore: prefer_interpolation_to_compose_strings
//     return RegExp(r'(\d+\.?\d*|\' + operators + ')').allMatches(expression).map((m) => m.group(0)!).toList();
//   }

//   bool currentNumberHasDecimal() {
//     final exprSplit = splitExprByOperator;

//     if (exprSplit.isEmpty) {
//       return false;
//     }

//     return exprSplit.last.contains('.');
//   }

//   void setExpression(String value) {
//     _expression.value = value;
//   }

//   /// Wrap the expression with -( .. ) // TODO: Correct this
//   void handleToggleSign() {
//     _expression.value = '-(${_expression.value})';
//     // evaluateExpression();
//   }

//   /// Handle number (0-9) pressed
//   /// If the expression has only zero, whole expression will be replaced, (only if the number tapped is not zero)
//   /// For all other cases, the number tapped will be appended
//   void handleNumber(int number) {
//     if (expression.isEmpty) {
//       setExpression(number.toString());
//       return;
//     }

//     // final newText = number.toString();

//     final lastNum = splitExprByOperator.last;
//     if (splitExpr.isEmpty) {
//       amountString = newText;
//     } else {
//       amountString = splitExpr.last;
//     }

//     if (amountString.isEmpty || amountString == CalculatorOperator.subtract.symbol) {
//       if (number == 0) {
//         return;
//       } else {
//         final sign = valueToNumber.isNegative ? '-' : '';

//         amountString = '$sign$newText';
//       }
//     } else if (CalculatorOperator.exprEndsWithOperator(amountString)) {
//       amountString += newText;
//     } else {
//       amountString += newText;
//     }
//     //   if (hasOnlyZero) {
//     //     if (number == _Symbol.zero.val) return;
//     //     expression = expression.substring(0, expression.length - 1);
//     //   }
//     //   expression += number;

//     //   evaluteExpression();
//   }

//   /// Handle decimal (.) pressed.
//   /// If the expression has a decimal i.e. the expression ends with a decimal (e.g. 12346.),
//   /// or if the expression from an operator (e.g. 12345.53 + 56.95) has decimal, nothing will happen.
//   /// If the expression is empty or ends with an operator, a '0' will be prefixed before decimal
//   void handleDecimal() {
//     if (currentNumberHasDecimal()) return;

//     if (_expression.value.isEmpty || CalculatorOperator.exprEndsWithOperator(_expression.value)) {
//       _expression.value += '0.';
//     } else {
//       _expression.value += '.';
//     }
//   }

//   /// Handle operator (+, -, ×, ÷) pressed.
//   /// If the expression is empty, a '0' will be prefixed (except for the new operator is minus)
//   /// If the expression's last character is itself an operator, it will be replaced.
//   void handleOperator(CalculatorOperator operator) {
//     if (_expression.value.isEmpty && operator != CalculatorOperator.subtract) {
//       _expression.value = '0${operator.symbol}';
//     } else {
//       if (CalculatorOperator.exprEndsWithOperator(_expression.value)) {
//         _expression.value = _expression.value.substring(0, _expression.value.length - 1);
//       }
//       _expression.value += operator.symbol;
//     }
//   }

//   void addToAmount(String newText) {
//     final newInputIsOperator = CalculatorOperator.isOperator(newText);

//     setNewAmount(String newSelectedAmount) {
//       setState(() => amountString = newSelectedAmount);
//     }

//     if (valueToNumber != 0 &&
//         double.tryParse(newText) != null &&
//         currentNumberHasDecimal() &&
//         !CalculatorOperator.exprHasOperator(amountString)) {
//       final decimalPlaces = splitExprByNumbersAndOperator(amountString).last.split('.').elementAtOrNull(1);

//       if (decimalPlaces != null && decimalPlaces.length >= 2) {
//         return;
//       }

//       // Pass
//     }

//     if (amountString.isEmpty || amountString == CalculatorOperator.subtract.symbol) {
//       if (newText == '0') {
//         return;
//       } else if (newText == '.') {
//         if (valueToNumber.isNegative) {
//           setNewAmount('-0.');
//         } else {
//           setNewAmount('0.');
//         }
//       } else if (newInputIsOperator) {
//         setNewAmount('0$newText');
//       } else {
//         final sign = valueToNumber.isNegative ? '-' : '';

//         setNewAmount('$sign$newText');
//       }
//     } else if (CalculatorOperator.exprEndsWithOperator(amountString)) {
//       if (newText == '.') {
//         setNewAmount('${amountString}0.');
//       } else if (newInputIsOperator) {
//         // Replace last operator:
//         setNewAmount(amountString.substring(0, amountString.length - 1) + newText);
//       } else {
//         setNewAmount(amountString + newText);
//       }
//     } else {
//       setNewAmount(amountString + newText);
//     }
//   }

//   /// Handle clearing screen
//   void handleClear() {
//     _expression.value = '0';
//     _result.value = 0;
//   }

//   /// Handle backspace (delete last character)
//   void handleBackspace() {
//     if (_expression.value.isEmpty || _expression.value == CalculatorOperator.subtract.symbol) {
//       return;
//     }
//     if (_expression.value.length == 1) {
//       handleClear();
//       return;
//     }

//     _expression.value = _expression.value.substring(0, _expression.value.length - 1);
//     // evaluteExpression();
//   }

//   /// Submit result
//   void submitAmount() {
//     widget.onSubmit?.call(_result.value);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     _focusAttachment.reparent();

//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
//             child: Column(
//               children: <Widget>[
//                 // ~ Amount
//                 ValueListenableBuilder<double>(valueListenable: _result, builder: (_, value, __) => _Amount(value)),
//                 const SizedBox(height: 8.0),
//                 // ~ Expression
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
//                   child: ValueListenableBuilder<String>(
//                     valueListenable: _expression,
//                     builder: (_, data, __) => Text(data, textAlign: TextAlign.right),
//                   ),
//                 ),
//               ],
//             ),
//             // child: CurrencyDisplayer(
//             //   amountToConvert: valueToNumber,
//             //   currency: widget.currency,
//             //   followPrivateMode: false,
//             //   decimalsStyle: TextStyle(
//             //     fontWeight: FontWeight.w200,
//             //     fontSize: 22,
//             //     color: amountString.contains('.') ? null : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
//             //   ),
//             //   integerStyle: bigSizeStyle,
//             //   currencyStyle: bigSizeStyle,
//             // ),
//           ),
//           const SizedBox(height: 12.0),
//           const Divider(),

//           // ~ Buttons
//           Flexible(
//             child: Container(
//               margin: const EdgeInsets.only(top: 16),
//               decoration: const BoxDecoration(
//                 borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       mainAxisSize: MainAxisSize.min,
//                       children: <Widget>[
//                         _CalculatorButton(
//                           onPressed: () => handleOperator(CalculatorOperator.multiply),
//                           label: CalculatorOperator.multiply.symbol,
//                           textColor: theme.colorScheme.primary,
//                           bgColor: theme.colorScheme.primary.withAlpha(25),
//                         ),
//                         _CalculatorButton(onPressed: () => addToAmount('1'), label: '1'),
//                         _CalculatorButton(onPressed: () => addToAmount('4'), label: '4'),
//                         _CalculatorButton(onPressed: () => addToAmount('7'), label: '7'),
//                         _CalculatorButton(onPressed: () => addToAmount('0'), label: '0'),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       mainAxisSize: MainAxisSize.min,
//                       children: <Widget>[
//                         _CalculatorButton(
//                           onPressed: () => handleOperator(CalculatorOperator.divide),
//                           label: CalculatorOperator.divide.symbol,
//                           textColor: theme.colorScheme.primary,
//                           bgColor: theme.colorScheme.primary.withAlpha(25),
//                         ),
//                         _CalculatorButton(onPressed: () => addToAmount('2'), label: '2'),
//                         _CalculatorButton(onPressed: () => addToAmount('5'), label: '5'),
//                         _CalculatorButton(onPressed: () => addToAmount('8'), label: '8'),
//                         _CalculatorButton(
//                           // disabled: _currentNumberHasDecimal(),
//                           onPressed: handleDecimal,
//                           label: '.',
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         _CalculatorButton(
//                           onPressed: () => handleOperator(CalculatorOperator.subtract),
//                           label: CalculatorOperator.subtract.symbol,
//                           textColor: theme.colorScheme.primary,
//                           bgColor: theme.colorScheme.primary.withAlpha(25),
//                         ),
//                         _CalculatorButton(onPressed: () => addToAmount('3'), label: '3'),
//                         _CalculatorButton(onPressed: () => addToAmount('6'), label: '6'),
//                         _CalculatorButton(onPressed: () => addToAmount('9'), label: '9'),
//                         _CalculatorButton(
//                           onPressed: handleClear,
//                           label: 'AC',
//                           textColor: theme.colorScheme.error,
//                           bgColor: theme.colorScheme.error.withAlpha(25),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         _CalculatorButton(
//                           onPressed: () => handleOperator(CalculatorOperator.add),
//                           label: CalculatorOperator.add.symbol,
//                           textColor: theme.colorScheme.primary,
//                           bgColor: theme.colorScheme.primary.withAlpha(25),
//                         ),
//                         _CalculatorButton(
//                           onPressed: handleBackspace,
//                           icon: const Icon(Icons.backspace_rounded),
//                           textColor: theme.colorScheme.error,
//                           bgColor: theme.colorScheme.error.withAlpha(25),
//                         ),
//                         _CalculatorButton(onPressed: handleToggleSign, icon: Icon(Icons.exposure_rounded)),
//                         _CalculatorButton(
//                           // disabled: valueToNumber == 0 || valueToNumber.isInfinite || valueToNumber.isNaN,
//                           onPressed: submitAmount,
//                           icon: Icon(Icons.check_rounded),
//                           flex: 2,
//                           textColor: theme.colorScheme.secondary,
//                           bgColor: theme.colorScheme.secondary.withAlpha(75),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _CalculatorButton extends StatelessWidget {
//   final String? label;
//   final Widget? icon;
//   final Color? textColor;
//   final Color? bgColor;
//   final VoidCallback? onPressed;
//   final int flex;

//   const _CalculatorButton({this.flex = 1, this.label, this.icon, required this.onPressed, this.textColor, this.bgColor})
//     : assert(icon != null, "Either label or icon has to be assigned"),
//       assert(label == null || icon == null, "Both label and icon can't be assigned");

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final child = icon ?? Text(label!);

//     return Expanded(
//       flex: flex,
//       child: Padding(
//         padding: const EdgeInsets.all(4.0),
//         child: TextButton(
//           onPressed: onPressed,
//           style: TextButton.styleFrom(
//             fixedSize: const Size.fromHeight(64.0),
//             backgroundColor: bgColor ?? Colors.transparent,
//             foregroundColor: textColor ?? theme.colorScheme.onSurface,
//             shape: RoundedRectangleBorder(
//               side: BorderSide(color: textColor ?? Colors.black),
//               borderRadius: BorderRadius.circular(16.0),
//             ),
//           ),
//           child: child,
//         ),
//       ),
//     );
//   }
// }

// final _currencyFormat = NumberFormat.simpleCurrency();

// /// Display amount in decorated manners
// class _Amount extends StatelessWidget {
//   const _Amount(this.amount, [this.format]);

//   final double amount;
//   final RegExp? format;

//   List<String?>? formatAmount(String data) {
//     final match = format?.firstMatch(data);
//     if (match == null) return null;

//     final List<String?> strings = [];
//     for (int i = 0; i < match.groupCount; i++) {
//       strings.add(match.group(i + 1));
//     }
//     return strings;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme.secondary;
//     final data = _currencyFormat.format(amount);
//     final fData = formatAmount(data);

//     if (fData == null) {
//       return Text(data, style: TextStyle(fontSize: 40.0, color: color), maxLines: 1, overflow: TextOverflow.ellipsis);
//     }

//     return Text.rich(
//       TextSpan(
//         text: fData[0] ?? '',
//         style: TextStyle(fontSize: 40.0, color: color.withAlpha(125)),
//         children: <TextSpan>[
//           if (fData.length > 1) TextSpan(text: fData[1] ?? '', style: TextStyle(fontSize: 72.0, color: color)),
//           if (fData.length > 2) TextSpan(text: fData.sublist(2).where((e) => e != null).join()),
//         ],
//       ),
//       maxLines: 1,
//       overflow: TextOverflow.ellipsis,
//     );
//   }
// }

// enum CalculatorOperator {
//   add('+'),
//   subtract('-'),
//   multiply('x'),
//   divide('÷');

//   final String symbol;

//   const CalculatorOperator(this.symbol);

//   @override
//   String toString() => symbol;

//   static CalculatorOperator? fromString(String symbol) {
//     switch (symbol) {
//       case '+':
//         return CalculatorOperator.add;
//       case '-':
//         return CalculatorOperator.subtract;
//       case '*' || 'x' || 'X':
//         return CalculatorOperator.multiply;
//       case '/' || '÷':
//         return CalculatorOperator.divide;
//       default:
//         return null;
//     }
//   }

//   double apply(double a, double b) {
//     switch (this) {
//       case CalculatorOperator.add:
//         return a + b;
//       case CalculatorOperator.subtract:
//         return a - b;
//       case CalculatorOperator.multiply:
//         return a * b;
//       case CalculatorOperator.divide:
//         return a / b;
//     }
//   }

//   static bool exprHasOperator(String expression) {
//     expression = expression.trim();

//     for (int i = 1; i < expression.length; i++) {
//       // Start by zero to avoid returning true when the first number is negative
//       final char = expression[i];
//       if (CalculatorOperator.fromString(char) != null) {
//         return true;
//       }
//     }

//     return false;
//   }

//   static bool isOperator(String char) {
//     if (char.length > 1) {
//       throw ArgumentError("Character can not have this legth");
//     }

//     return CalculatorOperator.fromString(char) != null;
//   }

//   static bool exprEndsWithOperator(String expression) {
//     if (expression.isEmpty) {
//       return false;
//     }

//     final lastChar = expression[expression.length - 1];
//     return CalculatorOperator.fromString(lastChar) != null;
//   }

//   static Iterable<String> getAllSymbols() {
//     return values.map((op) => op.symbol);
//   }
// }

// //   void evaluteExpression() {
// //     if (expression.isEmpty || expression == '0') {
// //       result = 0;
// //     } else {
// //       String internal = expression;

// //       // remove end operator, if present
// //       while ((operatorRegExp.hasMatch(internal) || decimalRegExp.hasMatch(internal)) && internal.length > 1) {
// //         internal = internal.substring(0, internal.length - 1);
// //       }

// //       // replace × and ÷ with * and /
// //       internal = internal.replaceAll(_Symbol.times.val, '*').replaceAll(_Symbol.divide.val, '/');

// //       // replace % with multiplication
// //       internal = internal.replaceAll('%', '*0.01');

// //       try {
// //         Expression expr = Expression.parse(internal);
// //         final r = evaluator.eval(expr, {});
// //         if (r is int) {
// //           result = r.toDouble();
// //         } else if (r is double) {
// //           result = r;
// //         }
// //       } on Exception catch (e) {
// //         $logger.e(e);
// //       }
// //     }

// //     widget.onUpdate(expression, result);
// //   }

// List<String> _infixToPostfix(List<String> tokens) {
//   final precedence = {
//     CalculatorOperator.add: 1,
//     CalculatorOperator.subtract: 1,
//     CalculatorOperator.multiply: 2,
//     CalculatorOperator.divide: 2,
//   };
//   final operators = <CalculatorOperator>[];
//   final output = <String>[];

//   for (int i = 0; i < tokens.length; i++) {
//     final token = tokens[i];
//     final op = CalculatorOperator.fromString(token);

//     if (double.tryParse(token) != null) {
//       // If the token is a number, add it to the output
//       output.add(token);
//     } else if (op != null) {
//       // While the top of the operator stack has the same or greater precedence
//       while (operators.isNotEmpty && precedence[operators.last]! >= precedence[op]!) {
//         output.add(operators.removeLast().toString());
//       }
//       // Push the current operator to the stack
//       operators.add(op);
//     }
//   }

//   // Pop any remaining operators onto the output
//   while (operators.isNotEmpty) {
//     output.add(operators.removeLast().toString());
//   }

//   return output;
// }

// double _evaluatePostfix(List<String> postfix) {
//   final stack = <double>[];

//   for (final token in postfix) {
//     if (double.tryParse(token) != null) {
//       stack.add(double.parse(token));
//     } else {
//       final b = stack.removeLast();
//       final a = stack.removeLast();
//       final op = CalculatorOperator.fromString(token)!;
//       stack.add(op.apply(a, b));
//     }
//   }

//   return stack.last;
// }

// // class _CalculatorKeyboard extends StatefulWidget {
// //   final String? expression;
// //   final double? result;
// //   final void Function(String expression, double result) onUpdate;
// //   final VoidCallback? onConfirm;

// //   const _CalculatorKeyboard({super.key, this.expression, this.result, required this.onUpdate, this.onConfirm});

// //   @override
// //   State<_CalculatorKeyboard> createState() => _CalculatorKeyboardState();
// // }

// // class _CalculatorKeyboardState extends State<_CalculatorKeyboard> {
// //   late double result;
// //   late String expression;
// //   late final ExpressionEvaluator evaluator;

// //   final RegExp decimalRegExp = RegExp(r'\d*\.\d*$');
// //   final RegExp zeroRegExp = RegExp(r'^[^\d.]*0+$');
// //   final RegExp operatorRegExp = RegExp(r'[-+×÷]$');

// //   bool get hasDecimal => decimalRegExp.hasMatch(expression);
// //   bool get hasOnlyZero => zeroRegExp.hasMatch(expression);
// //   bool get lastCharIsOperator => operatorRegExp.hasMatch(expression);
// //   bool get emptyOrOperator => lastCharIsOperator || expression.isEmpty;

// //   @override
// //   void initState() {
// //     super.initState();
// //     result = widget.result ?? 0;
// //     expression = widget.expression ?? '0';
// //     evaluator = const ExpressionEvaluator();
// //   }
// // }
