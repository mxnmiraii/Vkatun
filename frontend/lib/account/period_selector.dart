import 'package:flutter/material.dart';
import 'package:vkatun/design/colors.dart';

class PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodSelected;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPeriodButton('День', 'day'),
        const SizedBox(width: 8),
        _buildPeriodButton('Неделя', 'week'),
        const SizedBox(width: 8),
        _buildPeriodButton('Месяц', 'month'),
      ],
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    return TextButton(
      onPressed: () => onPeriodSelected(period),
      child: Text(
        label,
        style: TextStyle(
          color: selectedPeriod == period ? timeColor : Colors.grey,
          fontWeight: selectedPeriod == period ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}