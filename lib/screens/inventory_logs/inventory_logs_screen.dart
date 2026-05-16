import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../model/response/response.dart';
import '../../provider/inventory_provider.dart';
import '../../widgets/advanced_data_table.dart';
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
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        SizedBox(
          width: 240,
          child: TextField(
            controller: _searchCtrl,
            onSubmitted: p.setSearch,
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.search, size: 16),
              hintText: 'Search product / SKU / note',
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.colorScheme.border),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 200,
          child: DropdownButtonFormField<String>(
            initialValue: p.reasonFilter,
            isDense: true,
            decoration: InputDecoration(
              labelText: 'Reason',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            items: [
              const DropdownMenuItem<String>(value: null, child: Text('All')),
              ..._reasonLabels.entries.map(
                (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
              ),
            ],
            onChanged: p.setReason,
          ),
        ),
        ShadButton.outline(
          leading: const Icon(LucideIcons.x, size: 14),
          onPressed: p.clearFilters,
          child: const Text('Reset'),
        ),
      ],
    );
  }

  Widget _buildTable(InventoryProvider p) {
    return AdvancedDataTable<InventoryLog>(
      columns: [
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
                    [
                      l.productSku,
                      l.variantSku,
                    ].whereType<String>().join(' / '),
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
      ],
      items: p.items,
      idOf: (l) => l.id,
      currentPage: p.pagination?.currentPage ?? p.currentPage,
      totalPages: p.pagination?.totalPages ?? 1,
      totalItems: p.pagination?.totalItems ?? 0,
      itemLabel: 'movements',
      onPageChanged: (page) => p.load(page: page),
    );
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
