import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class HistoryEntry {
  final String id;
  final String operandA;
  final String operatorStr;
  final String operandB;
  final String result;

  HistoryEntry({
    String? id,
    required this.operandA,
    required this.operatorStr,
    required this.operandB,
    required this.result,
  }) : id = id ?? const Uuid().v4();

  HistoryEntry copyWith({
    String? operandA,
    String? operatorStr,
    String? operandB,
    String? result,
  }) {
    return HistoryEntry(
      id: id,
      operandA: operandA ?? this.operandA,
      operatorStr: operatorStr ?? this.operatorStr,
      operandB: operandB ?? this.operandB,
      result: result ?? this.result,
    );
  }
}

class HistoryNotifier extends Notifier<List<HistoryEntry>> {
  @override
  List<HistoryEntry> build() {
    return [];
  }

  void addEntry(String operandA, String operatorStr, String operandB, String result) {
    state = [
      ...state,
      HistoryEntry(
        operandA: operandA,
        operatorStr: operatorStr,
        operandB: operandB,
        result: result,
      )
    ];
  }

  void clearHistory() {
    state = [];
  }

  void updateEntry(String id, {String? newOperandA, String? newOperandB}) {
    int index = state.indexWhere((entry) => entry.id == id);
    if (index == -1) return;

    List<HistoryEntry> newState = List.from(state);
    
    // Update the targeted entry
    HistoryEntry target = newState[index];
    newState[index] = target.copyWith(
      operandA: newOperandA ?? target.operandA,
      operandB: newOperandB ?? target.operandB,
    );

    // Cascade recalculations for this and all subsequent entries
    for (int i = index; i < newState.length; i++) {
      HistoryEntry current = newState[i];
      
      // If it's not the first updated entry, the operandA becomes the result of the previous entry
      if (i > index) {
        current = current.copyWith(operandA: newState[i - 1].result);
      }

      // Calculate new result
      double? a = double.tryParse(current.operandA);
      double? b = double.tryParse(current.operandB);

      if (a != null && b != null) {
        double resultVal = 0;
        switch (current.operatorStr) {
          case '+': resultVal = a + b; break;
          case '-': resultVal = a - b; break;
          case '×': 
          case '*': resultVal = a * b; break;
          case '÷': 
          case '/': 
            if (b != 0) {
              resultVal = a / b;
            } else {
               // Handle divide by zero in history? We just put Error.
               newState[i] = current.copyWith(result: 'Error');
               continue;
            }
            break;
        }
        
        String resultStr = _formatResult(resultVal);
        newState[i] = current.copyWith(result: resultStr);
      }
    }
    
    state = newState;
  }
  
  String _formatResult(double result) {
    String str = result.toString();
    if (str.endsWith('.0')) {
      str = str.substring(0, str.length - 2);
    }
    const int maxLength = 15;
    if (str.length > maxLength) {
      if (str.contains('.')) {
        str = str.substring(0, maxLength);
      } else {
         str = result.toStringAsExponential(5);
      }
    }
    return str;
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, List<HistoryEntry>>(() {
  return HistoryNotifier();
});
