import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/theme/app_theme.dart';
import '../../provider/dashboard_provider.dart';
import '../../widgets/page_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/loading_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
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

        return RefreshIndicator(
          onRefresh: () => provider.loadDashboard(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageHeader(
                  title: 'Dashboard',
                  subtitle:
                      'Welcome back! Here\'s what\'s happening with your store.',
                ),
                const SizedBox(height: 24),

                // Stats Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 1200
                        ? 4
                        : constraints.maxWidth > 800
                        ? 3
                        : 2;
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.8,
                      children: [
                        StatCard(
                          title: 'Total Products',
                          value: '${stats?.totalProducts ?? 0}',
                          icon: LucideIcons.package,
                          color: const Color(0xFF2563EB),
                        ),
                        StatCard(
                          title: 'Total Orders',
                          value: '${stats?.totalOrders ?? 0}',
                          icon: LucideIcons.shoppingBag,
                          color: AppTheme.successColor,
                        ),
                        StatCard(
                          title: 'Total Revenue',
                          value: currencyFormat.format(
                            stats?.totalRevenue ?? 0,
                          ),
                          icon: LucideIcons.wallet,
                          color: const Color(0xFF7C3AED),
                          subtitle:
                              'Today: ${currencyFormat.format(stats?.todayRevenue ?? 0)}',
                        ),
                        StatCard(
                          title: 'Pending Orders',
                          value: '${stats?.pendingOrders ?? 0}',
                          icon: LucideIcons.clock,
                          color: AppTheme.warningColor,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Recent Orders & Low Stock
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 900) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildRecentOrders(provider),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: _buildLowStockProducts(provider),
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        _buildRecentOrders(provider),
                        const SizedBox(height: 16),
                        _buildLowStockProducts(provider),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentOrders(DashboardProvider provider) {
    final theme = ShadTheme.of(context);
    return ShadCard(
      padding: const EdgeInsets.all(20),
      title: Text('Recent Orders', style: theme.textTheme.h4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          if (provider.recentOrders.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text('No orders yet', style: theme.textTheme.muted),
              ),
            )
          else
            ...provider.recentOrders.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.orderNumber ?? '',
                            style: theme.textTheme.small,
                          ),
                          Text(
                            order.customerName ?? 'N/A',
                            style: theme.textTheme.muted,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${(order.totalAmount ?? 0).toStringAsFixed(0)}',
                      style: theme.textTheme.small,
                    ),
                    const SizedBox(width: 12),
                    StatusBadge(status: order.orderStatus ?? 'pending'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLowStockProducts(DashboardProvider provider) {
    final theme = ShadTheme.of(context);
    return ShadCard(
      padding: const EdgeInsets.all(20),
      title: Row(
        children: [
          Icon(
            LucideIcons.triangleAlert,
            color: AppTheme.warningColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text('Low Stock Alert', style: theme.textTheme.h4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          if (provider.lowStockProducts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'All products well stocked',
                  style: theme.textTheme.muted,
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
                        ShadBadge.destructive(
                          child: Text('${product.stockQuantity ?? 0} left'),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
