import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/navigation_utils.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../model/response/report_models.dart';
import '../../provider/report_provider.dart';
import '../../widgets/page_header.dart';
import 'widgets/date_range_filter.dart';
import 'widgets/export_buttons.dart';
import '../../widgets/skeletons.dart';

class BestProductsScreen extends StatefulWidget {
  const BestProductsScreen({super.key});

  @override
  State<BestProductsScreen> createState() => _BestProductsScreenState();
}

class _BestProductsScreenState extends State<BestProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ReportProvider>().loadBestProducts();
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
                title: 'Best Selling Products',
                subtitle: 'Top products by quantity sold and revenue',
                onBack: () => smartBack(context, '/admin/reports'),
                actions: const [ExportButtons(reportType: 'best-products')],
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
                        provider.loadBestProducts();
                      }
                    },
                    onClear: () {
                      provider.setDateRange(null, null);
                      provider.loadBestProducts();
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
                    : provider.bestProducts.isEmpty
                    ? const Center(
                        child: Text('No product sales data available'),
                      )
                    : _buildContent(provider, theme),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(ReportProvider provider, ShadThemeData theme) {
    return Column(
      children: [
        // Chart showing top 10
        ShadCard(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 200,
            child: _buildChart(provider.bestProducts.take(10).toList(), theme),
          ),
        ),
        const SizedBox(height: 20),
        // Table
        Expanded(child: _buildTable(provider, theme)),
      ],
    );
  }

  Widget _buildChart(List<BestProductItem> data, ShadThemeData theme) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY:
            data.fold<double>(
              0,
              (max, e) =>
                  e.quantitySold > max ? e.quantitySold.toDouble() : max,
            ) *
            1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final name = data[group.x].productName ?? '';
              return BarTooltipItem(
                '${name.length > 20 ? '${name.substring(0, 20)}...' : name}\n${data[group.x].quantitySold} sold',
                const TextStyle(color: Colors.white, fontSize: 10),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= data.length) return const SizedBox();
                final name = data[value.toInt()].productName ?? '';
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    name.length > 8 ? '${name.substring(0, 8)}..' : name,
                    style: const TextStyle(fontSize: 8),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 9),
              ),
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
        barGroups: data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.quantitySold.toDouble(),
                color: const Color(0xFF059669),
                width: data.length > 8 ? 12 : 20,
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

  Widget _buildTable(ReportProvider provider, ShadThemeData theme) {
    return ShadCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.muted.withValues(alpha: 0.3),
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.border),
              ),
            ),
            child: Row(
              children: [
                _headerCell('#', 0, theme, width: 40),
                _headerCell('PRODUCT', 3, theme),
                _headerCell('SKU', 2, theme),
                _headerCell('QTY SOLD', 1, theme),
                _headerCell('REVENUE', 2, theme),
                _headerCell('ORDERS', 1, theme),
                _headerCell('STOCK LEFT', 1, theme),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: provider.bestProducts.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: theme.colorScheme.border),
              itemBuilder: (context, index) {
                final item = provider.bestProducts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          '${index + 1}',
                          style: theme.textTheme.muted.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.productName ?? 'N/A',
                          style: theme.textTheme.small,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.sku ?? '-',
                          style: theme.textTheme.muted.copyWith(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${item.quantitySold}',
                          style: theme.textTheme.small.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹${item.totalRevenue.toStringAsFixed(0)}',
                          style: theme.textTheme.small,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${item.totalOrders}',
                          style: theme.textTheme.small,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${item.stockRemaining}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: item.stockRemaining <= 5 ? Colors.red : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(
    String text,
    int flex,
    ShadThemeData theme, {
    double? width,
  }) {
    final child = Text(
      text,
      style: theme.textTheme.muted.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
    if (width != null) return SizedBox(width: width, child: child);
    return Expanded(flex: flex, child: child);
  }
}
