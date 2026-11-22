enum TransactionType { earning, spending }

enum ChartPeriod { daily, weekly, monthly }

extension ChartPeriodX on ChartPeriod {
  String get label {
    switch (this) {
      case ChartPeriod.daily:
        return 'Daily';
      case ChartPeriod.weekly:
        return 'Weekly';
      case ChartPeriod.monthly:
        return 'Monthly';
    }
  }

  static ChartPeriod fromName(String? value) {
    switch (value) {
      case 'weekly':
        return ChartPeriod.weekly;
      case 'monthly':
        return ChartPeriod.monthly;
      default:
        return ChartPeriod.daily;
    }
  }
}

class BudgetTransaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String note;
  final DateTime timestamp;

  const BudgetTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.note,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'amount': amount,
        'note': note,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };

  factory BudgetTransaction.fromJson(Map<String, dynamic> json) {
    return BudgetTransaction(
      id: (json['id'] as String?) ?? '',
      type: json['type'] == 'earning'
          ? TransactionType.earning
          : TransactionType.spending,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      note: (json['note'] as String?) ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['timestamp'] as num?)?.toInt() ?? 0,
      ),
    );
  }
}

class ChartDefaults {
  final ChartPeriod home;
  final ChartPeriod spending;
  final ChartPeriod earnings;

  const ChartDefaults({
    this.home = ChartPeriod.daily,
    this.spending = ChartPeriod.daily,
    this.earnings = ChartPeriod.daily,
  });

  ChartDefaults copyWith({
    ChartPeriod? home,
    ChartPeriod? spending,
    ChartPeriod? earnings,
  }) {
    return ChartDefaults(
      home: home ?? this.home,
      spending: spending ?? this.spending,
      earnings: earnings ?? this.earnings,
    );
  }

  Map<String, dynamic> toJson() => {
        'home': home.name,
        'spending': spending.name,
        'earnings': earnings.name,
      };

  factory ChartDefaults.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ChartDefaults();
    return ChartDefaults(
      home: ChartPeriodX.fromName(json['home'] as String?),
      spending: ChartPeriodX.fromName(json['spending'] as String?),
      earnings: ChartPeriodX.fromName(json['earnings'] as String?),
    );
  }
}

class BudgetState {
  final List<BudgetTransaction> transactions;
  final ChartDefaults defaults;
  final String currencyCode;
  final bool darkMode;
  final String languageCode;

  const BudgetState({
    this.transactions = const [],
    this.defaults = const ChartDefaults(),
    this.currencyCode = 'USD',
    this.darkMode = false,
    this.languageCode = 'en',
  });

  BudgetState copyWith({
    List<BudgetTransaction>? transactions,
    ChartDefaults? defaults,
    String? currencyCode,
    bool? darkMode,
    String? languageCode,
  }) {
    return BudgetState(
      transactions: transactions ?? this.transactions,
      defaults: defaults ?? this.defaults,
      currencyCode: currencyCode ?? this.currencyCode,
      darkMode: darkMode ?? this.darkMode,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  double get totalEarnings => transactions
      .where((t) => t.type == TransactionType.earning)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalSpendings => transactions
      .where((t) => t.type == TransactionType.spending)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance =>
      ((totalEarnings - totalSpendings) * 100).roundToDouble() / 100;

  Map<String, dynamic> toJson() => {
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'defaults': defaults.toJson(),
        'currencyCode': currencyCode,
        'darkMode': darkMode,
        'languageCode': languageCode,
      };

  factory BudgetState.fromJson(Map<String, dynamic> json) {
    final rawList = (json['transactions'] as List<dynamic>?) ?? const [];
    final txs = rawList
        .whereType<Map<String, dynamic>>()
        .map(BudgetTransaction.fromJson)
        .where((t) => t.amount > 0)
        .toList();
    return BudgetState(
      transactions: txs,
      defaults: ChartDefaults.fromJson(
        json['defaults'] as Map<String, dynamic>?,
      ),
      currencyCode: (json['currencyCode'] as String?) ?? (json['currency'] as String?) ?? 'USD',
      darkMode: (json['darkMode'] as bool?) ?? false,
      languageCode: (json['languageCode'] as String?) ?? (json['language'] as String?) ?? 'en',
    );
  }
}
