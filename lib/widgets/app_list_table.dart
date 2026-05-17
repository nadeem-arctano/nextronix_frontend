import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'data_table_pagination.dart';

/// Column definition for AppListTable
class AppTableColumn {
  final String label;
  final int flex;

  const AppTableColumn({required this.label, this.flex = 1});
}

/// Reusable list-style table widget using shadcn_ui styling
class AppListTable<T> extends StatelessWidget {
  final List<AppTableColumn> columns;
  final List<T> items;
  final Widget Function(T item, int index) rowBuilder;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final String itemLabel;
  final ValueChanged<int> onPageChanged;
  final double trailingWidth;

  /// Optional row selection. When [onSelectionChanged] is provided, a leading
  /// checkbox column is rendered both in the header (toggles all-on-page) and
  /// each row. The widget is purely controlled — pass [selectedKeys] from
  /// state and update it inside [onSelectionChanged].
  final Set<int>? selectedKeys;
  final int Function(T item)? keyOf;
  final ValueChanged<Set<int>>? onSelectionChanged;

  const AppListTable({
    super.key,
    required this.columns,
    required this.items,
    required this.rowBuilder,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemLabel,
    required this.onPageChanged,
    this.trailingWidth = 40,
    this.selectedKeys,
    this.keyOf,
    this.onSelectionChanged,
  });

  bool get _selectable =>
      onSelectionChanged != null && keyOf != null && selectedKeys != null;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final allKeys = _selectable ? items.map(keyOf!).toSet() : <int>{};
    final allSelected =
        _selectable &&
        allKeys.isNotEmpty &&
        allKeys.every(selectedKeys!.contains);
    final someSelected =
        _selectable && allKeys.any(selectedKeys!.contains) && !allSelected;

    return ShadCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                // Header row
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.muted.withValues(alpha: 0.3),
                    border: Border(
                      bottom: BorderSide(color: theme.colorScheme.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (_selectable)
                        SizedBox(
                          width: 32,
                          child: Checkbox(
                            value: allSelected
                                ? true
                                : (someSelected ? null : false),
                            tristate: true,
                            onChanged: (v) {
                              final next = Set<int>.from(selectedKeys!);
                              if (v == true) {
                                next.addAll(allKeys);
                              } else {
                                next.removeAll(allKeys);
                              }
                              onSelectionChanged!(next);
                            },
                          ),
                        ),
                      ...columns.map(
                        (col) => Expanded(
                          flex: col.flex,
                          child: Text(
                            col.label.toUpperCase(),
                            style: theme.textTheme.muted.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: trailingWidth),
                    ],
                  ),
                ),

                // Rows
                Expanded(
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: theme.colorScheme.border),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final row = rowBuilder(item, index);
                      if (!_selectable) return row;
                      final id = keyOf!(item);
                      final isOn = selectedKeys!.contains(id);
                      return Row(
                        children: [
                          SizedBox(
                            width: 32,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Checkbox(
                                value: isOn,
                                onChanged: (v) {
                                  final next = Set<int>.from(selectedKeys!);
                                  if (v == true) {
                                    next.add(id);
                                  } else {
                                    next.remove(id);
                                  }
                                  onSelectionChanged!(next);
                                },
                              ),
                            ),
                          ),
                          Expanded(child: row),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Pagination
          Divider(height: 1, color: theme.colorScheme.border),
          DataTablePagination(
            currentPage: currentPage,
            totalPages: totalPages,
            totalItems: totalItems,
            showingCount: items.length,
            itemLabel: itemLabel,
            onPageChanged: onPageChanged,
          ),
        ],
      ),
    );
  }
}
