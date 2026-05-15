import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../model/response/response.dart';
import '../../provider/dashboard_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/status_badge.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard().then((_) {
        _fadeController.forward();
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.stats == null) {
          return const LoadingWidget(message: 'Loading dashboard...');
        }

        if (provider.error != null && provider.stats == null) {
          return ErrorWidget2(
            message: provider.error!,
            onRetry: () => provider.loadDashboard(),
          );
        }

        final stats = provider.stats;
        final currencyFormat = NumberFormat.currency(
          locale: 'en_IN',
          symbol: '₹',
          decimalDigits: 0,
        );

        return FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: () => provider.loadDashboard(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(theme),
                  const SizedBox(height: 28),

                  // Stats Cards
                  _buildStatsGrid(stats, currencyFormat, theme),
                  const SizedBox(height: 28),

                  // Revenue Chart + Recent Orders
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 900) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildRevenueChart(provider, theme),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 2,
                              child: _buildRecentOrders(provider, theme),
                            ),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          _buildRevenueChart(provider, theme),
                          const SizedBox(height: 20),
                          _buildRecentOrders(provider, theme),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Weekly Bar Chart — Sales & Orders
                  _buildWeeklyBarChart(provider, theme),
                  const SizedBox(height: 20),

                  // Top Products + Low Stock
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 900) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildTopProducts(provider, theme)),
                            const SizedBox(width: 20),
                            Expanded(child: _buildLowStock(provider, theme)),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          _buildTopProducts(provider, theme),
                          const SizedBox(height: 20),
                          _buildLowStock(provider, theme),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ShadThemeData theme) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good Morning'
        : now.hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting 👋',
          style: theme.textTheme.muted.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          'Dashboard Overview',
          style: theme.textTheme.h2.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(
    DashboardStatsResult? stats,
    NumberFormat fmt,
    ShadThemeData theme,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1100
            ? 4
            : constraints.maxWidth > 700
            ? 2
            : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: constraints.maxWidth > 700 ? 2.2 : 1.6,
          children: [
            _StatCard(
              title: 'Total Revenue',
              value: fmt.format(stats?.totalRevenue ?? 0),
              subtitle: 'Today: ${fmt.format(stats?.todayRevenue ?? 0)}',
              icon: LucideIcons.indianRupee,
              gradient: const [Color(0xFF6366F1), Color(0xFF818CF8)],
              trend: '+12.5%',
              trendUp: true,
            ),
            _StatCard(
              title: 'Total Orders',
              value: '${stats?.totalOrders ?? 0}',
              subtitle: 'Today: ${stats?.todayOrders ?? 0}',
              icon: LucideIcons.shoppingCart,
              gradient: const [Color(0xFF10B981), Color(0xFF34D399)],
              trend: '+8.2%',
              trendUp: true,
            ),
            _StatCard(
              title: 'Total Products',
              value: '${stats?.totalProducts ?? 0}',
              subtitle: '${stats?.lowStockProducts ?? 0} low stock',
              icon: LucideIcons.package,
              gradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
            ),
            _StatCard(
              title: 'Customers',
              value: '${stats?.totalCustomers ?? 0}',
              subtitle: '${stats?.pendingOrders ?? 0} pending orders',
              icon: LucideIcons.users,
              gradient: const [Color(0xFFEC4899), Color(0xFFF472B6)],
            ),
          ],
        );
      },
    );
  }

  Widget _buildRevenueChart(DashboardProvider provider, ShadThemeData theme) {
    final data = provider.revenueData;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Revenue Overview', style: theme.textTheme.h4),
                  const SizedBox(height: 2),
                  Text('Last 30 days', style: theme.textTheme.muted),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.trendingUp,
                      size: 12,
                      color: AppTheme.successColor,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '+12.5%',
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: data.isEmpty
                ? Center(
                    child: Text(
                      'No revenue data',
                      style: theme.textTheme.muted,
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: data.asMap().entries.map((e) {
                            return FlSpot(
                              e.key.toDouble(),
                              e.value.revenue ?? 0,
                            );
                          }).toList(),
                          isCurved: true,
                          curveSmoothness: 0.3,
                          color: AppTheme.brand,
                          barWidth: 2.5,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.brand.withValues(alpha: 0.15),
                                AppTheme.brand.withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBarChart(DashboardProvider provider, ShadThemeData theme) {
    final weeklyData = provider.weeklyData;

    // Generate last 7 days labels
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return DateFormat('dd MMM').format(d);
    });

    // Map data by date for lookup
    final dataMap = <String, RevenueResult>{};
    for (final item in weeklyData) {
      if (item.date != null) {
        final key = DateFormat('dd MMM').format(DateTime.parse(item.date!));
        dataMap[key] = item;
      }
    }

    // Find max value for scaling
    double maxRevenue = 1;
    int maxOrders = 1;
    for (final d in last7Days) {
      final item = dataMap[d];
      if (item != null) {
        if ((item.revenue ?? 0) > maxRevenue) maxRevenue = item.revenue!;
        if ((item.orders ?? 0) > maxOrders) maxOrders = item.orders!;
      }
    }

    // Better Y-axis formatting
    String formatYAxis(double value) {
      if (value >= 10000000)
        return '₹${(value / 10000000).toStringAsFixed(1)}Cr';
      if (value >= 100000) return '₹${(value / 100000).toStringAsFixed(1)}L';
      if (value >= 1000) return '₹${(value / 1000).toStringAsFixed(0)}K';
      return '₹${value.toStringAsFixed(0)}';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Weekly Performance', style: theme.textTheme.h4),
                  const SizedBox(height: 2),
                  Text(
                    'Sales & orders from last 7 days',
                    style: theme.textTheme.muted,
                  ),
                ],
              ),
              // Legend
              Row(
                children: [
                  _legendDot(AppTheme.brand, 'Revenue'),
                  const SizedBox(width: 16),
                  _legendDot(AppTheme.successColor, 'Orders'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Bar Chart
          SizedBox(
            height: 260,
            child: weeklyData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.chartBarBig,
                          size: 36,
                          color: theme.colorScheme.mutedForeground,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No data for this week',
                          style: theme.textTheme.muted,
                        ),
                      ],
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceEvenly,
                      maxY: maxRevenue * 1.15,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipRoundedRadius: 10,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final dayLabel = last7Days[group.x.toInt()];
                            final item = dataMap[dayLabel];
                            if (rodIndex == 0) {
                              return BarTooltipItem(
                                '$dayLabel\n',
                                const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                ),
                                children: [
                                  TextSpan(
                                    text: formatYAxis(item?.revenue ?? 0),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              );
                            }
                            return BarTooltipItem(
                              '${item?.orders ?? 0} orders',
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
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
                              final idx = value.toInt();
                              if (idx < 0 || idx >= last7Days.length) {
                                return const SizedBox();
                              }
                              final date = now.subtract(
                                Duration(days: 6 - idx),
                              );
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  DateFormat('EEE').format(date),
                                  style: theme.textTheme.muted.copyWith(
                                    fontSize: 11,
                                  ),
                                ),
                              );
                            },
                            reservedSize: 30,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 56,
                            interval: maxRevenue > 0 ? maxRevenue / 3 : 1,
                            getTitlesWidget: (value, meta) {
                              if (value == 0) return const SizedBox();
                              if (value > maxRevenue * 1.1)
                                return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  formatYAxis(value),
                                  style: theme.textTheme.muted.copyWith(
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
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
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxRevenue > 0 ? maxRevenue / 3 : 1,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: theme.colorScheme.border.withValues(
                            alpha: 0.5,
                          ),
                          strokeWidth: 0.8,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(7, (i) {
                        final dayLabel = last7Days[i];
                        final item = dataMap[dayLabel];
                        final revenue = item?.revenue ?? 0;
                        final orders = item?.orders ?? 0;
                        // Scale orders proportionally to revenue axis
                        final scaledOrders = maxOrders > 0
                            ? (orders / maxOrders) * maxRevenue * 0.5
                            : 0.0;

                        return BarChartGroupData(
                          x: i,
                          barsSpace: 3,
                          barRods: [
                            BarChartRodData(
                              toY: revenue > 0 ? revenue : 0,
                              gradient: const LinearGradient(
                                colors: [AppTheme.brand, AppTheme.brandLight],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              width: 18,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                            ),
                            BarChartRodData(
                              toY: scaledOrders > 0 ? scaledOrders : 0,
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.successColor,
                                  AppTheme.successColor.withValues(alpha: 0.7),
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              width: 18,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 400),
                    swapAnimationCurve: Curves.easeInOut,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOrders(DashboardProvider provider, ShadThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Orders', style: theme.textTheme.h4),
              ShadButton.ghost(
                size: ShadButtonSize.sm,
                onPressed: () {},
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: AppTheme.brand,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (provider.recentOrders.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.shoppingBag,
                      size: 32,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    const SizedBox(height: 8),
                    Text('No orders yet', style: theme.textTheme.muted),
                  ],
                ),
              ),
            )
          else
            ...provider.recentOrders
                .take(5)
                .map(
                  (order) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.brand.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(
                              LucideIcons.receipt,
                              size: 16,
                              color: AppTheme.brand,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.orderNumber ?? '',
                                style: theme.textTheme.small.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                order.customerName ?? 'N/A',
                                style: theme.textTheme.muted.copyWith(
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${(order.totalAmount ?? 0).toStringAsFixed(0)}',
                              style: theme.textTheme.small.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            StatusBadge(status: order.orderStatus ?? 'pending'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildTopProducts(DashboardProvider provider, ShadThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Selling Products', style: theme.textTheme.h4),
          const SizedBox(height: 16),
          if (provider.topProducts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('No data', style: theme.textTheme.muted),
              ),
            )
          else
            ...provider.topProducts.take(5).toList().asMap().entries.map((
              entry,
            ) {
              final i = entry.key;
              final product = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: i < 3
                            ? AppTheme.brand.withValues(alpha: 0.1)
                            : theme.colorScheme.muted.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: i < 3
                                ? AppTheme.brand
                                : theme.colorScheme.mutedForeground,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name ?? '',
                            style: theme.textTheme.small,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${product.totalSales ?? 0} sold',
                            style: theme.textTheme.muted.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${(product.sellingPrice ?? 0).toStringAsFixed(0)}',
                      style: theme.textTheme.small.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildLowStock(DashboardProvider provider, ShadThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  LucideIcons.triangleAlert,
                  size: 14,
                  color: AppTheme.warningColor,
                ),
              ),
              const SizedBox(width: 10),
              Text('Low Stock Alert', style: theme.textTheme.h4),
            ],
          ),
          const SizedBox(height: 16),
          if (provider.lowStockProducts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.packageCheck,
                      size: 28,
                      color: AppTheme.successColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All products well stocked',
                      style: theme.textTheme.muted,
                    ),
                  ],
                ),
              ),
            )
          else
            ...provider.lowStockProducts
                .take(5)
                .map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name ?? '',
                                style: theme.textTheme.small,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                product.sku ?? '',
                                style: theme.textTheme.muted.copyWith(
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _stockColor(
                              product.stockQuantity ?? 0,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${product.stockQuantity ?? 0} left',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _stockColor(product.stockQuantity ?? 0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Color _stockColor(int qty) {
    if (qty == 0) return AppTheme.dangerColor;
    if (qty <= 5) return AppTheme.warningColor;
    return AppTheme.infoColor;
  }
}

// ─── Stat Card Widget ─────────────────────────────────────────────────────────

class _StatCard extends StatefulWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final List<Color> gradient;
  final String? trend;
  final bool trendUp;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    this.subtitle,
    this.trend,
    this.trendUp = true,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: _isHovered
            ? (Matrix4.identity()..translate(0.0, -2.0))
            : Matrix4.identity(),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? widget.gradient[0].withValues(alpha: 0.3)
                : theme.colorScheme.border,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.gradient[0].withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: theme.textTheme.muted.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 16),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.value,
                  style: theme.textTheme.h3.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (widget.trend != null) ...[
                      Icon(
                        widget.trendUp
                            ? LucideIcons.trendingUp
                            : LucideIcons.trendingDown,
                        size: 12,
                        color: widget.trendUp
                            ? AppTheme.successColor
                            : AppTheme.dangerColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.trend!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: widget.trendUp
                              ? AppTheme.successColor
                              : AppTheme.dangerColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (widget.subtitle != null)
                      Expanded(
                        child: Text(
                          widget.subtitle!,
                          style: theme.textTheme.muted.copyWith(fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
