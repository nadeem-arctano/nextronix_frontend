import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../provider/gst_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/page_header.dart';
import 'widgets/month_year_picker.dart';

class Gstr3bScreen extends StatefulWidget {
  const Gstr3bScreen({super.key});

  @override
  State<Gstr3bScreen> createState() => _Gstr3bScreenState();
}

class _Gstr3bScreenState extends State<Gstr3bScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GstProvider>().loadGstr3b();
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
              PageHeader(
                title: 'GSTR-3B',
                subtitle: 'Monthly summary return — tax liability',
                onBack: () => context.go('/admin/gst'),
                actions: [
                  MonthYearPicker(
                    selectedMonth: p.selectedMonth,
                    selectedYear: p.selectedYear,
                    onMonthChanged: (m) {
                      p.setMonth(m);
                      p.loadGstr3b();
                    },
                    onYearChanged: (y) {
                      p.setYear(y);
                      p.loadGstr3b();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: p.isLoading
                    ? const LoadingWidget()
                    : p.gstr3b == null
                    ? const EmptyWidget(message: 'No data')
                    : SingleChildScrollView(child: _buildContent(p)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(GstProvider p) {
    final theme = ShadTheme.of(context);
    final d = p.gstr3b!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShadCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '3.1 Outward Supplies',
                style: theme.textTheme.h4.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 16),
              _detailRow(
                'Taxable Value',
                '₹${d.taxableValue.toStringAsFixed(2)}',
                theme,
              ),
              _detailRow('CGST', '₹${d.cgst.toStringAsFixed(2)}', theme),
              _detailRow('SGST', '₹${d.sgst.toStringAsFixed(2)}', theme),
              _detailRow('IGST', '₹${d.igst.toStringAsFixed(2)}', theme),
              const Divider(height: 24),
              _detailRow(
                'Total Tax',
                '₹${d.totalTax.toStringAsFixed(2)}',
                theme,
                bold: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ShadCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '3.2 Tax Payable Summary',
                style: theme.textTheme.h4.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.indianRupee,
                      color: Color(0xFF4F46E5),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Total tax liability for this period',
                        style: theme.textTheme.small,
                      ),
                    ),
                    Text(
                      '₹${d.totalTax.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Note: ITC and inward supplies require purchase records integration.',
                style: theme.textTheme.muted.copyWith(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailRow(
    String label,
    String value,
    ShadThemeData theme, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.muted.copyWith(fontSize: 13),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 16 : 14,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
