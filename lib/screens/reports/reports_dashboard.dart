import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../provider/report_provider.dart';
import '../../widgets/page_header.dart';
import 'widgets/report_card.dart';
import 'widgets/report_summary_card.dart';

class ReportsDashboard extends StatefulWidget {
  const ReportsDashboard({super.key});

  @override
  State<ReportsDashboard> createState() => _ReportsDashboardState();
}

class _ReportsDashboardState extends State<ReportsDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ReportProvider>();
      provider.loadDailySales();
      provider.loadMonthlySales();
      provider.loadBestProducts(limit: 5);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageHeader(
                  title: 'Reports',
                  subtitle: 'Sales analytics and business insights',
                ),
                const SizedBox(height: 24),

                // Summary Cards
                if (provider.dailySalesData?.summary != null) ...[
                  _buildSummaryCards(provider),
                  const SizedBox(height: 24),
                ],

                // Report Navigation Cards
                _buildReportGrid(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(ReportProvider provider) {
    final summary = provider.dailySalesData!.summary!;
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        ReportSummaryCard(
          title: 'Total Revenue',
          value: '₹${_formatNumber(summary.totalRevenue)}',
          icon: LucideIcons.indianRupee,
          color: const Color(0xFF4F46E5),
        ),
        ReportSummaryCard(
          title: 'Total Orders',
          value: summary.totalOrders.toString(),
          icon: LucideIcons.shoppingBag,
          color: const Color(0xFF059669),
        ),
        ReportSummaryCard(
          title: 'Total GST',
          value: '₹${_formatNumber(summary.totalGST)}',
          icon: LucideIcons.receipt,
          color: const Color(0xFFD97706),
        ),
        ReportSummaryCard(
          title: 'Total Discount',
          value: '₹${_formatNumber(summary.totalDiscount)}',
          icon: LucideIcons.percent,
          color: const Color(0xFFDC2626),
        ),
        ReportSummaryCard(
          title: 'COD Orders',
          value: summary.codOrders.toString(),
          icon: LucideIcons.banknote,
          color: const Color(0xFF7C3AED),
        ),
        ReportSummaryCard(
          title: 'Online Orders',
          value: summary.onlineOrders.toString(),
          icon: LucideIcons.creditCard,
          color: const Color(0xFF0891B2),
        ),
      ],
    );
  }

  Widget _buildReportGrid(BuildContext context) {
    final reports = [
      _ReportItem(
        title: 'Daily Sales',
        description: 'Day-wise revenue, orders, and payment breakdown',
        icon: LucideIcons.calendarDays,
        color: const Color(0xFF4F46E5),
        route: '/admin/reports/daily-sales',
      ),
      _ReportItem(
        title: 'Monthly Sales',
        description: 'Monthly revenue trends and growth analysis',
        icon: LucideIcons.trendingUp,
        color: const Color(0xFF059669),
        route: '/admin/reports/monthly-sales',
      ),
      _ReportItem(
        title: 'GST Report',
        description: 'GST breakdown by rate with CGST, SGST, IGST',
        icon: LucideIcons.receipt,
        color: const Color(0xFFD97706),
        route: '/admin/reports/gst-report',
      ),
      _ReportItem(
        title: 'Coupon Report',
        description: 'Coupon usage, discount given, and effectiveness',
        icon: LucideIcons.ticket,
        color: const Color(0xFFDC2626),
        route: '/admin/reports/coupon-report',
      ),
      _ReportItem(
        title: 'Top Customers',
        description: 'Highest spending customers ranked by revenue',
        icon: LucideIcons.users,
        color: const Color(0xFF7C3AED),
        route: '/admin/reports/top-customers',
      ),
      _ReportItem(
        title: 'Best Products',
        description: 'Top selling products by quantity and revenue',
        icon: LucideIcons.award,
        color: const Color(0xFF0891B2),
        route: '/admin/reports/best-products',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 3
            : constraints.maxWidth > 600
            ? 2
            : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.2,
          ),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return ReportCard(
              title: report.title,
              description: report.description,
              icon: report.icon,
              color: report.color,
              onTap: () => context.go(report.route),
            );
          },
        );
      },
    );
  }

  String _formatNumber(double value) {
    if (value >= 10000000) return '${(value / 10000000).toStringAsFixed(2)} Cr';
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(2)} L';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)} K';
    return value.toStringAsFixed(2);
  }
}

class _ReportItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  _ReportItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}
