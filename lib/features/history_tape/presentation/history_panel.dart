import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/history_provider.dart';
import '../../calculator/providers/calculator_provider.dart';
import '../../../core/theme/colors.dart';

class HistoryPanel extends ConsumerStatefulWidget {
  const HistoryPanel({super.key});

  @override
  ConsumerState<HistoryPanel> createState() => _HistoryPanelState();
}

class _HistoryPanelState extends ConsumerState<HistoryPanel> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showEditDialog(BuildContext context, HistoryEntry entry, bool isOperandA) {
    final TextEditingController controller = TextEditingController(
      text: isOperandA ? entry.operandA : entry.operandB,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundCharcoal,
          title: Text(
            'Edit Operand ${isOperandA ? 'A' : 'B'}',
            style: const TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            style: const TextStyle(color: AppColors.neonCyan),
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.glassWhite),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.neonCyan),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                final newValue = controller.text;
                if (double.tryParse(newValue) != null) {
                  if (isOperandA) {
                    ref.read(historyProvider.notifier).updateEntry(entry.id, newOperandA: newValue);
                  } else {
                    ref.read(historyProvider.notifier).updateEntry(entry.id, newOperandB: newValue);
                  }
                  
                  // Also sync the calculator screen's main state to the last history result if needed.
                  final history = ref.read(historyProvider);
                  if (history.isNotEmpty) {
                    ref.read(calculatorProvider.notifier).syncWithHistory(history.last.result);
                  }
                }
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: AppColors.neonCyan)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);
    
    // Auto scroll when history updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return ListView.builder(
      controller: _scrollController,
      itemCount: history.length,
      itemBuilder: (context, index) {
        final entry = history[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => _showEditDialog(context, entry, true),
                child: Text(
                  entry.operandA,
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  entry.operatorStr,
                  style: const TextStyle(color: AppColors.electricPurple, fontSize: 18),
                ),
              ),
              GestureDetector(
                onTap: () => _showEditDialog(context, entry, false),
                child: Text(
                  entry.operandB,
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '=',
                  style: TextStyle(color: Colors.white54, fontSize: 18),
                ),
              ),
              Text(
                entry.result,
                style: const TextStyle(color: AppColors.neonCyan, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}
