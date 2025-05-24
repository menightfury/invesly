part of 'calculator_cubit.dart';

class CalculatorState extends Equatable {
  const CalculatorState({this.leftOperand = '', this.rightOperand = '0', this.operator});

  final String leftOperand;
  final String rightOperand;
  final CalculatorOperator? operator;

  CalculatorState copyWith({String? leftOperand, String? rightOperand, CalculatorOperator? operator}) {
    return CalculatorState(
      leftOperand: leftOperand ?? this.leftOperand,
      rightOperand: rightOperand ?? this.rightOperand,
      operator: operator ?? this.operator,
    );
  }

  @override
  List<Object?> get props => [leftOperand, rightOperand, operator];
}

enum CalculatorOperator {
  add('+'),
  subtract('-'),
  multiply('x'),
  divide('÷');

  final String symbol;

  const CalculatorOperator(this.symbol);

  @override
  String toString() => symbol;

  static CalculatorOperator? fromString(String symbol) {
    switch (symbol) {
      case '+':
        return CalculatorOperator.add;
      case '-':
        return CalculatorOperator.subtract;
      case '*' || 'x' || 'X':
        return CalculatorOperator.multiply;
      case '/' || '÷':
        return CalculatorOperator.divide;
      default:
        return null;
    }
  }

  double apply(double a, double b) {
    switch (this) {
      case CalculatorOperator.add:
        return a + b;
      case CalculatorOperator.subtract:
        return a - b;
      case CalculatorOperator.multiply:
        return a * b;
      case CalculatorOperator.divide:
        return a / b;
    }
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
