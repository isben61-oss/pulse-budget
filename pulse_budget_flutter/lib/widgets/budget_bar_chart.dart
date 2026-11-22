import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/currencies.dart';
import '../utils/formatters.dart';

enum BarColorMode { balance, spending, earnings }

class BudgetBarChart extends StatefulWidget {
  final List<String> labels;
  final List<double> values;
  final BarColorMode colorMode;
  final CurrencyInfo currency;
  final bool darkMode;

  const BudgetBarChart({
    super.key,
    required this.labels,
    required this.values,
    required this.colorMode,
    required this.currency,
    this.darkMode = false,
  });

  @override
  State<BudgetBarChart> createState() => _BudgetBarChartState();
}

class _BudgetBarChartState extends State<BudgetBarChart> {
  int? _selectedIndex;

  void _handleTap(Offset localPosition, double width) {
    const padLeft = 50.0;
    const padRight = 10.0;
    final plotW = width - padLeft - padRight;
    if (plotW <= 0 || widget.labels.isEmpty) return;

    final relX = localPosition.dx - padLeft;
    if (relX < 0 || relX > plotW) {
      setState(() => _selectedIndex = null);
      return;
    }

    final slotW = plotW / widget.labels.length;
    final idx = (relX / slotW).floor().clamp(0, widget.labels.length - 1);
    setState(() {
      _selectedIndex = _selectedIndex == idx ? null : idx;
    });
  }

  @override
  void didUpdateWidget(covariant BudgetBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.labels.length != widget.labels.length) {
      _selectedIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) =>
                    _handleTap(d.localPosition, constraints.maxWidth),
                child: CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _BarChartPainter(
                    labels: widget.labels,
                    values: widget.values,
                    colorMode: widget.colorMode,
                    selectedIndex: _selectedIndex,
                    currency: widget.currency,
                    darkMode: widget.darkMode,
                  ),
                ),
              ),
              if (_selectedIndex != null &&
                  _selectedIndex! < widget.labels.length)
                Positioned(
                  top: 4,
                  right: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: widget.darkMode ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${widget.labels[_selectedIndex!]} · ${formatMoney(widget.values[_selectedIndex!], widget.currency)}',
                      style: TextStyle(
                        color: widget.darkMode ? const Color(0xFF0F172A) : Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<String> labels;
  final List<double> values;
  final BarColorMode colorMode;
  final int? selectedIndex;
  final CurrencyInfo currency;
  final bool darkMode;

  const _BarChartPainter({
    required this.labels,
    required this.values,
    required this.colorMode,
    required this.selectedIndex,
    required this.currency,
    required this.darkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padTop = 20.0;
    const padRight = 10.0;
    const padBottom = 26.0;
    final plotH = size.height - padTop - padBottom;
    if (plotH <= 0 || labels.isEmpty) return;

    double maxVal = values.fold(0.0, (m, v) => math.max(m, v));
    double minVal = values.fold(0.0, (m, v) => math.min(m, v));
    if (maxVal == 0 && minVal == 0) {
      maxVal = 100;
    } else {
      final span = maxVal - minVal;
      if (maxVal > 0) maxVal += span * 0.12;
      if (minVal < 0) minVal -= span * 0.12;
    }

    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);
    double valueToY(double v) => padTop + ((maxVal - v) / range) * plotH;
    final zeroY = valueToY(0);

    // Measure Y-axis labels dynamically so multi-char currencies never clip
    const steps = 4;
    final tickPainters = <(double, TextPainter)>[];
    double maxTickWidth = 36.0;
    for (int i = 0; i <= steps; i++) {
      final val = minVal + (range * i) / steps;
      final tp = TextPainter(
        text: TextSpan(
          text: formatCompactMoney(val, currency),
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      if (tp.width > maxTickWidth) maxTickWidth = tp.width;
      tickPainters.add((val, tp));
    }

    final padLeft = maxTickWidth + 14.0;
    final plotW = size.width - padLeft - padRight;
    if (plotW <= 0) return;

    for (final entry in tickPainters) {
      final val = entry.$1;
      final tp = entry.$2;
      final y = valueToY(val);
      final isZero = val.abs() < 1e-6;
      final gridPaint = Paint()
        ..color = isZero ? (darkMode ? const Color(0xFF475569) : const Color(0xFFCBD5E1)) : (darkMode ? const Color(0xFF263449) : const Color(0xFFF1F5F9))
        ..strokeWidth = 1;
      canvas.drawLine(Offset(padLeft, y), Offset(size.width - padRight, y), gridPaint);
      tp.paint(canvas, Offset(padLeft - tp.width - 8, y - tp.height / 2));
    }

    // Bars and X-axis labels
    final slotW = plotW / labels.length;
    final barW = math.min(30.0, math.max(12.0, slotW * 0.56));

    for (int i = 0; i < labels.length; i++) {
      final v = values[i];
      final cx = padLeft + slotW * i + slotW / 2;
      final bx = cx - barW / 2;
      final by = valueToY(v);
      final isSel = selectedIndex == i;

      Color fill;
      switch (colorMode) {
        case BarColorMode.spending:
          fill = isSel ? const Color(0xFFBE123C) : const Color(0xFFF43F5E);
          break;
        case BarColorMode.earnings:
          fill = isSel ? const Color(0xFF047857) : const Color(0xFF10B981);
          break;
        case BarColorMode.balance:
          if (v < 0) {
            fill = isSel ? const Color(0xFFBE123C) : const Color(0xFFF43F5E);
          } else {
            fill = isSel ? const Color(0xFF1D4ED8) : const Color(0xFF2563EB);
          }
          break;
      }

      final barPaint = Paint()..color = fill;
      if (v > 0) {
        final h = math.max(2.0, zeroY - by);
        final rect = RRect.fromRectAndCorners(
          Rect.fromLTWH(bx, by, barW, h),
          topLeft: const Radius.circular(6),
          topRight: const Radius.circular(6),
        );
        canvas.drawRRect(rect, barPaint);
      } else if (v < 0) {
        final h = math.max(2.0, by - zeroY);
        final rect = RRect.fromRectAndCorners(
          Rect.fromLTWH(bx, zeroY, barW, h),
          bottomLeft: const Radius.circular(6),
          bottomRight: const Radius.circular(6),
        );
        canvas.drawRRect(rect, barPaint);
      } else {
        canvas.drawRect(
          Rect.fromLTWH(bx, zeroY - 2, barW, 2),
          Paint()..color = darkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        );
      }

      final xtp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: isSel ? (darkMode ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A)) : (darkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            fontSize: 11,
            fontWeight: isSel ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      xtp.paint(canvas, Offset(cx - xtp.width / 2, size.height - padBottom + 8));
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.labels != labels ||
        oldDelegate.values != values ||
        oldDelegate.colorMode != colorMode ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.currency.code != currency.code ||
        oldDelegate.darkMode != darkMode;
  }
}
