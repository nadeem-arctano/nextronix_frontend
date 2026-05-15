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
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
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
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: theme.colorScheme.border),
                    itemBuilder: (context, index) {
                      return rowBuilder(items[index], index);
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
