import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../provider/gst_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/page_header.dart';
import 'widgets/month_year_picker.dart';

class Gstr1Screen extends StatefulWidget {
  const Gstr1Screen({super.key});

  @override
  State<Gstr1Screen> createState() => _Gstr1ScreenState();
}

class _Gstr1ScreenState extends State<Gstr1Screen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GstProvider>().loadGstr1();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Consumer<GstProvider>(
      builder: (context, p, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'GSTR-1',
                subtitle: 'Outward supplies — rate-wise summary',
                actions: [
                  MonthYearPicker(
                    selectedMonth: p.selectedMonth,
                    selectedYear: p.selectedYear,
                    onMonthChanged: (m) {
                      p.setMonth(m);
                      p.loadGstr1();
                    },
                    onYearChanged: (y) {
                      p.setYear(y);
                      p.loadGstr1();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: p.isLoading
                    ? const LoadingWidget()
                    : p.gstr1 == null
                    ? const EmptyWidget(message: 'No data')
                    : SingleChildScrollView(child: _buildContent(p, theme)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(GstProvider p, ShadThemeData theme) {
    final d = p.gstr1!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _statCard(
              'Total Invoices',
              d.totalInvoices.toString(),
              const Color(0xFF4F46E5),
              LucideIcons.fileText,
            ),
            _statCard(
              'Total Taxable',
              '₹${d.totalTaxable.toStringAsFixed(0)}',
              const Color(0xFF059669),
              LucideIcons.indianRupee,
            ),
            _statCard(
              'Total Tax',
              '₹${d.totalTax.toStringAsFixed(0)}',
              const Color(0xFFD97706),
              LucideIcons.receipt,
            ),
          ],
        ),
        const SizedBox(height: 20),
        ShadCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted.withValues(alpha: 0.3),
                  border: Border(
                    bottom: BorderSide(color: theme.colorScheme.border),
                  ),
                ),
                child: Row(
                  children: [
                    _hCell('RATE', 1, theme),
                    _hCell('INVOICES', 1, theme),
                    _hCell('TAXABLE', 2, theme),
                    _hCell('CGST', 2, theme),
                    _hCell('SGST', 2, theme),
                    _hCell('IGST', 2, theme),
                    _hCell('TOTAL TAX', 2, theme),
                  ],
                ),
              ),
              ...d.ratewise.map(
                (r) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: theme.colorScheme.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${r.rate}%',
                          style: theme.textTheme.small.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${r.invoiceCount}',
                          style: theme.textTheme.small,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹${r.taxableValue.toStringAsFixed(2)}',
                          style: theme.textTheme.small,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹${r.cgst.toStringAsFixed(2)}',
                          style: theme.textTheme.small,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹${r.sgst.toStringAsFixed(2)}',
                          style: theme.textTheme.small,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹${r.igst.toStringAsFixed(2)}',
                          style: theme.textTheme.small,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹${r.totalTax.toStringAsFixed(2)}',
                          style: theme.textTheme.small.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

  Widget _statCard(String label, String value, Color color, IconData icon) {
    final theme = ShadTheme.of(context);
    return SizedBox(
      width: 220,
      child: ShadCard(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: theme.textTheme.h4.copyWith(fontSize: 16)),
                  Text(
                    label,
                    style: theme.textTheme.muted.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hCell(String t, int f, ShadThemeData theme) => Expanded(
    flex: f,
    child: Text(
      t,
      style: theme.textTheme.muted.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  );
}
