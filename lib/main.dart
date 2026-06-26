import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/styles.dart';
import 'features/calculator/presentation/calculator_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.black,
  ));
  runApp(
    const ProviderScope(
      child: VibeCalculatorApp(),
    ),
  );
}

class VibeCalculatorApp extends StatelessWidget {
  const VibeCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibe Calculator',
      debugShowCheckedModeBanner: false,
      theme: AppStyles.theme,
      home: const CalculatorScreen(),
    );
  }
}
