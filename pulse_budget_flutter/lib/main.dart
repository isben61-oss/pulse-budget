import 'package:flutter/material.dart';
import 'screens/budget_home_shell.dart';
import 'services/budget_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PulseBudgetApp());
}

class PulseBudgetApp extends StatelessWidget {
  const PulseBudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PulseBudget',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: BudgetHomeShell(storage: BudgetStorage()),
    );
  }
}
