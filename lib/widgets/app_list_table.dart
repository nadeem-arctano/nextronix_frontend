import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'data_table_pagination.dart';

/// Column definition for [AppListTable].
///
/// [key] is optional but required for columns to be toggleable via
/// [AppListTable.hiddenColumns]. When [hideable] is `false`, the column is
/// excluded from the visibility menu and is always shown.
class AppTableColumn {
  final String label;
  final int flex;
  final String? key;
  final bool hideable;

  const AppTableColumn({
    required this.label,
    this.flex = 1,
    this.key,
    this.hideable = true,
  });
}

/// Reusable list-style table widget using shadcn_ui styling.
///
/// Optionally supports column hiding via [hiddenColumns] (a set of column
/// keys). Row builders should query [AppListTable.isColumnHidden] to skip
/// rendering the corresponding cell so the row layout stays in sync with
/// the header.
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

  /// Set of [AppTableColumn.key] values that should be hidden from both
  /// the header and (via [isColumnHidden]) each row.
  final Set<String> hiddenColumns;

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
    this.hiddenColumns = const <String>{},
    this.selectedKeys,
    this.keyOf,
    this.onSelectionChanged,
  });

  bool get _selectable =>
      onSelectionChanged != null && keyOf != null && selectedKeys != null;

  /// Stack of hidden-column sets pushed while a row builder is executing.
  /// Used by [isColumnHidden] so screens can query the current table's
  /// hidden columns without needing a [BuildContext] that's below an
  /// inherited widget.
  ///
  /// Row builders run synchronously inside the table's `itemBuilder`, so
  /// reading the top of this stack at that moment yields the correct set.
  static final List<Set<String>> _hiddenStack = <Set<String>>[];

  /// Returns `true` when a column with [key] is hidden in the currently
  /// rendering [AppListTable]. Row builders should call this and skip the
  /// matching `Expanded` block so cells stay aligned with the header.
  ///
  /// The [context] argument is accepted for API consistency but is not
  /// actually required — the lookup uses a render-time stack instead of an
  /// inherited widget so it works even when the row builder closes over a
  /// context that lives above the table widget.
  static bool isColumnHidden(BuildContext context, String key) {
    if (_hiddenStack.isEmpty) return false;
    return _hiddenStack.last.contains(key);
  }

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

    final visibleCols = columns
        .where((c) => c.key == null || !hiddenColumns.contains(c.key))
        .toList();

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
                      ...visibleCols.map(
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
                      // Push the current hidden-columns set so any
                      // [isColumnHidden] calls made *during* the synchronous
                      // construction of the row widget tree see it. The pop
                      // in the finally block keeps the stack balanced even if
                      // a row builder throws.
                      _hiddenStack.add(hiddenColumns);
                      final Widget row;
                      try {
                        row = rowBuilder(item, index);
                      } finally {
                        _hiddenStack.removeLast();
                      }
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

/// Standalone column-visibility menu compatible with [AppListTable].
///
/// Same icon and popup behaviour as the menu used by `AdvancedDataTable`,
/// but designed to plug into the simpler `AppTableColumn` API: each
/// hideable column must declare a [AppTableColumn.key].
class AppListTableColumnMenu extends StatelessWidget {
  final List<AppTableColumn> columns;
  final Set<String> hiddenColumns;
  final ValueChanged<Set<String>> onChanged;
  final String tooltip;

  const AppListTableColumnMenu({
    super.key,
    required this.columns,
    required this.hiddenColumns,
    required this.onChanged,
    this.tooltip = 'Toggle columns',
  });

  @override
  Widget build(BuildContext context) {
    final hideable = columns.where((c) => c.hideable && c.key != null).toList();
    if (hideable.isEmpty) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      tooltip: tooltip,
      icon: const Icon(LucideIcons.columns3, size: 16),
      onSelected: (key) {
        final next = Set<String>.from(hiddenColumns);
        if (next.contains(key)) {
          next.remove(key);
        } else {
          next.add(key);
        }
        onChanged(next);
      },
      itemBuilder: (ctx) => hideable
          .map(
            (c) => CheckedPopupMenuItem<String>(
              value: c.key!,
              checked: !hiddenColumns.contains(c.key),
              child: Text(c.label),
            ),
          )
          .toList(),
    );
  }
}
