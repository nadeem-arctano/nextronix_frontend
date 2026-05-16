import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../provider/report_provider.dart';
import '../../widgets/page_header.dart';
import '../../widgets/loading_widget.dart';
import 'widgets/date_range_filter.dart';
import 'widgets/export_buttons.dart';

class DailySalesScreen extends StatefulWidget {
  const DailySalesScreen({super.key});

  @override
  State<DailySalesScreen> createState() => _DailySalesScreenState();
}

class _DailySalesScreenState extends State<DailySalesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().loadDailySales();
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
                title: 'Daily Sales Report',
                subtitle: 'Revenue and order breakdown by day',
                onBack: () => context.go('/admin/reports'),
                actions: const [ExportButtons(reportType: 'daily-sales')],
              ),
              const SizedBox(height: 20),
              // Filters
              Row(
                children: [
                  DateRangeFilter(
                    startDate: provider.startDate,
                    endDate: provider.endDate,
                    onChanged: (range) {
                      if (range != null) {
                        provider.setDateRange(range.start, range.end);
                        provider.loadDailySales();
                      }
                    },
                    onClear: () {
                      provider.setDateRange(null, null);
                      provider.loadDailySales();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Content
              Expanded(
                child: provider.isLoading
                    ? const LoadingWidget(message: 'Loading report...')
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
    final data = provider.dailySalesData;
    if (data == null || data.data.isEmpty) {
      return const Center(child: Text('No data available for selected period'));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Chart
          ShadCard(
            padding: const EdgeInsets.all(20),
            child: SizedBox(height: 250, child: _buildChart(data.data, theme)),
          ),
          const SizedBox(height: 20),
          // Table
          ShadCard(
            padding: EdgeInsets.zero,
            child: _buildTable(data.data, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List data, ShadThemeData theme) {
    final reversed = data.reversed.toList();
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY:
            reversed.fold<double>(
              0,
              (max, e) => e.revenue > max ? e.revenue : max,
            ) *
            1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '₹${reversed[group.x].revenue.toStringAsFixed(0)}',
                const TextStyle(color: Colors.white, fontSize: 11),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= reversed.length) return const SizedBox();
                final item = reversed[value.toInt()];
                final date = item.date != null
                    ? DateFormat('dd/MM').format(DateTime.parse(item.date!))
                    : '';
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(date, style: const TextStyle(fontSize: 9)),
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
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        barGroups: reversed.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.revenue,
                color: const Color(0xFF4F46E5),
                width: reversed.length > 15 ? 8 : 16,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTable(List data, ShadThemeData theme) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.muted.withValues(alpha: 0.3),
            border: Border(bottom: BorderSide(color: theme.colorScheme.border)),
          ),
          child: Row(
            children: [
              _headerCell('DATE', 2, theme),
              _headerCell('ORDERS', 1, theme),
              _headerCell('REVENUE', 2, theme),
              _headerCell('GST', 2, theme),
              _headerCell('DISCOUNT', 2, theme),
              _headerCell('COD', 1, theme),
              _headerCell('ONLINE', 1, theme),
            ],
          ),
        ),
        // Rows
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
                    item.date != null
                        ? DateFormat(
                            'MMM dd, yyyy',
                          ).format(DateTime.parse(item.date!))
                        : '-',
                    style: theme.textTheme.small,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text('${item.orders}', style: theme.textTheme.small),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '₹${item.revenue.toStringAsFixed(2)}',
                    style: theme.textTheme.small,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '₹${item.gst.toStringAsFixed(2)}',
                    style: theme.textTheme.small,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '₹${item.discount.toStringAsFixed(2)}',
                    style: theme.textTheme.small,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '${item.codOrders}',
                    style: theme.textTheme.small,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '${item.onlineOrders}',
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

  String _shortNumber(double value) {
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(1)}L';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toStringAsFixed(0);
  }
}
