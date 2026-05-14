import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'data_table_pagination.dart';

/// Column definition for AppListTable
class AppTableColumn {
  final String label;
  final int flex;

  const AppTableColumn({required this.label, this.flex = 1});
}

/// Reusable list-style table widget (no box/card, white bg, divider rows)
/// Used across Orders, Users, Products screens for consistent UI.
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
    return Column(
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
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppTheme.borderColor),
                  ),
                ),
                child: Row(
                  children: [
                    ...columns.map(
                      (col) => Expanded(
                        flex: col.flex,
                        child: Text(
                          col.label.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
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
                      const Divider(height: 1, color: AppTheme.dividerColor),
                  itemBuilder: (context, index) {
                    return rowBuilder(items[index], index);
                  },
                ),
              ),
            ],
          ),
        ),

        // Pagination
        DataTablePagination(
          currentPage: currentPage,
          totalPages: totalPages,
          totalItems: totalItems,
          showingCount: items.length,
          itemLabel: itemLabel,
          onPageChanged: onPageChanged,
        ),
      ],
    );
  }
}
