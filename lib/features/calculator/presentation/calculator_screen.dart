import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/float_converter.dart';
import '../../history_tape/presentation/history_panel.dart';
import '../providers/calculator_provider.dart';
import 'widgets/glass_button.dart';

class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundBlack,
              AppColors.backgroundCharcoal,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // History Panel
              const Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: HistoryPanel(),
                ),
              ),
              // Main Display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${state.previousOperand} ${state.currentOperator ?? ""}'.trim(),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.currentOperand,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: state.hasError ? Colors.redAccent : Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (state.isDevMode) _buildDevModeVisualizer(state.currentOperand),
                  ],
                ),
              ),
              // Keypad
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const spacing = 12.0;
                      return Column(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(child: GlassButton(label: 'AC', onTap: notifier.clear, color: Colors.white24)),
                                const SizedBox(width: spacing),
                                Expanded(child: GlassButton(label: '+/-', onTap: notifier.toggleSign, color: Colors.white24)),
                                const SizedBox(width: spacing),
                                Expanded(child: GlassButton(label: '%', onTap: notifier.applyPercentage, color: Colors.white24)),
                                const SizedBox(width: spacing),
                                Expanded(child: GlassButton(label: '÷', onTap: () => notifier.setOperator('÷'), color: AppColors.electricPurple.withOpacity(0.2))),
                              ],
                            ),
                          ),
                          const SizedBox(height: spacing),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(child: GlassButton(label: '7', onTap: () => notifier.appendDigit('7'))),
                                const SizedBox(width: spacing),
                                Expanded(child: GlassButton(label: '8', onTap: () => notifier.appendDigit('8'))),
                                const SizedBox(width: spacing),
                                Expanded(child: GlassButton(label: '9', onTap: () => notifier.appendDigit('9'))),
                                const SizedBox(width: spacing),
                                Expanded(child: GlassButton(label: '×', onTap: () => notifier.setOperator('×'), color: AppColors.electricPurple.withOpacity(0.2))),
                              ],
                            ),
                          ),
                          const SizedBox(height: spacing),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(child: GlassButton(label: '4', onTap: () => notifier.appendDigit('4'))),
                                const SizedBox(width: spacing),
                                Expanded(child: GlassButton(label: '5', onTap: () => notifier.appendDigit('5'))),
                                const SizedBox(width: spacing),
                                Expanded(child: GlassButton(label: '6', onTap: () => notifier.appendDigit('6'))),
                                const SizedBox(width: spacing),
                                Expanded(child: GlassButton(label: '-', onTap: () => notifier.setOperator('-'), color: AppColors.electricPurple.withOpacity(0.2))),
                              ],
                            ),
                          ),
                          const SizedBox(height: spacing),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(child: GlassButton(label: '1', onTap: () => notifier.appendDigit('1'))),
                                const SizedBox(width: spacing),
                                Expanded(child: GlassButton(label: '2', onTap: () => notifier.appendDigit('2'))),
                                const SizedBox(width: spacing),
                                Expanded(child: GlassButton(label: '3', onTap: () => notifier.appendDigit('3'))),
                                const SizedBox(width: spacing),
                                Expanded(child: GlassButton(label: '+', onTap: () => notifier.setOperator('+'), color: AppColors.electricPurple.withOpacity(0.2))),
                              ],
                            ),
                          ),
                          const SizedBox(height: spacing),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(flex: 2, child: GlassButton(label: '0', onTap: () => notifier.appendDigit('0'))),
                                const SizedBox(width: spacing),
                                Expanded(child: GlassButton(
                                  label: '.', 
                                  onTap: notifier.appendDecimal,
                                  onLongPress: notifier.toggleDevMode, // Deep Dev Mode Toggle
                                )),
                                const SizedBox(width: spacing),
                                Expanded(child: GlassButton(label: '=', onTap: notifier.calculate, isPrimary: true)),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDevModeVisualizer(String currentOperand) {
    double? val = double.tryParse(currentOperand);
    if (val == null) return const SizedBox.shrink();

    final components = FloatConverter.getSinglePrecisionComponents(val);

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'IEEE 754 Single-Precision (32-bit)',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBitBlock(components.sign, Colors.redAccent, 'Sign (1)'),
              const SizedBox(width: 4),
              _buildBitBlock(components.exponent, Colors.greenAccent, 'Exp (8)'),
              const SizedBox(width: 4),
              _buildBitBlock(components.mantissa, AppColors.neonCyan, 'Mantissa (23)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBitBlock(String bits, Color color, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            bits,
            style: TextStyle(
              color: color,
              fontFamily: 'monospace',
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: color.withOpacity(0.8), fontSize: 8),
        ),
      ],
    );
  }
}
