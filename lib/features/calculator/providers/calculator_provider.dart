import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../history_tape/providers/history_provider.dart';

class CalculatorState {
  final String currentOperand;
  final String previousOperand;
  final String? currentOperator;
  final bool hasError;
  final bool isNewOperand;
  final bool isDevMode;

  CalculatorState({
    required this.currentOperand,
    required this.previousOperand,
    this.currentOperator,
    this.hasError = false,
    this.isNewOperand = false,
    this.isDevMode = false,
  });

  CalculatorState copyWith({
    String? currentOperand,
    String? previousOperand,
    String? currentOperator,
    bool? hasError,
    bool? isNewOperand,
    bool? isDevMode,
  }) {
    return CalculatorState(
      currentOperand: currentOperand ?? this.currentOperand,
      previousOperand: previousOperand ?? this.previousOperand,
      currentOperator: currentOperator ?? this.currentOperator,
      hasError: hasError ?? this.hasError,
      isNewOperand: isNewOperand ?? this.isNewOperand,
      isDevMode: isDevMode ?? this.isDevMode,
    );
  }
}

class CalculatorNotifier extends Notifier<CalculatorState> {
  static const int maxLength = 15;

  @override
  CalculatorState build() {
    return CalculatorState(currentOperand: '0', previousOperand: '');
  }

  void toggleDevMode() {
    state = state.copyWith(isDevMode: !state.isDevMode);
  }

  void appendDigit(String digit) {
    if (state.hasError) clear();

    String newOperand = state.currentOperand;
    if (state.isNewOperand) {
      newOperand = digit;
    } else {
      if (newOperand == '0') {
        newOperand = digit;
      } else {
        if (newOperand.length < maxLength) {
          newOperand += digit;
        }
      }
    }
    state = state.copyWith(currentOperand: newOperand, isNewOperand: false);
  }

  void appendDecimal() {
    if (state.hasError) clear();

    String newOperand = state.currentOperand;
    if (state.isNewOperand) {
      newOperand = '0.';
    } else {
      if (!newOperand.contains('.')) {
        newOperand += '.';
      }
    }
    state = state.copyWith(currentOperand: newOperand, isNewOperand: false);
  }

  void setOperator(String operator) {
    if (state.hasError) return;

    if (state.currentOperator != null && !state.isNewOperand) {
      _calculateInternal();
    }
    state = state.copyWith(
      previousOperand: state.currentOperand,
      currentOperator: operator,
      isNewOperand: true,
    );
  }

  void calculate() {
    if (state.hasError || state.currentOperator == null) return;
    _calculateInternal();
    state = state.copyWith(currentOperator: null, isNewOperand: true);
  }

  void _calculateInternal() {
    double? prev = double.tryParse(state.previousOperand);
    double? curr = double.tryParse(state.currentOperand);

    if (prev == null || curr == null) return;

    double result = 0;
    bool divisionByZero = false;

    switch (state.currentOperator) {
      case '+':
        result = prev + curr;
        break;
      case '-':
        result = prev - curr;
        break;
      case '×':
      case '*':
        result = prev * curr;
        break;
      case '÷':
      case '/':
        if (curr == 0) {
          divisionByZero = true;
        } else {
          result = prev / curr;
        }
        break;
    }

    if (divisionByZero) {
      ref.read(historyProvider.notifier).addEntry(
        state.previousOperand, 
        state.currentOperator!, 
        state.currentOperand, 
        'Error'
      );
      state = state.copyWith(currentOperand: 'Error', hasError: true);
      return;
    }

    String resultStr = _formatResult(result);
    
    // Add to history tape
    ref.read(historyProvider.notifier).addEntry(
      state.previousOperand, 
      state.currentOperator!, 
      state.currentOperand, 
      resultStr
    );

    state = state.copyWith(currentOperand: resultStr, previousOperand: '');
  }

  String _formatResult(double result) {
    String str = result.toString();
    if (str.endsWith('.0')) {
      str = str.substring(0, str.length - 2);
    }
    if (str.length > maxLength) {
      if (str.contains('.')) {
        str = str.substring(0, maxLength);
      } else {
         str = result.toStringAsExponential(5);
      }
    }
    return str;
  }

  void clear() {
    state = CalculatorState(currentOperand: '0', previousOperand: '', isDevMode: state.isDevMode);
    ref.read(historyProvider.notifier).clearHistory();
  }

  void toggleSign() {
    if (state.hasError || state.currentOperand == '0') return;
    if (state.currentOperand.startsWith('-')) {
      state = state.copyWith(currentOperand: state.currentOperand.substring(1));
    } else {
      state = state.copyWith(currentOperand: '-' + state.currentOperand);
    }
  }

  void applyPercentage() {
    if (state.hasError) return;
    double? curr = double.tryParse(state.currentOperand);
    if (curr != null) {
      curr = curr / 100;
      state = state.copyWith(currentOperand: _formatResult(curr), isNewOperand: true);
    }
  }

  void syncWithHistory(String result) {
    state = state.copyWith(currentOperand: result, previousOperand: '', currentOperator: null, isNewOperand: true, hasError: result == 'Error');
  }
}

final calculatorProvider = NotifierProvider<CalculatorNotifier, CalculatorState>(() {
  return CalculatorNotifier();
});
