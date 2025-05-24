import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'calculator_state.dart';

class CalculatorCubit extends Cubit<CalculatorState> {
  CalculatorCubit({this.initialValue}) : super(CalculatorState(rightOperand: initialValue?.toString() ?? '0'));

  final num? initialValue;

  void _setLeftOperand(String value) {
    emit(state.copyWith(leftOperand: value));
  }

  void _setRightOperand(String value) {
    emit(state.copyWith(rightOperand: value));
  }

  void _setOperator(CalculatorOperator operator) {
    emit(state.copyWith(operator: operator));
  }

  String get _left => state.leftOperand.trim();
  String get _right => state.rightOperand.trim();

  /// Right operand preixed with - sign
  void handleToggleSign() {
    if (_right.startsWith('-')) {
      _setRightOperand(_right.substring(1));
      return;
    }
    _setRightOperand('-$_right');
  }

  /// Handle number (0-9) pressed
  /// If the expression has only zero, whole expression will be replaced, (only if the number tapped is not zero)
  /// For all other cases, the number tapped will be appended
  void handleNumber(int number) {
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
  void handleDecimal() {
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
  void handleOperator(CalculatorOperator operator) {
    String left = _left;
    if (_right.isZeroOrEmpty) {
      if (_left.isZeroOrEmpty) left = '0';
    } else {
      if (_left.isZeroOrEmpty) {
        left = _right;
      } else {
        left = result.toString();
      }
    }

    emit(CalculatorState(leftOperand: left, rightOperand: '0', operator: operator));
  }

  /// Handle clearing screen
  void handleClear() {
    emit(state.copyWith(leftOperand: '', rightOperand: '0', operator: null));
  }

  /// Handle backspace (delete last character)
  void handleBackspace() {
    if (_right.isEmpty) return;
    final right = _right.substring(0, _right.length - 1);
    _setRightOperand(right.isEmpty ? '0' : right);
  }

  /// Calculate or Submit result
  void calculateOrSubmit() {
    emit(CalculatorState(leftOperand: '', rightOperand: '$result', operator: null));
  }

  double get result {
    final left = double.tryParse(_left) ?? 0.0;
    final right = double.tryParse(_right) ?? 0.0;
    if (state.operator == null) return 0.0;

    return state.operator!.apply(left, right);
  }

  void clear() {
    emit(CalculatorState());
  }
}
