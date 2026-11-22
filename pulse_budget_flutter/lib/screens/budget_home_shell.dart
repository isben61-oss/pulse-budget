import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../data/currencies.dart';
import '../data/translations.dart';
import '../models/budget_models.dart';
import '../services/budget_storage.dart';
import '../utils/formatters.dart';
import '../widgets/budget_bar_chart.dart';

enum _AppView { home, spending, earnings }

class BudgetHomeShell extends StatefulWidget {
  final BudgetStorage storage;

  const BudgetHomeShell({super.key, required this.storage});

  @override
  State<BudgetHomeShell> createState() => _BudgetHomeShellState();
}

class _BudgetHomeShellState extends State<BudgetHomeShell> {
  BudgetState _state = const BudgetState();
  bool _loaded = false;
  _AppView _currentView = _AppView.home;

  ChartPeriod _homePeriod = ChartPeriod.daily;
  ChartPeriod _spendingPeriod = ChartPeriod.daily;
  ChartPeriod _earningsPeriod = ChartPeriod.daily;

  final _earningAmountCtrl = TextEditingController();
  final _earningNoteCtrl = TextEditingController();
  final _spendingAmountCtrl = TextEditingController();
  final _spendingNoteCtrl = TextEditingController();

  CurrencyInfo get _currency => currencyByCode(_state.currencyCode);
  AppLanguage get _lang => AppLanguageX.fromCode(_state.languageCode);
  AppStrings get _s => AppStrings(_lang);
  bool get _isDark => _state.darkMode;

  Color get _bgApp => _isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
  Color get _surface => _isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get _surfaceAlt => _isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
  Color get _pillBg => _isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
  Color get _border => _isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  Color get _borderSoft => _isDark ? const Color(0xFF263449) : const Color(0xFFF1F5F9);
  Color get _textPrimary => _isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  Color get _textSecondary => _isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get _textMuted => _isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  Color get _emeraldAccent => _isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
  Color get _roseAccent => _isDark ? const Color(0xFFFB7185) : const Color(0xFFE11D48);

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final loaded = await widget.storage.load();
    if (!mounted) return;
    setState(() {
      _state = loaded;
      _homePeriod = loaded.defaults.home;
      _spendingPeriod = loaded.defaults.spending;
      _earningsPeriod = loaded.defaults.earnings;
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _earningAmountCtrl.dispose();
    _earningNoteCtrl.dispose();
    _spendingAmountCtrl.dispose();
    _spendingNoteCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  Future<void> _saveState(BudgetState next) async {
    setState(() => _state = next);
    await widget.storage.save(next);
  }

  String _periodLabel(ChartPeriod p) => switch (p) {
        ChartPeriod.daily => _s.daily,
        ChartPeriod.weekly => _s.weekly,
        ChartPeriod.monthly => _s.monthly,
      };

  Future<void> _addTransaction(
    TransactionType type,
    TextEditingController amountCtrl,
    TextEditingController noteCtrl,
  ) async {
    final parsed = double.tryParse(amountCtrl.text.trim());
    if (parsed == null || !parsed.isFinite || parsed <= 0) {
      _showSnack(_s.invalidAmount);
      return;
    }

    final amount = (parsed * 100).roundToDouble() / 100;
    final tx = BudgetTransaction(
      id: 'tx_${DateTime.now().microsecondsSinceEpoch}',
      type: type,
      amount: amount,
      note: noteCtrl.text.trim(),
      timestamp: DateTime.now(),
    );

    amountCtrl.clear();
    noteCtrl.clear();
    FocusScope.of(context).unfocus();

    await _saveState(_state.copyWith(transactions: [..._state.transactions, tx]));
    final formatted = formatMoney(amount, _currency);
    _showSnack(type == TransactionType.earning
        ? _s.addedEarning(formatted)
        : _s.addedSpending(formatted));
  }

  Future<void> _deleteTransaction(String id) async {
    await _saveState(_state.copyWith(
      transactions: _state.transactions.where((t) => t.id != id).toList(),
    ));
    _showSnack(_s.entryRemoved);
  }

  Future<void> _editTransaction(BudgetTransaction tx) async {
    final amountCtrl = TextEditingController(text: tx.amount.toString());
    final noteCtrl = TextEditingController(text: tx.note);
    final isSpending = tx.type == TransactionType.spending;
    final prefix = _currency.symbol.length <= 3 ? _currency.symbol : _currency.code;

    final updated = await showDialog<BudgetTransaction>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: _lang.isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: _surface,
          title: Text(
            isSpending ? _s.editSpending : _s.editEarning,
            style: TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountCtrl,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
                decoration: InputDecoration(
                  prefixText: '$prefix ',
                  prefixStyle: TextStyle(color: _textMuted, fontWeight: FontWeight.w600),
                  filled: true,
                  fillColor: _surfaceAlt,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _border),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteCtrl,
                maxLength: 60,
                style: TextStyle(color: _textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: isSpending ? _s.spendingNoteHint : _s.earningNoteHint,
                  hintStyle: TextStyle(color: _textMuted, fontSize: 12),
                  filled: true,
                  fillColor: _surfaceAlt,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _borderSoft),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(_s.cancel),
            ),
            FilledButton(
              onPressed: () {
                final parsed = double.tryParse(amountCtrl.text.trim());
                if (parsed == null || !parsed.isFinite || parsed <= 0) {
                  _showSnack(_s.invalidAmount);
                  return;
                }
                final amount = (parsed * 100).roundToDouble() / 100;
                Navigator.of(ctx).pop(BudgetTransaction(
                  id: tx.id,
                  type: tx.type,
                  amount: amount,
                  note: noteCtrl.text.trim(),
                  timestamp: tx.timestamp,
                ));
              },
              child: Text(_s.save),
            ),
          ],
        ),
      ),
    );

    amountCtrl.dispose();
    noteCtrl.dispose();

    if (updated != null) {
      final nextList = _state.transactions
          .map((t) => t.id == updated.id ? updated : t)
          .toList();
      await _saveState(_state.copyWith(transactions: nextList));
      _showSnack(_s.entryUpdated);
    }
  }

  Future<void> _setDefaultPeriod(_AppView view, ChartPeriod period) async {
    final currentDefault = switch (view) {
      _AppView.home => _state.defaults.home,
      _AppView.spending => _state.defaults.spending,
      _AppView.earnings => _state.defaults.earnings,
    };

    if (currentDefault == period) {
      _showSnack(_s.alreadyDefault(_periodLabel(period)));
      return;
    }

    final nextDefaults = switch (view) {
      _AppView.home => _state.defaults.copyWith(home: period),
      _AppView.spending => _state.defaults.copyWith(spending: period),
      _AppView.earnings => _state.defaults.copyWith(earnings: period),
    };

    await _saveState(_state.copyWith(defaults: nextDefaults));
    _showSnack(_s.defaultSaved(_periodLabel(period)));
  }

  void _selectView(_AppView view) {
    Navigator.of(context).pop();
    setState(() {
      _currentView = view;
      if (view == _AppView.home) _homePeriod = _state.defaults.home;
      if (view == _AppView.spending) _spendingPeriod = _state.defaults.spending;
      if (view == _AppView.earnings) _earningsPeriod = _state.defaults.earnings;
    });
  }

  Future<void> _openExportDialog() async {
    Navigator.of(context).pop();
    final jsonText = const JsonEncoder.withIndent('  ').convert(_state.toJson());
    await showDialog<void>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: _lang.isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: _surface,
          title: Text(_s.exportBackup, style: TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(_s.exportDesc, style: TextStyle(fontSize: 12, color: _textSecondary)),
                const SizedBox(height: 10),
                Container(
                  constraints: const BoxConstraints(maxHeight: 190),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      jsonText,
                      style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: _textPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(_s.close),
            ),
            FilledButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: jsonText));
                if (ctx.mounted) Navigator.of(ctx).pop();
                _showSnack(_s.backupCopied);
              },
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: Text(_s.copyBackup),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openImportDialog() async {
    Navigator.of(context).pop();
    final ctrl = TextEditingController();
    final restored = await showDialog<BudgetState>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: _lang.isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: _surface,
          title: Text(_s.importBackup, style: TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(_s.importDesc, style: TextStyle(fontSize: 12, color: _textSecondary)),
                const SizedBox(height: 10),
                TextField(
                  controller: ctrl,
                  maxLines: 6,
                  style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: _textPrimary),
                  decoration: InputDecoration(
                    hintText: '{"transactions": [...]}',
                    hintStyle: TextStyle(color: _textMuted, fontSize: 11),
                    filled: true,
                    fillColor: _surfaceAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _border),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () async {
                      final data = await Clipboard.getData(Clipboard.kTextPlain);
                      if (data?.text != null) {
                        ctrl.text = data!.text!;
                      }
                    },
                    icon: const Icon(Icons.content_paste_rounded, size: 16),
                    label: Text(_s.pasteBackup),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(_s.cancel),
            ),
            FilledButton(
              onPressed: () {
                try {
                  final decoded = jsonDecode(ctrl.text.trim()) as Map<String, dynamic>;
                  if (!decoded.containsKey('transactions')) {
                    _showSnack(_s.invalidBackup);
                    return;
                  }
                  Navigator.of(ctx).pop(BudgetState.fromJson(decoded));
                } catch (_) {
                  _showSnack(_s.invalidBackup);
                }
              },
              child: Text(_s.restore),
            ),
          ],
        ),
      ),
    );
    ctrl.dispose();

    if (restored != null) {
      await _saveState(restored);
      setState(() {
        _homePeriod = restored.defaults.home;
        _spendingPeriod = restored.defaults.spending;
        _earningsPeriod = restored.defaults.earnings;
      });
      _showSnack(_s.backupRestored(restored.transactions.length));
    }
  }

  Future<void> _confirmReset() async {
    Navigator.of(context).pop();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: _lang.isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: _surface,
          title: Text(_s.resetTitle, style: TextStyle(color: _textPrimary)),
          content: Text(_s.resetBody, style: TextStyle(color: _textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(_s.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(_s.resetConfirm),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      await _saveState(BudgetState(
        darkMode: _state.darkMode,
        languageCode: _state.languageCode,
      ));
      setState(() {
        _homePeriod = ChartPeriod.daily;
        _spendingPeriod = ChartPeriod.daily;
        _earningsPeriod = ChartPeriod.daily;
      });
      _showSnack(_s.clearedAll);
    }
  }

  Future<void> _openCurrencyPicker() async {
    final selected = await showModalBottomSheet<CurrencyInfo>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final q = query.trim().toLowerCase();
            final matches = q.isEmpty
                ? kAllCurrencies
                : kAllCurrencies.where((c) {
                    return c.code.toLowerCase().contains(q) ||
                        c.name.toLowerCase().contains(q) ||
                        c.symbol.toLowerCase().contains(q);
                  }).toList();

            return Directionality(
              textDirection: _lang.isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.78,
                minChildSize: 0.5,
                maxChildSize: 0.92,
                builder: (_, scrollCtrl) => Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 8, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _s.selectCurrency,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: _textPrimary,
                                  ),
                                ),
                                Text(
                                  _s.currencyCount(matches.length, kAllCurrencies.length),
                                  style: TextStyle(fontSize: 12, color: _textSecondary),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              icon: Icon(Icons.close_rounded, color: _textPrimary),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: TextField(
                          autofocus: true,
                          style: TextStyle(color: _textPrimary),
                          onChanged: (val) => setModalState(() => query = val),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search_rounded, size: 20, color: _textMuted),
                            hintText: _s.currencySearchHint,
                            hintStyle: TextStyle(color: _textMuted, fontSize: 13),
                            filled: true,
                            fillColor: _surfaceAlt,
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: _border),
                            ),
                          ),
                        ),
                      ),
                      Divider(height: 1, color: _borderSoft),
                      Expanded(
                        child: matches.isEmpty
                            ? Center(
                                child: Text(_s.noCurrencies, style: TextStyle(color: _textSecondary)),
                              )
                            : ListView.builder(
                                controller: scrollCtrl,
                                itemCount: matches.length,
                                itemBuilder: (_, idx) {
                                  final c = matches[idx];
                                  final isSel = c.code == _state.currencyCode;
                                  final selBg = _isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
                                  final selFg = _isDark ? const Color(0xFF0F172A) : Colors.white;
                                  return ListTile(
                                    selected: isSel,
                                    selectedTileColor: selBg,
                                    leading: Container(
                                      width: 44,
                                      height: 34,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isSel ? selFg.withOpacity(0.14) : _pillBg,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        c.symbol,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isSel ? selFg : _textPrimary,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      c.code,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isSel ? selFg : _textPrimary,
                                      ),
                                    ),
                                    subtitle: Text(
                                      c.name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isSel ? selFg.withOpacity(0.75) : _textSecondary,
                                      ),
                                    ),
                                    trailing: isSel ? Icon(Icons.check_rounded, color: selFg) : null,
                                    onTap: () => Navigator.of(ctx).pop(c),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (selected != null && selected.code != _state.currencyCode) {
      await _saveState(_state.copyWith(currencyCode: selected.code));
      _showSnack(_s.currencySet(selected.code, selected.name));
    }
  }

  String get _appBarTitle => switch (_currentView) {
        _AppView.home => _s.titleHome,
        _AppView.spending => _s.navSpending,
        _AppView.earnings => _s.navEarnings,
      };

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _lang.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _bgApp,
        appBar: AppBar(
          backgroundColor: _surface,
          surfaceTintColor: _surface,
          foregroundColor: _textPrimary,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: _borderSoft),
          ),
          title: Text(
            _appBarTitle,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: InkWell(
                onTap: _openCurrencyPicker,
                borderRadius: BorderRadius.circular(9),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _pillBg,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: _border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currency.code,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: _textSecondary),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        drawer: _buildDrawer(),
        body: !_loaded
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  child: switch (_currentView) {
                    _AppView.home => _buildHomeView(),
                    _AppView.spending => _buildDetailsView(TransactionType.spending),
                    _AppView.earnings => _buildDetailsView(TransactionType.earning),
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildDrawer() {
    final activeBg = _isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final activeFg = _isDark ? const Color(0xFF0F172A) : Colors.white;

    return Drawer(
      backgroundColor: _surface,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 12, 16),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: activeBg,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '\$',
                      style: TextStyle(color: activeFg, fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PulseBudget',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textPrimary),
                      ),
                      Text(
                        _s.brandSub,
                        style: TextStyle(fontSize: 11, color: _textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: _borderSoft),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _drawerItem(
                    icon: Icons.home_rounded,
                    label: _s.navOverview,
                    selected: _currentView == _AppView.home,
                    activeBg: activeBg,
                    activeFg: activeFg,
                    onTap: () => _selectView(_AppView.home),
                  ),
                  const SizedBox(height: 4),
                  _drawerItem(
                    icon: Icons.trending_down_rounded,
                    label: _s.navSpending,
                    selected: _currentView == _AppView.spending,
                    activeBg: activeBg,
                    activeFg: activeFg,
                    onTap: () => _selectView(_AppView.spending),
                  ),
                  const SizedBox(height: 4),
                  _drawerItem(
                    icon: Icons.trending_up_rounded,
                    label: _s.navEarnings,
                    selected: _currentView == _AppView.earnings,
                    activeBg: activeBg,
                    activeFg: activeFg,
                    onTap: () => _selectView(_AppView.earnings),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: _borderSoft),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.dark_mode_rounded, size: 18, color: _textPrimary),
                          const SizedBox(width: 8),
                          Text(
                            _s.darkMode,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textPrimary),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isDark,
                        onChanged: (val) => _saveState(_state.copyWith(darkMode: val)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.language_rounded, size: 18, color: _textPrimary),
                      const SizedBox(width: 8),
                      Text(
                        _s.language,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: _pillBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: AppLanguage.values.map((lang) {
                        final sel = lang == _lang;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => _saveState(_state.copyWith(languageCode: lang.name)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              decoration: BoxDecoration(
                                color: sel ? _surface : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                lang.nativeName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: sel ? _textPrimary : _textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: _borderSoft),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _borderSoft),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_s.currentBalance, style: TextStyle(fontSize: 11, color: _textSecondary)),
                        const SizedBox(height: 2),
                        Text(
                          formatMoney(_state.balance, _currency),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.circle, size: 8, color: Color(0xFF10B981)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _s.localOnly,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _emeraldAccent),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: _openExportDialog,
                          style: FilledButton.styleFrom(
                            backgroundColor: _pillBg,
                            foregroundColor: _textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(_s.exportBackup, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: _openImportDialog,
                          style: FilledButton.styleFrom(
                            backgroundColor: _pillBg,
                            foregroundColor: _textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(_s.importBackup, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: _confirmReset,
                    style: TextButton.styleFrom(foregroundColor: _textSecondary),
                    child: Text(_s.resetAll),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required bool selected,
    required Color activeBg,
    required Color activeFg,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: selected ? activeFg : _textPrimary, size: 20),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: selected ? activeFg : _textPrimary,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: selected ? activeBg : null,
      onTap: onTap,
    );
  }

  Widget _buildHomeView() {
    final series = computeBalanceSeries(_state.transactions, _homePeriod, _s);
    final isDefault = _homePeriod == _state.defaults.home;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _isDark ? const Color(0xFF020617) : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(18),
            border: _isDark ? Border.all(color: const Color(0xFF334155)) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_s.currentBalance.toUpperCase()} (${_currency.code})',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.7,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                formatMoney(_state.balance, _currency),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: _state.balance < 0 ? const Color(0xFFFB7185) : Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFF1E293B)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_s.totalEarnings, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                        const SizedBox(height: 2),
                        Text(
                          '+${formatMoney(_state.totalEarnings, _currency)}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF34D399)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_s.totalSpendings, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                        const SizedBox(height: 2),
                        Text(
                          '−${formatMoney(_state.totalSpendings, _currency)}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFFB7185)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildInputCard(
          title: _s.addEarning,
          hint: _s.increasesBalance,
          noteHint: _s.earningNoteHint,
          buttonLabel: _s.btnAdd,
          accentColor: _emeraldAccent,
          buttonBg: const Color(0xFF059669),
          amountCtrl: _earningAmountCtrl,
          noteCtrl: _earningNoteCtrl,
          onSubmit: () => _addTransaction(TransactionType.earning, _earningAmountCtrl, _earningNoteCtrl),
        ),
        const SizedBox(height: 12),
        _buildInputCard(
          title: _s.addSpending,
          hint: _s.decreasesBalance,
          noteHint: _s.spendingNoteHint,
          buttonLabel: _s.btnSpend,
          accentColor: _roseAccent,
          buttonBg: const Color(0xFFE11D48),
          amountCtrl: _spendingAmountCtrl,
          noteCtrl: _spendingNoteCtrl,
          onSubmit: () => _addTransaction(TransactionType.spending, _spendingAmountCtrl, _spendingNoteCtrl),
        ),
        const SizedBox(height: 14),
        _buildChartCard(
          title: _s.moneyAmount,
          subtitle: series.subtitle,
          totalText: null,
          totalColor: null,
          activePeriod: _homePeriod,
          isDefault: isDefault,
          onSelectPeriod: (p) => setState(() => _homePeriod = p),
          onSetDefault: () => _setDefaultPeriod(_AppView.home, _homePeriod),
          labels: series.labels,
          values: series.values,
          colorMode: BarColorMode.balance,
        ),
      ],
    );
  }

  Widget _buildDetailsView(TransactionType type) {
    final isSpending = type == TransactionType.spending;
    final view = isSpending ? _AppView.spending : _AppView.earnings;
    final period = isSpending ? _spendingPeriod : _earningsPeriod;
    final isDefault = period == (isSpending ? _state.defaults.spending : _state.defaults.earnings);

    final series = computeTypeSeries(_state.transactions, type, period, _s);
    final history = _state.transactions.where((tx) => tx.type == type).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildChartCard(
          title: isSpending ? _s.spendingChart : _s.earningsChart,
          subtitle: series.subtitle,
          totalText: formatMoney(series.total, _currency),
          totalColor: isSpending ? _roseAccent : _emeraldAccent,
          activePeriod: period,
          isDefault: isDefault,
          onSelectPeriod: (p) => setState(() {
            if (isSpending) {
              _spendingPeriod = p;
            } else {
              _earningsPeriod = p;
            }
          }),
          onSetDefault: () => _setDefaultPeriod(view, period),
          labels: series.labels,
          values: series.values,
          colorMode: isSpending ? BarColorMode.spending : BarColorMode.earnings,
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isSpending ? _s.spendingHistory : _s.earningsHistory,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary),
                    ),
                    Text(
                      _s.entriesCount(history.length),
                      style: TextStyle(fontSize: 12, color: _textSecondary),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: _borderSoft),
              if (history.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 34),
                  child: Column(
                    children: [
                      Text(
                        isSpending ? _s.noSpendings : _s.noEarnings,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _s.emptyHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: _textMuted),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: history.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: _borderSoft),
                  itemBuilder: (_, idx) {
                    final tx = history[idx];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      title: Text(
                        tx.note.isNotEmpty
                            ? tx.note
                            : (isSpending ? _s.defaultSpendingNote : _s.defaultEarningNote),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary),
                      ),
                      subtitle: Text(
                        formatExactTimestamp(tx.timestamp, _s),
                        style: TextStyle(fontSize: 12, color: _textSecondary),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${isSpending ? '−' : '+'}${formatMoney(tx.amount, _currency)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isSpending ? _roseAccent : _emeraldAccent,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit_outlined, size: 19, color: _textMuted),
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _editTransaction(tx),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline_rounded, size: 20, color: _textMuted),
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _deleteTransaction(tx.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputCard({
    required String title,
    required String hint,
    required String noteHint,
    required String buttonLabel,
    required Color accentColor,
    required Color buttonBg,
    required TextEditingController amountCtrl,
    required TextEditingController noteCtrl,
    required VoidCallback onSubmit,
  }) {
    final prefix = _currency.symbol.length <= 3 ? _currency.symbol : _currency.code;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: accentColor)),
                ],
              ),
              Text(hint, style: TextStyle(fontSize: 12, color: _textMuted)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onSubmit(),
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: _textPrimary),
                  decoration: InputDecoration(
                    prefixText: '$prefix ',
                    prefixStyle: TextStyle(color: _textMuted, fontWeight: FontWeight.w600, fontSize: 14),
                    hintText: '0.00',
                    hintStyle: TextStyle(color: _textMuted),
                    filled: true,
                    fillColor: _surfaceAlt,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _border),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: buttonBg,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed: onSubmit,
                  child: Text(buttonLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: noteCtrl,
            maxLength: 60,
            style: TextStyle(fontSize: 12, color: _textPrimary),
            decoration: InputDecoration(
              counterText: '',
              hintText: noteHint,
              hintStyle: TextStyle(fontSize: 12, color: _textMuted),
              filled: true,
              fillColor: _surfaceAlt,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _borderSoft),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _borderSoft),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required String? totalText,
    required Color? totalColor,
    required ChartPeriod activePeriod,
    required bool isDefault,
    required ValueChanged<ChartPeriod> onSelectPeriod,
    required VoidCallback onSetDefault,
    required List<String> labels,
    required List<double> values,
    required BarColorMode colorMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: totalText == null ? 14 : 12,
                      fontWeight: totalText == null ? FontWeight.w600 : FontWeight.w500,
                      color: totalText == null ? _textPrimary : _textSecondary,
                    ),
                  ),
                  if (totalText != null) ...[
                    const SizedBox(height: 2),
                    Text(totalText, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: totalColor)),
                  ],
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: _textMuted)),
                ],
              ),
              OutlinedButton(
                onPressed: onSetDefault,
                style: OutlinedButton.styleFrom(
                  backgroundColor: isDefault
                      ? (_isDark ? const Color(0x28F59E0B) : const Color(0xFFFFFBEB))
                      : _pillBg,
                  foregroundColor: isDefault
                      ? (_isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309))
                      : _textPrimary,
                  side: BorderSide(
                    color: isDefault
                        ? (_isDark ? const Color(0x55F59E0B) : const Color(0xFFFDE68A))
                        : Colors.transparent,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  isDefault ? _s.isDefault : _s.setDefault,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: _pillBg, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: ChartPeriod.values.map((period) {
                final selected = period == activePeriod;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onSelectPeriod(period),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? _surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _periodLabel(period),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? _textPrimary : _textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          BudgetBarChart(
            labels: labels,
            values: values,
            colorMode: colorMode,
            currency: _currency,
            darkMode: _isDark,
          ),
        ],
      ),
    );
  }
}
