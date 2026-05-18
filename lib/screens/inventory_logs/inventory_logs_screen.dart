import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../model/response/response.dart';
import '../../provider/inventory_provider.dart';
import '../../widgets/advanced_data_table.dart';
import '../../widgets/debounced_search_input.dart';
import '../../widgets/filter_dropdown.dart';
import '../../widgets/page_header.dart';
import '../../widgets/skeletons.dart';

/// Brand-scoped inventory movement log.
/// Filters by reason / search and shows previous → new with delta.
class InventoryLogsScreen extends StatefulWidget {
  const InventoryLogsScreen({super.key});

  @override
  State<InventoryLogsScreen> createState() => _InventoryLogsScreenState();
}

class _InventoryLogsScreenState extends State<InventoryLogsScreen> {
  final _searchCtrl = TextEditingController();

  /// Locally-managed hidden-columns set so the column-toggle button can
  /// live inside the filter row alongside search and dropdowns — matches
  /// the admins screen behaviour.
  Set<String> _hiddenColumns = <String>{};

  static const _reasonLabels = <String, String>{
    'order_deduction': 'Order',
    'return_restock': 'Return',
    'manual_add': 'Manual add',
    'manual_reduce': 'Manual reduce',
    'adjustment': 'Adjustment',
    'initial_stock': 'Initial',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<InventoryProvider>().load(page: 1);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, p, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'Inventory History',
                subtitle: 'Every stock movement, with the reason and actor',
              ),
              const SizedBox(height: 20),
              _buildFilters(p),
              const SizedBox(height: 16),
              if (p.isLoading && p.items.isEmpty)
                const Expanded(child: TableSkeleton(rows: 8, columns: 6))
              else
                Expanded(child: _buildTable(p)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilters(InventoryProvider p) {
    final theme = ShadTheme.of(context);
    final hasFilters = p.reasonFilter != null;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Auto-debounced search using the shared widget.
          DebouncedSearchInput(
            controller: _searchCtrl,
            placeholder: 'Search product / SKU / note',
            width: 240,
            onSearch: p.setSearch,
          ),
          const SizedBox(width: 12),

          // Reason filter — values mapped to friendly labels via _reasonLabels.
          FilterDropdown<String>(
            placeholder: 'Reason',
            width: 180,
            value: p.reasonFilter ?? '',
            options: [
              const FilterOption(value: '', label: 'All Reasons'),
              ..._reasonLabels.entries.map(
                (e) => FilterOption(value: e.key, label: e.value),
              ),
            ],
            onChanged: (v) => p.setReason(v == null || v.isEmpty ? null : v),
          ),

          if (hasFilters) ...[
            const SizedBox(width: 12),
            ShadButton.ghost(
              size: ShadButtonSize.sm,
              onPressed: () {
                _searchCtrl.clear();
                p.clearFilters();
              },
              child: Text(
                'Clear All',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],

          const SizedBox(width: 12),
          // Column-visibility toggle, same icon as the table's built-in
          // toolbar but rendered here so it sits alongside the filters.
          ColumnVisibilityMenu<InventoryLog>(
            columns: _columnsFor(),
            hiddenColumns: _hiddenColumns,
            onChanged: (next) => setState(() => _hiddenColumns = next),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(InventoryProvider p) {
    return AdvancedDataTable<InventoryLog>(
      columns: _columnsFor(),
      hiddenColumns: _hiddenColumns,
      onHiddenColumnsChanged: (next) => setState(() => _hiddenColumns = next),
      showColumnToggle: false,
      items: p.items,
      idOf: (l) => l.id,
      currentPage: p.pagination?.currentPage ?? p.currentPage,
      totalPages: p.pagination?.totalPages ?? 1,
      totalItems: p.pagination?.totalItems ?? 0,
      itemLabel: 'movements',
      onPageChanged: (page) => p.load(page: page),
    );
  }

  /// Column definitions shared between [_buildTable] and the standalone
  /// [ColumnVisibilityMenu] in the filter row, so toggling a column in
  /// either place stays in sync.
  List<AdvancedTableColumn<InventoryLog>> _columnsFor() {
    return [
      AdvancedTableColumn<InventoryLog>(
        key: 'when',
        label: 'When',
        flex: 2,
        cellBuilder: (l, _) => Text(
          l.createdAt != null
              ? DateFormat(
                  'MMM dd, HH:mm',
                ).format(DateTime.parse(l.createdAt!).toLocal())
              : '-',
          style: ShadTheme.of(context).textTheme.muted.copyWith(fontSize: 12),
        ),
      ),
      AdvancedTableColumn<InventoryLog>(
        key: 'product',
        label: 'Product',
        flex: 4,
        cellBuilder: (l, _) {
          final theme = ShadTheme.of(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l.productName ?? '-',
                style: theme.textTheme.small,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (l.productSku != null || l.variantSku != null)
                Text(
                  [l.productSku, l.variantSku].whereType<String>().join(' / '),
                  style: theme.textTheme.muted.copyWith(fontSize: 11),
                ),
            ],
          );
        },
      ),
      AdvancedTableColumn<InventoryLog>(
        key: 'reason',
        label: 'Reason',
        flex: 2,
        cellBuilder: (l, _) => _ReasonBadge(reason: l.reason),
      ),
      AdvancedTableColumn<InventoryLog>(
        key: 'change',
        label: 'Change',
        flex: 2,
        cellBuilder: (l, _) => _StockChange(log: l),
      ),
      AdvancedTableColumn<InventoryLog>(
        key: 'actor',
        label: 'By',
        flex: 2,
        cellBuilder: (l, _) {
          final theme = ShadTheme.of(context);
          return Text(
            l.userName ?? '-',
            style: theme.textTheme.muted.copyWith(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
      AdvancedTableColumn<InventoryLog>(
        key: 'note',
        label: 'Note',
        flex: 3,
        cellBuilder: (l, _) {
          final theme = ShadTheme.of(context);
          return Text(
            l.note ?? '-',
            style: theme.textTheme.muted.copyWith(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
    ];
  }
}

class _ReasonBadge extends StatelessWidget {
  final String reason;
  const _ReasonBadge({required this.reason});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (reason) {
      case 'order_deduction':
        color = AppTheme.brand;
        break;
      case 'return_restock':
        color = AppTheme.successColor;
        break;
      case 'manual_add':
      case 'initial_stock':
        color = AppTheme.successColor;
        break;
      case 'manual_reduce':
        color = AppTheme.warningColor;
        break;
      default:
        color = AppTheme.infoColor;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        reason.replaceAll('_', ' '),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StockChange extends StatelessWidget {
  final InventoryLog log;
  const _StockChange({required this.log});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final delta = log.quantityChanged;
    final color = delta >= 0 ? AppTheme.successColor : AppTheme.dangerColor;
    return Row(
      children: [
        Text(
          '${log.previousStock}',
          style: theme.textTheme.muted.copyWith(fontSize: 12),
        ),
        const SizedBox(width: 4),
        Icon(
          LucideIcons.arrowRight,
          size: 12,
          color: theme.colorScheme.mutedForeground,
        ),
        const SizedBox(width: 4),
        Text(
          '${log.newStock}',
          style: theme.textTheme.small.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${delta >= 0 ? '+' : ''}$delta',
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
