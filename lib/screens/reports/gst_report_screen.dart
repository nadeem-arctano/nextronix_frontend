import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/navigation_utils.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../provider/report_provider.dart';
import '../../widgets/page_header.dart';
import 'widgets/date_range_filter.dart';
import 'widgets/export_buttons.dart';
import 'widgets/report_summary_card.dart';
import '../../widgets/skeletons.dart';

class GstReportScreen extends StatefulWidget {
  const GstReportScreen({super.key});

  @override
  State<GstReportScreen> createState() => _GstReportScreenState();
}

class _GstReportScreenState extends State<GstReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ReportProvider>().loadGstReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Consumer<ReportProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'GST Report',
                subtitle: 'Tax breakdown with CGST, SGST, and IGST',
                onBack: () => smartBack(context, '/admin/gst'),
                actions: const [ExportButtons(reportType: 'gst-report')],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  DateRangeFilter(
                    startDate: provider.startDate,
                    endDate: provider.endDate,
                    onChanged: (range) {
                      if (range != null) {
                        provider.setDateRange(range.start, range.end);
                        provider.loadGstReport();
                      }
                    },
                    onClear: () {
                      provider.setDateRange(null, null);
                      provider.loadGstReport();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: provider.isLoading
                    ? const ChartSkeleton(height: 280)
                    : provider.error != null
                    ? Center(child: Text(provider.error!))
                    : _buildContent(provider, theme),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(ReportProvider provider, ShadThemeData theme) {
    final data = provider.gstReportData;
    if (data == null || data.gstByRate.isEmpty) {
      return const Center(child: Text('No GST data available'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          if (data.invoiceSummary != null)
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                ReportSummaryCard(
                  title: 'Total Invoices',
                  value: data.invoiceSummary!.totalInvoices.toString(),
                  icon: LucideIcons.fileText,
                  color: const Color(0xFF4F46E5),
                ),
                ReportSummaryCard(
                  title: 'Total Revenue',
                  value:
                      '₹${data.invoiceSummary!.totalRevenue.toStringAsFixed(0)}',
                  icon: LucideIcons.indianRupee,
                  color: const Color(0xFF059669),
                ),
                ReportSummaryCard(
                  title: 'Total GST Collected',
                  value: '₹${data.invoiceSummary!.totalGST.toStringAsFixed(0)}',
                  icon: LucideIcons.receipt,
                  color: const Color(0xFFD97706),
                ),
              ],
            ),
          const SizedBox(height: 24),
          // Pie chart
          ShadCard(
            padding: const EdgeInsets.all(20),
            child: SizedBox(height: 200, child: _buildPieChart(data.gstByRate)),
          ),
          const SizedBox(height: 20),
          // Table
          ShadCard(
            padding: EdgeInsets.zero,
            child: _buildTable(data.gstByRate, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(List gstByRate) {
    final colors = [
      const Color(0xFF4F46E5),
      const Color(0xFF059669),
      const Color(0xFFD97706),
      const Color(0xFFDC2626),
      const Color(0xFF7C3AED),
    ];

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: gstByRate.asMap().entries.map((entry) {
                final item = entry.value;
                return PieChartSectionData(
                  value: item.taxableAmount,
                  color: colors[entry.key % colors.length],
                  title: '${item.gstPercent}%',
                  titleStyle: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  radius: 60,
                );
              }).toList(),
              centerSpaceRadius: 30,
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: gstByRate.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colors[entry.key % colors.length],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'GST ${entry.value.gstPercent}%',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTable(List gstByRate, ShadThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.muted.withValues(alpha: 0.3),
            border: Border(bottom: BorderSide(color: theme.colorScheme.border)),
          ),
          child: Row(
            children: [
              _headerCell('GST RATE', 1, theme),
              _headerCell('INVOICES', 1, theme),
              _headerCell('TAXABLE AMOUNT', 2, theme),
              _headerCell('CGST', 2, theme),
              _headerCell('SGST', 2, theme),
              _headerCell('IGST', 2, theme),
            ],
          ),
        ),
        ...gstByRate.map(
          (item) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    '${item.gstPercent}%',
                    style: theme.textTheme.small,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '${item.invoiceCount}',
                    style: theme.textTheme.small,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '₹${item.taxableAmount.toStringAsFixed(2)}',
                    style: theme.textTheme.small,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '₹${item.cgst.toStringAsFixed(2)}',
                    style: theme.textTheme.small,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '₹${item.sgst.toStringAsFixed(2)}',
                    style: theme.textTheme.small,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '₹${item.igst.toStringAsFixed(2)}',
                    style: theme.textTheme.small,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerCell(String text, int flex, ShadThemeData theme) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: theme.textTheme.muted.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
