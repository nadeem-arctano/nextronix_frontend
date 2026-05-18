import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../model/response/response.dart';
import '../../provider/return_provider.dart';
import '../../widgets/app_list_table.dart';
import '../../widgets/debounced_search_input.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/page_header.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/skeletons.dart';

class ReturnsListScreen extends StatefulWidget {
  const ReturnsListScreen({super.key});

  @override
  State<ReturnsListScreen> createState() => _ReturnsListScreenState();
}

class _ReturnsListScreenState extends State<ReturnsListScreen> {
  final _searchController = TextEditingController();

  /// Locally-managed hidden-columns set for the column-toggle button.
  Set<String> _hiddenColumns = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final p = context.read<ReturnProvider>();
      p.loadStats();
      p.loadReturns();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReturnProvider>(
      builder: (context, p, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'Return Requests',
                subtitle: 'Manage product returns and refunds',
              ),
              const SizedBox(height: 20),
              if (p.stats != null) _buildStats(p.stats!),
              const SizedBox(height: 16),
              _buildFilters(p),
              const SizedBox(height: 16),
              Expanded(
                child: p.isLoading && p.returns.isEmpty
                    ? const TableSkeleton(rows: 8, columns: 5)
                    : p.returns.isEmpty
                    ? const EmptyWidget(message: 'No return requests')
                    : AppListTable<ReturnRequest>(
                        columns: const [
                          AppTableColumn(
                            key: 'return_number',
                            label: 'Return #',
                            flex: 2,
                          ),
                          AppTableColumn(key: 'order', label: 'Order', flex: 2),
                          AppTableColumn(
                            key: 'customer',
                            label: 'Customer',
                            flex: 3,
                          ),
                          AppTableColumn(
                            key: 'reason',
                            label: 'Reason',
                            flex: 3,
                          ),
                          AppTableColumn(
                            key: 'refund',
                            label: 'Refund',
                            flex: 2,
                          ),
                          AppTableColumn(
                            key: 'status',
                            label: 'Status',
                            flex: 2,
                          ),
                          AppTableColumn(key: 'date', label: 'Date', flex: 2),
                        ],
                        hiddenColumns: _hiddenColumns,
                        items: p.returns,
                        currentPage: p.currentPage,
                        totalPages: p.pagination?.totalPages ?? 1,
                        totalItems: p.pagination?.totalItems ?? 0,
                        itemLabel: 'returns',
                        onPageChanged: (page) => p.loadReturns(page: page),
                        rowBuilder: (r, _) => _buildRow(r),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStats(ReturnStats s) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            'Total',
            s.totalReturns.toString(),
            const Color(0xFF4F46E5),
            LucideIcons.refreshCw,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            'Pending',
            s.pendingReturns.toString(),
            const Color(0xFFF59E0B),
            LucideIcons.clock,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            'Approved',
            s.approvedReturns.toString(),
            const Color(0xFF059669),
            LucideIcons.circleCheck,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            'Refunded',
            '₹${s.totalRefundAmount.toStringAsFixed(0)}',
            const Color(0xFF10B981),
            LucideIcons.indianRupee,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            'Rejected',
            s.rejectedReturns.toString(),
            const Color(0xFFDC2626),
            LucideIcons.circleX,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    final theme = ShadTheme.of(context);
    return ShadCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.h4.copyWith(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: theme.textTheme.muted.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(ReturnProvider p) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          DebouncedSearchInput(
            controller: _searchController,
            placeholder: 'Search returns...',
            initialValue: p.search,
            onSearch: p.setSearch,
          ),
          const SizedBox(width: 12),
          _chip('All', null, p.statusFilter, p.setStatusFilter),
          const SizedBox(width: 6),
          _chip('Requested', 'requested', p.statusFilter, p.setStatusFilter),
          const SizedBox(width: 6),
          _chip('Approved', 'approved', p.statusFilter, p.setStatusFilter),
          const SizedBox(width: 6),
          _chip('Rejected', 'rejected', p.statusFilter, p.setStatusFilter),
          const SizedBox(width: 6),
          _chip('Refunded', 'refunded', p.statusFilter, p.setStatusFilter),
          const SizedBox(width: 6),
          _chip('Completed', 'completed', p.statusFilter, p.setStatusFilter),
          const SizedBox(width: 12),
          AppListTableColumnMenu(
            columns: const [
              AppTableColumn(key: 'return_number', label: 'Return #'),
              AppTableColumn(key: 'order', label: 'Order'),
              AppTableColumn(key: 'customer', label: 'Customer'),
              AppTableColumn(key: 'reason', label: 'Reason'),
              AppTableColumn(key: 'refund', label: 'Refund'),
              AppTableColumn(key: 'status', label: 'Status'),
              AppTableColumn(key: 'date', label: 'Date'),
            ],
            hiddenColumns: _hiddenColumns,
            onChanged: (next) => setState(() => _hiddenColumns = next),
          ),
        ],
      ),
    );
  }

  Widget _chip(
    String label,
    String? value,
    String? current,
    ValueChanged<String?> onTap,
  ) {
    final theme = ShadTheme.of(context);
    final selected = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected
                ? theme.colorScheme.primaryForeground
                : theme.colorScheme.mutedForeground,
          ),
        ),
      ),
    );
  }

  Widget _buildRow(ReturnRequest r) {
    final theme = ShadTheme.of(context);
    return InkWell(
      onTap: () => context.go('/admin/returns/${r.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (!AppListTable.isColumnHidden(context, 'return_number'))
              Expanded(
                flex: 2,
                child: Text(
                  r.returnNumber,
                  style: theme.textTheme.small.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (!AppListTable.isColumnHidden(context, 'order'))
              Expanded(
                flex: 2,
                child: Text(
                  r.orderNumber ?? '-',
                  style: theme.textTheme.small.copyWith(fontSize: 12),
                ),
              ),
            if (!AppListTable.isColumnHidden(context, 'customer'))
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.customerName ?? '-',
                      style: theme.textTheme.small.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      r.customerEmail ?? '',
                      style: theme.textTheme.muted.copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            if (!AppListTable.isColumnHidden(context, 'reason'))
              Expanded(
                flex: 3,
                child: Text(
                  r.reason ?? '-',
                  style: theme.textTheme.small.copyWith(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (!AppListTable.isColumnHidden(context, 'refund'))
              Expanded(
                flex: 2,
                child: Text(
                  r.refundAmount > 0
                      ? '₹${r.refundAmount.toStringAsFixed(0)}'
                      : '-',
                  style: theme.textTheme.small.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (!AppListTable.isColumnHidden(context, 'status'))
              Expanded(flex: 2, child: StatusBadge(status: r.status)),
            if (!AppListTable.isColumnHidden(context, 'date'))
              Expanded(
                flex: 2,
                child: Text(
                  r.createdAt != null
                      ? DateFormat(
                          'MMM dd',
                        ).format(DateTime.parse(r.createdAt!))
                      : '-',
                  style: theme.textTheme.muted.copyWith(fontSize: 12),
                ),
              ),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}
