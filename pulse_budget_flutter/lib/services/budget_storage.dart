import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/budget_models.dart';

/// 100% offline local persistence backed by SharedPreferences (Android)
/// and NSUserDefaults (iOS). Survives app restarts and phone reboots.
class BudgetStorage {
  static const String _storageKey = 'pulse_budget_state_v1';

  Future<BudgetState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return const BudgetState();
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return BudgetState.fromJson(decoded);
    } catch (_) {
      return const BudgetState();
    }
  }

  Future<void> save(BudgetState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }
}
