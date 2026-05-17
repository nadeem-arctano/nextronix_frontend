import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/navigation_utils.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../model/response/report_models.dart';
import '../../provider/report_provider.dart';
import '../../widgets/page_header.dart';
import 'widgets/export_buttons.dart';
import '../../widgets/skeletons.dart';

class MonthlySalesScreen extends StatefulWidget {
  const MonthlySalesScreen({super.key});

  @override
  State<MonthlySalesScreen> createState() => _MonthlySalesScreenState();
}

class _MonthlySalesScreenState extends State<MonthlySalesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ReportProvider>().loadMonthlySales();
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
                title: 'Monthly Sales Report',
                subtitle: 'Month-wise revenue trends and growth',
                onBack: () => smartBack(context, '/admin/reports'),
                actions: const [ExportButtons(reportType: 'monthly-sales')],
              ),
              const SizedBox(height: 20),
              // Year selector
              Row(
                children: [
                  _buildYearChip(provider, provider.selectedYear - 1, theme),
                  const SizedBox(width: 8),
                  _buildYearChip(provider, provider.selectedYear, theme),
                  const SizedBox(width: 8),
                  if (provider.selectedYear < DateTime.now().year)
                    _buildYearChip(provider, provider.selectedYear + 1, theme),
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

  Widget _buildYearChip(
    ReportProvider provider,
    int year,
    ShadThemeData theme,
  ) {
    final isSelected = provider.selectedYear == year;
    return GestureDetector(
      onTap: () {
        provider.setYear(year);
        provider.loadMonthlySales();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.border,
          ),
        ),
        child: Text(
          year.toString(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.primaryForeground
                : theme.colorScheme.mutedForeground,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ReportProvider provider, ShadThemeData theme) {
    if (provider.monthlySales.isEmpty) {
      return const Center(child: Text('No data available for selected year'));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Revenue Chart
          ShadCard(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: 250,
              child: _buildLineChart(provider.monthlySales, theme),
            ),
          ),
          const SizedBox(height: 20),
          // Table
          ShadCard(
            padding: EdgeInsets.zero,
            child: _buildTable(provider.monthlySales, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<MonthlySalesItem> data, ShadThemeData theme) {
    final sorted = [...data]..sort((a, b) => a.month.compareTo(b.month));
    final months = [
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

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt() - 1;
                if (idx < 0 || idx >= 12) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    months[idx],
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
              getTitlesWidget: (value, meta) {
                return Text(
                  _shortNumber(value),
                  style: const TextStyle(fontSize: 9),
                );
              },
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
        lineBarsData: [
          LineChartBarData(
            spots: sorted
                .map((e) => FlSpot(e.month.toDouble(), e.revenue))
                .toList(),
            isCurved: true,
            color: const Color(0xFF4F46E5),
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<MonthlySalesItem> data, ShadThemeData theme) {
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
              _headerCell('MONTH', 2, theme),
              _headerCell('ORDERS', 1, theme),
              _headerCell('REVENUE', 2, theme),
              _headerCell('TAX', 2, theme),
              _headerCell('AVG ORDER', 2, theme),
              _headerCell('GROWTH', 1, theme),
            ],
          ),
        ),
        ...data.map(
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
                  flex: 2,
                  child: Text(
                    '${months[item.month]} ${item.year}',
                    style: theme.textTheme.small,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '${item.orderCount}',
                    style: theme.textTheme.small,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '₹${item.revenue.toStringAsFixed(0)}',
                    style: theme.textTheme.small,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '₹${item.tax.toStringAsFixed(0)}',
                    style: theme.textTheme.small,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '₹${item.averageOrderValue.toStringAsFixed(0)}',
                    style: theme.textTheme.small,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '${item.growthPercent >= 0 ? '+' : ''}${item.growthPercent.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: item.growthPercent >= 0
                          ? Colors.green
                          : Colors.red,
                    ),
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

  String _shortNumber(double value) {
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(1)}L';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toStringAsFixed(0);
  }
}
