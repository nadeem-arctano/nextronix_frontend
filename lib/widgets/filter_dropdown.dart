import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A single option for [FilterDropdown].
class FilterOption<T> {
  final T value;
  final String label;
  const FilterOption({required this.value, required this.label});
}

/// A small wrapper around [ShadSelect] that gives every filter dropdown in
/// the app a consistent look and behaviour.
///
/// Replaces the repeated `SizedBox(width: …, child: ShadSelect<…>(…))` blocks
/// found across the products, users and admins screens.
///
/// Example:
/// ```dart
/// FilterDropdown<String>(
///   placeholder: 'Status',
///   value: provider.statusFilter,
///   options: const [
///     FilterOption(value: '', label: 'All'),
///     FilterOption(value: 'active', label: 'Active'),
///     FilterOption(value: 'blocked', label: 'Blocked'),
///   ],
///   onChanged: provider.setStatusFilter,
/// )
/// ```
class FilterDropdown<T> extends StatelessWidget {
  /// Placeholder shown when no value is selected.
  final String placeholder;

  /// Currently selected value. May be `null`.
  final T? value;

  /// Options displayed in the dropdown.
  final List<FilterOption<T>> options;

  /// Called when the user selects a new value. Empty/null values are passed
  /// through unchanged so callers can decide whether to treat them as "all".
  final ValueChanged<T?> onChanged;

  /// Field width. Defaults to 160.
  final double width;

  const FilterDropdown({
    super.key,
    required this.placeholder,
    required this.value,
    required this.options,
    required this.onChanged,
    this.width = 160,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ShadSelect<T>(
        placeholder: Text(placeholder),
        initialValue: value,
        options: [
          for (final opt in options)
            ShadOption<T>(value: opt.value, child: Text(opt.label)),
        ],
        selectedOptionBuilder: (context, selected) {
          final match = options.where((o) => o.value == selected).firstOrNull;
          return Text(match?.label ?? placeholder);
        },
        onChanged: onChanged,
      ),
    );
  }
}
