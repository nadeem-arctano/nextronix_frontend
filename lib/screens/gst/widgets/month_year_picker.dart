import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MonthYearPicker extends StatelessWidget {
  final int selectedMonth;
  final int selectedYear;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onYearChanged;

  const MonthYearPicker({
    super.key,
    required this.selectedMonth,
    required this.selectedYear,
    required this.onMonthChanged,
    required this.onYearChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final months = const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final currentYear = DateTime.now().year;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedMonth,
              isDense: true,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              items: List.generate(
                12,
                (i) => DropdownMenuItem(value: i + 1, child: Text(months[i])),
              ),
              onChanged: (v) {
                if (v != null) onMonthChanged(v);
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedYear,
              isDense: true,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              items: List.generate(
                5,
                (i) => DropdownMenuItem(
                  value: currentYear - i,
                  child: Text((currentYear - i).toString()),
                ),
              ),
              onChanged: (v) {
                if (v != null) onYearChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}
