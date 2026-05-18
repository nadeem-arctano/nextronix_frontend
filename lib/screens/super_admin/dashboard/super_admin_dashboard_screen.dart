import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../provider/super_admin_dashboard_provider.dart';
import '../../../widgets/page_header.dart';

/// Super Admin dashboard screen rendering platform-wide KPI cards and
/// master totals/in-use rows.
///
/// Validates Requirements 9.1, 9.3.
class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() =>
      _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SuperAdminDashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SuperAdminDashboardProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: provider.isLoading
              ? const _DashboardSkeleton()
              : provider.error != null
              ? _buildError(provider)
              : _buildDashboard(provider),
        );
      },
    );
  }

  Widget _buildError(SuperAdminDashboardProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.triangleAlert, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            provider.error ?? 'Something went wrong',
            style: ShadTheme.of(context).textTheme.muted,
          ),
          const SizedBox(height: 16),
          ShadButton.outline(
            onPressed: () => provider.loadDashboard(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(SuperAdminDashboardProvider provider) {
    final data = provider.data;
    if (data == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: 'Dashboard', subtitle: 'Platform overview'),
          const SizedBox(height: 24),

          // ─── KPI Cards ───────────────────────────────────────────────
          _SectionTitle(title: 'Platform KPIs'),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900
                  ? 3
                  : constraints.maxWidth > 600
                  ? 2
                  : 1;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _KpiCard(
                    icon: LucideIcons.shield,
                    label: 'Admins',
                    value: data.adminCount.toString(),
                    color: Colors.blue,
                    width: _cardWidth(constraints.maxWidth, crossAxisCount),
                  ),
                  _KpiCard(
                    icon: LucideIcons.users,
                    label: 'Managers',
                    value: data.managerCount.toString(),
                    color: Colors.purple,
                    width: _cardWidth(constraints.maxWidth, crossAxisCount),
                  ),
                  _KpiCard(
                    icon: LucideIcons.user,
                    label: 'Customers',
                    value: data.customerCount.toString(),
                    color: Colors.teal,
                    width: _cardWidth(constraints.maxWidth, crossAxisCount),
                  ),
                  _KpiCard(
                    icon: LucideIcons.package,
                    label: 'Active Products',
                    value: data.activeProductCount.toString(),
                    color: Colors.orange,
                    width: _cardWidth(constraints.maxWidth, crossAxisCount),
                  ),
                  _KpiCard(
                    icon: LucideIcons.shoppingCart,
                    label: "Today's Orders",
                    value: data.todayOrderCount.toString(),
                    color: Colors.green,
                    width: _cardWidth(constraints.maxWidth, crossAxisCount),
                  ),
                  _KpiCard(
                    icon: LucideIcons.indianRupee,
                    label: "Today's Sales",
                    value: _formatCurrency(data.todaySalesAmount),
                    color: Colors.indigo,
                    width: _cardWidth(constraints.maxWidth, crossAxisCount),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // ─── Master Data Summary ─────────────────────────────────────
          _SectionTitle(title: 'Master Data'),
          const SizedBox(height: 12),
          _MasterDataTable(totals: data.masterTotals, inUse: data.masterInUse),
        ],
      ),
    );
  }

  double _cardWidth(double totalWidth, int crossAxisCount) {
    final spacing = 16.0 * (crossAxisCount - 1);
    return (totalWidth - spacing) / crossAxisCount;
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }
}

// ─── Subwidgets ──────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: ShadTheme.of(context).textTheme.h4);
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final double width;

  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return SizedBox(
      width: width,
      child: ShadCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.muted,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.h3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MasterDataTable extends StatelessWidget {
  final List<MasterCount> totals;
  final List<MasterInUseCount> inUse;

  const _MasterDataTable({required this.totals, required this.inUse});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    // Build a map for quick lookup
    final inUseMap = <String, int>{};
    for (final item in inUse) {
      inUseMap[item.master] = item.used;
    }

    return ShadCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Master Table', style: theme.textTheme.small),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Total Records',
                    style: theme.textTheme.small,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'In Use',
                    style: theme.textTheme.small,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Data rows
          ...totals.map((item) {
            final usedCount = inUseMap[item.master] ?? 0;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      _formatMasterName(item.master),
                      style: theme.textTheme.p,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.total.toString(),
                      style: theme.textTheme.p,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      usedCount.toString(),
                      style: theme.textTheme.p,
                      textAlign: TextAlign.center,
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

  String _formatMasterName(String name) {
    switch (name) {
      case 'categories':
        return 'Categories';
      case 'hsn':
        return 'HSN Codes';
      case 'colors':
        return 'Colors';
      case 'materials':
        return 'Materials';
      default:
        return name[0].toUpperCase() + name.substring(1);
    }
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // Skeleton for title
          Container(
            width: 200,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 32),
          // Skeleton for KPI cards
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: List.generate(
              6,
              (_) => Container(
                width: 280,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Skeleton for table
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
          ),
        ],
      ),
    );
  }
}
