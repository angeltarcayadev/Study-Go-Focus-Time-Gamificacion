import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class GitHubContributionGraph extends StatefulWidget {
  final Map<DateTime, int> contributions;
  final int pageIndex; // 0 o 1, controla el cuatrimestre

  const GitHubContributionGraph({
    super.key,
    required this.contributions,
    required this.pageIndex,
  });

  @override
  State<GitHubContributionGraph> createState() =>
      _GitHubContributionGraphState();
}

class _GitHubContributionGraphState extends State<GitHubContributionGraph> {
  final ScrollController _scrollController = ScrollController();
  OverlayEntry? _tooltipOverlay;

  DateTime? selectedDay; // ← Para saber qué cuadro está seleccionado

  static const double _boxSize = 12.0;
  static const double _boxMargin = 2.0;

  final List<Color> levelColors = [
    const Color(0xFF434242),
    const Color(0xFF9BE9A8),
    const Color(0xFF40C463),
    const Color(0xFF30A14E),
    const Color(0xFF216E39),
  ];

  Color getColor(int value) {
    if (value == 0) return levelColors[0];
    if (value <= 3) return levelColors[1];
    if (value <= 7) return levelColors[2];
    if (value <= 11) return levelColors[3];
    return levelColors[4];
  }

  void _showTooltip(BuildContext context, DateTime date, int value, GlobalKey key) {
    _hideTooltip();

    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);

    _tooltipOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx - 50 + _boxSize / 2,
        top: offset.dy - 45,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2E3340),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMM d, yyyy', 'es_ES').format(date),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "$value sesión${value == 1 ? '' : 'es'}",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_tooltipOverlay!);

    Future.delayed(const Duration(seconds: 5), () => _hideTooltip());
  }

  void _hideTooltip() {
    _tooltipOverlay?.remove();
    _tooltipOverlay = null;
  }

  List<DateTime> _getCuatrimestreDates() {
    final now = DateTime.now();
    final currentMonth = now.month;

    int startMonth = widget.pageIndex == 0
        ? currentMonth
        : (currentMonth + 4 > 12 ? currentMonth - 8 : currentMonth + 4);

    List<DateTime> days = [];

    for (int m = 0; m < 4; m++) {
      int month = startMonth + m;
      int year = now.year;

      if (month > 12) {
        month -= 12;
        year += 1;
      }

      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0);

      for (int d = 0; d < lastDay.day; d++) {
        days.add(firstDay.add(Duration(days: d)));
      }
    }

    return days;
  }

  List<List<DateTime>> _groupWeeks(List<DateTime> days) {
    List<List<DateTime>> weeks = [];
    for (int i = 0; i < days.length; i += 7) {
      weeks.add(days.sublist(i, min(i + 7, days.length)));
    }
    return weeks;
  }

  List<String> _getMonthLabels(List<DateTime> days) {
    final labels = <String>{};
    for (var d in days) {
      labels.add(DateFormat.MMM().format(d));
    }
    return labels.toList();
  }

  @override
  Widget build(BuildContext context) {
    final days = _getCuatrimestreDates();
    final weeks = _groupWeeks(days);
    final monthLabels = _getMonthLabels(days);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
          child: Row(
            children: monthLabels
                .map((m) => Expanded(
              child: Text(
                m,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ))
                .toList(),
          ),
        ),
        const SizedBox(height: 4),

        // ───────────────────────────────────────────────
        // GRID
        // ───────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: weeks.map((week) {
              return Column(
                children: week.map((day) {
                  final key = GlobalKey();
                  final count = widget.contributions[day] ?? 0;

                  final isSelected = selectedDay == day;

                  return GestureDetector(
                    key: key,
                    onTapDown: (_) {
                      setState(() => selectedDay = day);
                      _showTooltip(context, day, count, key);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.all(_boxMargin),
                      width: _boxSize,
                      height: _boxSize,
                      decoration: BoxDecoration(
                        color: getColor(count),
                        borderRadius: BorderRadius.circular(3),

                        // ⭐ Glow visual si está seleccionado
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.8),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ]
                            : [],
                      ),
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}