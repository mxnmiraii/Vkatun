import 'package:flutter/material.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/images.dart';

enum PeriodMode {
  day,
  week,
  month,
}

class PeriodSelector extends StatefulWidget {
  final void Function(DateTime from, DateTime to)? onPeriodChanged;

  const PeriodSelector({super.key, this.onPeriodChanged});

  @override
  _PeriodSelectorState createState() => _PeriodSelectorState();
}

class _PeriodSelectorState extends State<PeriodSelector> {
  DateTime currentDate = DateTime.now();
  PeriodMode periodMode = PeriodMode.week;

  // Маппинг для отображения русских названий периодов
  final Map<PeriodMode, String> periodLabels = {
    PeriodMode.day: 'День',
    PeriodMode.week: 'Неделя',
    PeriodMode.month: 'Месяц',
  };

  void _previousPeriod() {
    setState(() {
      currentDate = _getNewDate(-1);
      _notifyChange();
    });
  }

  void _nextPeriod() {
    setState(() {
      currentDate = _getNewDate(1);
      _notifyChange();
    });
  }

  void _notifyChange() {
    if (widget.onPeriodChanged != null) {
      final range = _getPeriodRange();
      widget.onPeriodChanged!(range.$1, range.$2);
    }
  }

  DateTime _getNewDate(int direction) {
    switch (periodMode) {
      case PeriodMode.day:
        return currentDate.add(Duration(days: direction));
      case PeriodMode.week:
        return currentDate.add(Duration(days: 7 * direction));
      case PeriodMode.month:
        return DateTime(currentDate.year, currentDate.month + direction, currentDate.day);
    }
  }

  (DateTime, DateTime) _getPeriodRange() {
    switch (periodMode) {
      case PeriodMode.day:
        return (currentDate, currentDate);
      case PeriodMode.week:
        final startOfWeek = currentDate.subtract(Duration(days: currentDate.weekday - 1));
        final endOfWeek = startOfWeek.add(Duration(days: 6));
        return (startOfWeek, endOfWeek);
      case PeriodMode.month:
        final firstDay = DateTime(currentDate.year, currentDate.month, 1);
        final lastDay = DateTime(currentDate.year, currentDate.month + 1, 0);
        return (firstDay, lastDay);
    }
  }

  String _getPeriodLabel() {
    final range = _getPeriodRange();
    final from = _formatDate(range.$1);
    final to = _formatDate(range.$2);
    return (from == to) ? from : "$from - $to";
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Переключение режима
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: PeriodMode.values.map((mode) {
            return TextButton(
              onPressed: () {
                setState(() {
                  periodMode = mode;
                  _notifyChange();
                });
              },
              child: Text(
                periodLabels[mode]!, // Используем русские названия
                style: TextStyle(
                  color: periodMode == mode ? timeColor : Colors.grey,
                  fontWeight: periodMode == mode ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
        // Навигация
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: timeArrowBack,
              onPressed: _previousPeriod,
            ),
            Text(
              _getPeriodLabel(),
              style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 16,
                  color: timeColor,
                  fontWeight: FontWeight.w800
              ),
            ),
            IconButton(
              icon: timeArrowForward,
              onPressed: _nextPeriod,
            ),
          ],
        ),
      ],
    );
  }
}