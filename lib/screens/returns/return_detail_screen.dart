import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../provider/return_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/page_header.dart';
import '../../widgets/status_badge.dart';

class ReturnDetailScreen extends StatefulWidget {
  final int returnId;
  const ReturnDetailScreen({super.key, required this.returnId});

  @override
  State<ReturnDetailScreen> createState() => _ReturnDetailScreenState();
}

class _ReturnDetailScreenState extends State<ReturnDetailScreen> {
  final _refundController = TextEditingController();
  final _remarkController = TextEditingController();
  String _refundMethod = 'original';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReturnProvider>().loadReturnById(widget.returnId);
    });
  }

  @override
  void dispose() {
    _refundController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(ReturnProvider p, String status) async {
    final refund = double.tryParse(_refundController.text);
    final err = await p.updateStatus(
      widget.returnId,
      status: status,
      adminRemark: _remarkController.text.trim().isEmpty
          ? null
          : _remarkController.text.trim(),
      refundAmount: refund,
      refundMethod: _refundMethod,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          err == null ? 'Status updated to $status' : err.alertMessage,
        ),
        backgroundColor: err == null
            ? AppTheme.successColor
            : AppTheme.dangerColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReturnProvider>(
      builder: (context, p, _) {
        final r = p.selected;
        if (r != null && _refundController.text.isEmpty && r.refundAmount > 0) {
          _refundController.text = r.refundAmount.toString();
        }
        if (r != null &&
            _remarkController.text.isEmpty &&
            r.adminRemark != null) {
          _remarkController.text = r.adminRemark!;
        }
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: r?.returnNumber ?? 'Return',
                subtitle: r?.reason ?? '',
                onBack: () => context.go('/admin/returns'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: p.isLoading || r == null
                    ? const LoadingWidget(message: 'Loading return...')
                    : SingleChildScrollView(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _buildLeft(r)),
                            const SizedBox(width: 16),
                            Expanded(flex: 1, child: _buildRight(p, r)),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeft(dynamic r) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShadCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Return Information',
                style: theme.textTheme.h4.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 16),
              _row('Return Number', r.returnNumber, theme),
              _row('Order Number', r.orderNumber ?? '-', theme),
              _row('Order Total', '₹${r.orderTotal.toStringAsFixed(2)}', theme),
              _row(
                'Customer',
                '${r.customerName ?? '-'} (${r.customerEmail ?? ''})',
                theme,
              ),
              _row('Reason', r.reason ?? '-', theme),
              if (r.description != null && r.description.isNotEmpty)
                _row('Description', r.description, theme),
              _row(
                'Created',
                r.createdAt != null
                    ? DateFormat(
                        'MMM dd, yyyy h:mm a',
                      ).format(DateTime.parse(r.createdAt!))
                    : '-',
                theme,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (r.items != null && (r.items as List).isNotEmpty)
          ShadCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Items being returned',
                  style: theme.textTheme.h4.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 12),
                ...(r.items as List).map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.package,
                          size: 14,
                          color: theme.colorScheme.mutedForeground,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.productName ?? '-',
                            style: theme.textTheme.small,
                          ),
                        ),
                        Text(
                          'Qty: ${item.quantity}',
                          style: theme.textTheme.muted.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _row(String label, String value, ShadThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.textTheme.muted.copyWith(fontSize: 12),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.small)),
        ],
      ),
    );
  }

  Widget _buildRight(ReturnProvider p, dynamic r) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShadCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Status',
                    style: theme.textTheme.h4.copyWith(fontSize: 13),
                  ),
                  StatusBadge(status: r.status),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Refund Amount',
                style: theme.textTheme.muted.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 6),
              ShadInput(
                controller: _refundController,
                placeholder: const Text('0.00'),
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                'Refund Method',
                style: theme.textTheme.muted.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: ['original', 'wallet', 'bank', 'manual']
                    .map(
                      (m) => ChoiceChip(
                        label: Text(m, style: const TextStyle(fontSize: 11)),
                        selected: _refundMethod == m,
                        onSelected: (_) => setState(() => _refundMethod = m),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              Text(
                'Admin Remark',
                style: theme.textTheme.muted.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 6),
              ShadInput(
                controller: _remarkController,
                placeholder: const Text('Add internal note...'),
                maxLines: 3,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ShadCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Update Status',
                style: theme.textTheme.h4.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 12),
              _statusButton('Approve', 'approved', AppTheme.successColor, p),
              const SizedBox(height: 6),
              _statusButton(
                'Schedule Pickup',
                'pickup_scheduled',
                AppTheme.infoColor,
                p,
              ),
              const SizedBox(height: 6),
              _statusButton(
                'Mark Refunded',
                'refunded',
                const Color(0xFF10B981),
                p,
              ),
              const SizedBox(height: 6),
              _statusButton('Mark Completed', 'completed', AppTheme.brand, p),
              const SizedBox(height: 6),
              _statusButton('Reject', 'rejected', AppTheme.dangerColor, p),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusButton(
    String label,
    String status,
    Color color,
    ReturnProvider p,
  ) {
    return ShadButton.outline(
      size: ShadButtonSize.sm,
      onPressed: () => _updateStatus(p, status),
      child: Text(label, style: TextStyle(fontSize: 12, color: color)),
    );
  }
}
