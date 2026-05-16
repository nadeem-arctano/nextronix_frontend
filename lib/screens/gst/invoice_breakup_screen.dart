import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../model/response/response.dart';
import '../../provider/gst_provider.dart';
import '../../widgets/app_list_table.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/page_header.dart';

class InvoiceBreakupScreen extends StatefulWidget {
  const InvoiceBreakupScreen({super.key});

  @override
  State<InvoiceBreakupScreen> createState() => _InvoiceBreakupScreenState();
}

class _InvoiceBreakupScreenState extends State<InvoiceBreakupScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GstProvider>().loadInvoiceBreakup();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GstProvider>(
      builder: (context, p, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'Invoice GST Breakup',
                subtitle: 'Per-invoice tax breakdown',
              ),
              const SizedBox(height: 20),
              Expanded(
                child: p.isLoading && p.invoiceData.isEmpty
                    ? const LoadingWidget()
                    : p.invoiceData.isEmpty
                    ? const EmptyWidget(message: 'No invoices')
                    : AppListTable<InvoiceBreakupItem>(
                        columns: const [
                          AppTableColumn(label: 'Invoice', flex: 2),
                          AppTableColumn(label: 'Date', flex: 2),
                          AppTableColumn(label: 'Customer', flex: 3),
                          AppTableColumn(label: 'State', flex: 2),
                          AppTableColumn(label: 'Taxable', flex: 2),
                          AppTableColumn(label: 'CGST', flex: 1),
                          AppTableColumn(label: 'SGST', flex: 1),
                          AppTableColumn(label: 'Total GST', flex: 2),
                          AppTableColumn(label: 'Total', flex: 2),
                        ],
                        items: p.invoiceData,
                        currentPage: p.invoicePagination?.currentPage ?? 1,
                        totalPages: p.invoicePagination?.totalPages ?? 1,
                        totalItems: p.invoicePagination?.totalItems ?? 0,
                        itemLabel: 'invoices',
                        onPageChanged: (page) =>
                            p.loadInvoiceBreakup(page: page),
                        rowBuilder: (item, _) => _buildRow(item),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(InvoiceBreakupItem item) {
    final theme = ShadTheme.of(context);
    return InkWell(
      onTap: () => _showInvoiceDetail(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                item.invoiceNumber,
                style: theme.textTheme.small.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                item.invoiceDate != null
                    ? DateFormat(
                        'MMM dd, yyyy',
                      ).format(DateTime.parse(item.invoiceDate!))
                    : '-',
                style: theme.textTheme.muted.copyWith(fontSize: 12),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                item.customerName ?? '-',
                style: theme.textTheme.small.copyWith(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                item.state ?? '-',
                style: theme.textTheme.muted.copyWith(fontSize: 12),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '₹${item.taxableAmount.toStringAsFixed(0)}',
                style: theme.textTheme.small,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '₹${item.cgst.toStringAsFixed(0)}',
                style: theme.textTheme.small.copyWith(fontSize: 11),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '₹${item.sgst.toStringAsFixed(0)}',
                style: theme.textTheme.small.copyWith(fontSize: 11),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '₹${item.totalGst.toStringAsFixed(0)}',
                style: theme.textTheme.small.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '₹${item.invoiceTotal.toStringAsFixed(0)}',
                style: theme.textTheme.small.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  void _showInvoiceDetail(InvoiceBreakupItem item) {
    showDialog(
      context: context,
      builder: (_) => _InvoiceDetailDialog(item: item),
    );
  }
}

class _InvoiceDetailDialog extends StatelessWidget {
  final InvoiceBreakupItem item;
  const _InvoiceDetailDialog({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Invoice Detail', style: theme.textTheme.h4),
              Text(
                item.invoiceNumber,
                style: theme.textTheme.muted.copyWith(fontFamily: 'monospace'),
              ),
              const Divider(height: 24),
              _row('Customer', item.customerName ?? '-', theme),
              _row('Email', item.customerEmail ?? '-', theme),
              _row('State', item.state ?? '-', theme),
              _row('Date', item.invoiceDate ?? '-', theme),
              const Divider(height: 24),
              _row(
                'Taxable Amount',
                '₹${item.taxableAmount.toStringAsFixed(2)}',
                theme,
              ),
              _row('CGST', '₹${item.cgst.toStringAsFixed(2)}', theme),
              _row('SGST', '₹${item.sgst.toStringAsFixed(2)}', theme),
              _row('IGST', '₹${item.igst.toStringAsFixed(2)}', theme),
              _row(
                'Total GST',
                '₹${item.totalGst.toStringAsFixed(2)}',
                theme,
                bold: true,
              ),
              const Divider(height: 16),
              _row(
                'Invoice Total',
                '₹${item.invoiceTotal.toStringAsFixed(2)}',
                theme,
                bold: true,
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ShadButton.outline(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(
    String label,
    String value,
    ShadThemeData theme, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.muted.copyWith(fontSize: 12),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.small.copyWith(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
