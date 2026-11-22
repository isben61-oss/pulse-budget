import '../data/currencies.dart';
import '../data/translations.dart';
import '../models/budget_models.dart';

String formatMoney(double value, CurrencyInfo currency) {
  final isNegative = value < 0;
  final absVal = value.abs();
  final digits = currency.digits.clamp(0, 4);
  final fixed = absVal.toStringAsFixed(digits);
  final parts = fixed.split('.');
  final intPart = parts[0];
  final decPart = parts.length > 1 ? '.${parts[1]}' : '';

  final buf = StringBuffer();
  for (int i = 0; i < intPart.length; i++) {
    final posFromRight = intPart.length - i;
    if (i > 0 && posFromRight % 3 == 0) buf.write(',');
    buf.write(intPart[i]);
  }
  final sym = currency.symbol.length == 1
      ? currency.symbol
      : (currency.symbol.length <= 3 ? '${currency.symbol} ' : '${currency.code} ');
  return '${isNegative ? '-' : ''}$sym${buf.toString()}$decPart';
}

String formatCompactMoney(double value, CurrencyInfo currency) {
  final sign = value < 0 ? '-' : '';
  final sym = currency.symbol.length == 1
      ? currency.symbol
      : (currency.symbol.length <= 3 ? '${currency.symbol} ' : '${currency.code} ');
  final abs = value.abs();
  if (abs >= 1e6) {
    final v = (abs / 1e6).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
    return '$sign$sym${v}M';
  }
  if (abs >= 1e3) {
    final v = (abs / 1e3).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
    return '$sign$sym${v}K';
  }
  return '$sign$sym${abs.round()}';
}

String formatExactTimestamp(DateTime dt, AppStrings strings) {
  final month = strings.shortMonths[dt.month - 1];
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  final ss = dt.second.toString().padLeft(2, '0');
  if (strings.lang == AppLanguage.en) {
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final h12 = (dt.hour % 12 == 0 ? 12 : dt.hour % 12).toString().padLeft(2, '0');
    return '$month ${dt.day}, ${dt.year} · $h12:$mm:$ss $period';
  }
  return '${dt.day} $month ${dt.year} · $hh:$mm:$ss';
}

class ChartBucket {
  final String label;
  final DateTime start;
  final DateTime end;

  const ChartBucket({required this.label, required this.start, required this.end});
}

class ChartSeriesData {
  final List<String> labels;
  final List<double> values;
  final double total;
  final String subtitle;

  const ChartSeriesData({
    required this.labels,
    required this.values,
    required this.total,
    required this.subtitle,
  });
}

List<ChartBucket> buildBuckets(ChartPeriod period, AppStrings strings, [DateTime? nowOverride]) {
  final now = nowOverride ?? DateTime.now();
  final months = strings.shortMonths;
  final buckets = <ChartBucket>[];

  if (period == ChartPeriod.daily) {
    for (int i = 6; i >= 0; i--) {
      final d = DateTime(now.year, now.month, now.day - i);
      final start = DateTime(d.year, d.month, d.day, 0, 0, 0, 0);
      final end = DateTime(d.year, d.month, d.day, 23, 59, 59, 999);
      final label = i == 0 ? strings.today : '${months[d.month - 1]} ${d.day}';
      buckets.add(ChartBucket(label: label, start: start, end: end));
    }
    return buckets;
  }

  if (period == ChartPeriod.weekly) {
    final daysSinceSunday = now.weekday % 7;
    final currentWeekStart = DateTime(now.year, now.month, now.day - daysSinceSunday);
    for (int i = 5; i >= 0; i--) {
      final ws = DateTime(currentWeekStart.year, currentWeekStart.month, currentWeekStart.day - i * 7);
      final we = DateTime(ws.year, ws.month, ws.day + 6, 23, 59, 59, 999);
      final label = i == 0 ? strings.thisWk : '${months[ws.month - 1]} ${ws.day}';
      buckets.add(ChartBucket(label: label, start: ws, end: we));
    }
    return buckets;
  }

  for (int i = 5; i >= 0; i--) {
    final ms = DateTime(now.year, now.month - i, 1, 0, 0, 0, 0);
    final me = DateTime(now.year, now.month - i + 1, 0, 23, 59, 59, 999);
    buckets.add(ChartBucket(label: months[ms.month - 1], start: ms, end: me));
  }
  return buckets;
}

ChartSeriesData computeBalanceSeries(
  List<BudgetTransaction> transactions,
  ChartPeriod period,
  AppStrings strings,
) {
  final buckets = buildBuckets(period, strings);
  final values = buckets.map((b) {
    double bal = 0;
    for (final tx in transactions) {
      if (!tx.timestamp.isAfter(b.end)) {
        bal += tx.type == TransactionType.earning ? tx.amount : -tx.amount;
      }
    }
    return (bal * 100).roundToDouble() / 100;
  }).toList();

  final rangeText = switch (period) {
    ChartPeriod.daily => '${strings.endingBalance} · ${strings.last7d}',
    ChartPeriod.weekly => '${strings.endingBalance} · ${strings.last6w}',
    ChartPeriod.monthly => '${strings.endingBalance} · ${strings.last6m}',
  };

  return ChartSeriesData(
    labels: buckets.map((b) => b.label).toList(),
    values: values,
    total: values.isNotEmpty ? values.last : 0.0,
    subtitle: rangeText,
  );
}

ChartSeriesData computeTypeSeries(
  List<BudgetTransaction> transactions,
  TransactionType type,
  ChartPeriod period,
  AppStrings strings,
) {
  final buckets = buildBuckets(period, strings);
  final values = buckets.map((b) {
    double sum = 0;
    for (final tx in transactions) {
      if (tx.type == type && !tx.timestamp.isBefore(b.start) && !tx.timestamp.isAfter(b.end)) {
        sum += tx.amount;
      }
    }
    return (sum * 100).roundToDouble() / 100;
  }).toList();

  final total = values.fold(0.0, (acc, v) => acc + v);
  final rangeText = switch (period) {
    ChartPeriod.daily => strings.last7d,
    ChartPeriod.weekly => strings.last6w,
    ChartPeriod.monthly => strings.last6m,
  };

  return ChartSeriesData(
    labels: buckets.map((b) => b.label).toList(),
    values: values,
    total: total,
    subtitle: rangeText,
  );
}
