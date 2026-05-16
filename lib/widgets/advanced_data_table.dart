import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../core/theme/app_theme.dart';
import 'data_table_pagination.dart';

/// Sort direction.
enum SortOrder { asc, desc }

/// State of a sortable column.
class SortState {
  final String columnKey;
  final SortOrder order;
  const SortState(this.columnKey, this.order);

  SortState toggle(String key) {
    if (key != columnKey) return SortState(key, SortOrder.asc);
    return SortState(
      key,
      order == SortOrder.asc ? SortOrder.desc : SortOrder.asc,
    );
  }
}

/// Column definition for AdvancedDataTable.
class AdvancedTableColumn<T> {
  final String key;
  final String label;
  final int flex;
  final bool sortable;
  final bool hideable;
  final TextAlign align;

  /// Cell renderer for the row data.
  final Widget Function(T item, int rowIndex) cellBuilder;

  AdvancedTableColumn({
    required this.key,
    required this.label,
    required this.cellBuilder,
    this.flex = 1,
    this.sortable = false,
    this.hideable = true,
    this.align = TextAlign.left,
  });
}

/// Advanced, reusable data table with:
/// - sortable columns (driven by parent — UI fires onSort)
/// - column visibility toggle
/// - row selection + bulk action bar
/// - sticky header row
/// - integrated pagination
///
/// Selection is opt-in: pass `selectable: true` to render checkboxes. The
/// parent owns the selected ID set so it can survive page changes.
class AdvancedDataTable<T> extends StatefulWidget {
  final List<AdvancedTableColumn<T>> columns;
  final List<T> items;
  final Object Function(T item) idOf;

  // Pagination
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final String itemLabel;
  final ValueChanged<int> onPageChanged;

  // Sorting
  final SortState? sortState;
  final ValueChanged<SortState>? onSortChanged;

  // Selection
  final bool selectable;
  final Set<Object>? selectedIds;
  final ValueChanged<Set<Object>>? onSelectionChanged;

  // Bulk-actions bar
  final List<BulkAction>? bulkActions;

  final EdgeInsetsGeometry rowPadding;

  const AdvancedDataTable({
    super.key,
    required this.columns,
    required this.items,
    required this.idOf,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.onPageChanged,
    this.itemLabel = 'items',
    this.sortState,
    this.onSortChanged,
    this.selectable = false,
    this.selectedIds,
    this.onSelectionChanged,
    this.bulkActions,
    this.rowPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  });

  @override
  State<AdvancedDataTable<T>> createState() => _AdvancedDataTableState<T>();
}

class _AdvancedDataTableState<T> extends State<AdvancedDataTable<T>> {
  late Set<String> _hiddenColumns;

  @override
  void initState() {
    super.initState();
    _hiddenColumns = <String>{};
  }

  bool _isVisible(AdvancedTableColumn<T> col) =>
      !_hiddenColumns.contains(col.key);

  void _toggleColumn(String key) {
    setState(() {
      if (_hiddenColumns.contains(key)) {
        _hiddenColumns.remove(key);
      } else {
        _hiddenColumns.add(key);
      }
    });
  }

  Set<Object> _selected() => widget.selectedIds ?? <Object>{};

  void _toggleAllOnPage(bool? checked) {
    final next = Set<Object>.from(_selected());
    final pageIds = widget.items.map(widget.idOf).toSet();
    if (checked == true) {
      next.addAll(pageIds);
    } else {
      next.removeAll(pageIds);
    }
    widget.onSelectionChanged?.call(next);
  }

  void _toggleOne(Object id) {
    final next = Set<Object>.from(_selected());
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    widget.onSelectionChanged?.call(next);
  }

  bool? _allOnPageSelected() {
    if (widget.items.isEmpty) return false;
    final selected = _selected();
    final pageIds = widget.items.map(widget.idOf).toSet();
    final hits = pageIds.where(selected.contains).length;
    if (hits == 0) return false;
    if (hits == pageIds.length) return true;
    return null; // tri-state
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final visibleCols = widget.columns.where(_isVisible).toList();

    return ShadCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Top toolbar (selection summary + bulk actions + column toggle)
          _Toolbar(
            selectedCount: _selected().length,
            onClearSelection: widget.selectable
                ? () => widget.onSelectionChanged?.call({})
                : null,
            bulkActions: widget.bulkActions,
            allColumns: widget.columns,
            hiddenColumns: _hiddenColumns,
            onToggleColumn: _toggleColumn,
          ),

          // Header row (sticky inside the card)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.muted.withValues(alpha: 0.3),
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.border),
              ),
            ),
            child: Row(
              children: [
                if (widget.selectable)
                  SizedBox(
                    width: 40,
                    child: Checkbox(
                      tristate: true,
                      value: _allOnPageSelected(),
                      onChanged: _toggleAllOnPage,
                    ),
                  ),
                ...visibleCols.map(
                  (col) => Expanded(
                    flex: col.flex,
                    child: _HeaderCell(
                      label: col.label,
                      align: col.align,
                      sortable: col.sortable,
                      sortOrder: widget.sortState?.columnKey == col.key
                          ? widget.sortState?.order
                          : null,
                      onTap: col.sortable && widget.onSortChanged != null
                          ? () {
                              final next = widget.sortState != null
                                  ? widget.sortState!.toggle(col.key)
                                  : SortState(col.key, SortOrder.asc);
                              widget.onSortChanged!(next);
                            }
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Rows
          Expanded(
            child: widget.items.isEmpty
                ? _EmptyRow(theme: theme)
                : ListView.separated(
                    itemCount: widget.items.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: theme.colorScheme.border),
                    itemBuilder: (_, i) {
                      final item = widget.items[i];
                      final id = widget.idOf(item);
                      final isSelected = _selected().contains(id);
                      return InkWell(
                        onTap: widget.selectable ? () => _toggleOne(id) : null,
                        child: Padding(
                          padding: widget.rowPadding,
                          child: Row(
                            children: [
                              if (widget.selectable)
                                SizedBox(
                                  width: 40,
                                  child: Checkbox(
                                    value: isSelected,
                                    onChanged: (_) => _toggleOne(id),
                                  ),
                                ),
                              ...visibleCols.map(
                                (col) => Expanded(
                                  flex: col.flex,
                                  child: Align(
                                    alignment: col.align == TextAlign.right
                                        ? Alignment.centerRight
                                        : col.align == TextAlign.center
                                        ? Alignment.center
                                        : Alignment.centerLeft,
                                    child: col.cellBuilder(item, i),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          Divider(height: 1, color: theme.colorScheme.border),
          DataTablePagination(
            currentPage: widget.currentPage,
            totalPages: widget.totalPages,
            totalItems: widget.totalItems,
            showingCount: widget.items.length,
            itemLabel: widget.itemLabel,
            onPageChanged: widget.onPageChanged,
          ),
        ],
      ),
    );
  }
}

/// Bulk action descriptor used by the toolbar action menu.
class BulkAction {
  final String label;
  final IconData icon;
  final bool destructive;
  final Future<void> Function(Set<Object> ids) onPressed;

  BulkAction({
    required this.label,
    required this.icon,
    this.destructive = false,
    required this.onPressed,
  });
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final TextAlign align;
  final bool sortable;
  final SortOrder? sortOrder;
  final VoidCallback? onTap;

  const _HeaderCell({
    required this.label,
    required this.align,
    required this.sortable,
    required this.sortOrder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final text = Text(
      label.toUpperCase(),
      style: theme.textTheme.muted.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );

    if (!sortable) return _alignWidget(text);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: _alignWidget(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              text,
              const SizedBox(width: 4),
              Icon(
                sortOrder == SortOrder.asc
                    ? LucideIcons.arrowUp
                    : sortOrder == SortOrder.desc
                    ? LucideIcons.arrowDown
                    : LucideIcons.arrowUpDown,
                size: 12,
                color: sortOrder != null
                    ? theme.colorScheme.foreground
                    : theme.colorScheme.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _alignWidget(Widget child) => Align(
    alignment: align == TextAlign.right
        ? Alignment.centerRight
        : align == TextAlign.center
        ? Alignment.center
        : Alignment.centerLeft,
    child: child,
  );
}

class _Toolbar<T> extends StatelessWidget {
  final int selectedCount;
  final VoidCallback? onClearSelection;
  final List<BulkAction>? bulkActions;
  final List<AdvancedTableColumn<T>> allColumns;
  final Set<String> hiddenColumns;
  final ValueChanged<String> onToggleColumn;

  const _Toolbar({
    required this.selectedCount,
    required this.onClearSelection,
    required this.bulkActions,
    required this.allColumns,
    required this.hiddenColumns,
    required this.onToggleColumn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final hasSelection = selectedCount > 0;
    if (!hasSelection && !_anyHideable()) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: hasSelection
            ? AppTheme.brand.withValues(alpha: 0.06)
            : theme.colorScheme.background,
        border: Border(bottom: BorderSide(color: theme.colorScheme.border)),
      ),
      child: Row(
        children: [
          if (hasSelection) ...[
            Icon(LucideIcons.checkCheck, size: 14, color: AppTheme.brand),
            const SizedBox(width: 6),
            Text(
              '$selectedCount selected',
              style: theme.textTheme.small.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: onClearSelection,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                minimumSize: const Size(0, 28),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Clear',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ),
            const Spacer(),
            if (bulkActions != null)
              for (final a in bulkActions!) ...[
                _bulkActionButton(context, a),
                const SizedBox(width: 6),
              ],
          ] else
            const Spacer(),
          if (_anyHideable()) _columnsMenu(context),
        ],
      ),
    );
  }

  bool _anyHideable() => allColumns.any((c) => c.hideable);

  Widget _bulkActionButton(BuildContext context, BulkAction a) {
    if (a.destructive) {
      return ShadButton.outline(
        leading: Icon(a.icon, size: 14),
        onPressed: () async {
          // Snapshot ids; parent should clear selection in its callback.
          final ids =
              (context
                  .findAncestorStateOfType<_AdvancedDataTableState>()
                  ?._selected()) ??
              <Object>{};
          await a.onPressed(Set<Object>.from(ids));
        },
        child: Text(a.label),
      );
    }
    return ShadButton.outline(
      leading: Icon(a.icon, size: 14),
      onPressed: () async {
        final ids =
            (context
                .findAncestorStateOfType<_AdvancedDataTableState>()
                ?._selected()) ??
            <Object>{};
        await a.onPressed(Set<Object>.from(ids));
      },
      child: Text(a.label),
    );
  }

  Widget _columnsMenu(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Toggle columns',
      icon: const Icon(LucideIcons.columns3, size: 16),
      onSelected: onToggleColumn,
      itemBuilder: (ctx) => allColumns
          .where((c) => c.hideable)
          .map(
            (c) => CheckedPopupMenuItem<String>(
              value: c.key,
              checked: !hiddenColumns.contains(c.key),
              child: Text(c.label),
            ),
          )
          .toList(),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  final ShadThemeData theme;
  const _EmptyRow({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.inbox,
              size: 36,
              color: theme.colorScheme.mutedForeground,
            ),
            const SizedBox(height: 10),
            Text('No records found', style: theme.textTheme.muted),
          ],
        ),
      ),
    );
  }
}
