import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../provider/gst_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/page_header.dart';

class GstDashboardScreen extends StatefulWidget {
  const GstDashboardScreen({super.key});

  @override
  State<GstDashboardScreen> createState() => _GstDashboardScreenState();
}

class _GstDashboardScreenState extends State<GstDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GstProvider>().loadDashboard();
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
                title: 'GST Dashboard',
                subtitle: 'Overview of GST collection and tax liability',
              ),
              const SizedBox(height: 20),
              Expanded(
                child: p.isLoading && p.dashboard == null
                    ? const LoadingWidget(message: 'Loading...')
                    : p.dashboard == null
                    ? const EmptyWidget(message: 'No GST data')
                    : SingleChildScrollView(child: _buildContent(p)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(GstProvider p) {
    final t = p.dashboard!.totals;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryCards(t),
        const SizedBox(height: 20),
        _buildCharts(p),
        const SizedBox(height: 20),
        _buildShortcuts(),
      ],
    );
  }

  Widget _buildSummaryCards(dynamic totals) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _summary(
          'Total Invoices',
          totals.totalInvoices.toString(),
          LucideIcons.fileText,
          const Color(0xFF4F46E5),
        ),
        _summary(
          'Taxable Amount',
          '₹${_fmt(totals.taxableAmount)}',
          LucideIcons.indianRupee,
          const Color(0xFF059669),
        ),
        _summary(
          'Total GST',
          '₹${_fmt(totals.totalGst)}',
          LucideIcons.receipt,
          const Color(0xFFD97706),
        ),
        _summary(
          'CGST',
          '₹${_fmt(totals.cgst)}',
          LucideIcons.percent,
          const Color(0xFF0891B2),
        ),
        _summary(
          'SGST',
          '₹${_fmt(totals.sgst)}',
          LucideIcons.percent,
          const Color(0xFF7C3AED),
        ),
        _summary(
          'IGST',
          '₹${_fmt(totals.igst)}',
          LucideIcons.percent,
          const Color(0xFFE11D48),
        ),
      ],
    );
  }

  Widget _summary(String label, String value, IconData icon, Color color) {
    final theme = ShadTheme.of(context);
    return SizedBox(
      width: 180,
      child: ShadCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 12),
            Text(value, style: theme.textTheme.h4.copyWith(fontSize: 16)),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.muted.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildCharts(GstProvider p) {
    final theme = ShadTheme.of(context);
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final monthly = p.dashboard!.monthly;
    if (monthly.isEmpty) return const SizedBox();

    return ShadCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly GST Comparison',
            style: theme.textTheme.h4.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY:
                    monthly.fold<double>(
                      0,
                      (max, e) => e.totalGst > max ? e.totalGst : max,
                    ) *
                    1.2,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= monthly.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            months[monthly[idx].month],
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (v, m) =>
                          Text(_short(v), style: const TextStyle(fontSize: 9)),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                barGroups: monthly.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.totalGst,
                        color: const Color(0xFF4F46E5),
                        width: 18,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcuts() {
    final shortcuts = [
      (
        'GST Reports',
        '/admin/gst/reports',
        LucideIcons.chartBarBig,
        const Color(0xFF4F46E5),
      ),
      (
        'GSTR-1',
        '/admin/gst/gstr1',
        LucideIcons.fileText,
        const Color(0xFF059669),
      ),
      (
        'GSTR-3B',
        '/admin/gst/gstr3b',
        LucideIcons.fileSpreadsheet,
        const Color(0xFFD97706),
      ),
      (
        'State-wise',
        '/admin/gst/state-wise',
        LucideIcons.mapPin,
        const Color(0xFF0891B2),
      ),
      (
        'Invoice Breakup',
        '/admin/gst/invoice-breakup',
        LucideIcons.receipt,
        const Color(0xFF7C3AED),
      ),
      (
        'HSN Summary',
        '/admin/gst/hsn-summary',
        LucideIcons.hash,
        const Color(0xFFE11D48),
      ),
      (
        'Monthly Export',
        '/admin/gst/export',
        LucideIcons.download,
        const Color(0xFF0F766E),
      ),
      (
        'Tax Settings',
        '/admin/gst/settings',
        LucideIcons.settings,
        const Color(0xFF6B7280),
      ),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth > 900
            ? 4
            : c.maxWidth > 600
            ? 3
            : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.4,
          ),
          itemCount: shortcuts.length,
          itemBuilder: (_, i) {
            final s = shortcuts[i];
            return InkWell(
              onTap: () => context.go(s.$2),
              child: ShadCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: s.$4.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(s.$3, color: s.$4, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.$1,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: ShadTheme.of(context).colorScheme.mutedForeground,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _fmt(double v) {
    if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(2)} Cr';
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(2)} L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  String _short(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}
