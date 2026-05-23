import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../app_list_table.dart';
import '../filter_bar.dart';
import '../page_header.dart';
import '../stat_card.dart';
import '../status_badge.dart';
import '../user_avatar.dart';

/// Realistic mini admin panel preview rendered under a candidate [ShadThemeData].
///
/// Wraps all content in a [ShadTheme] override so that descendant widgets
/// resolve theming from [candidateTheme] rather than the active app theme.
/// Uses only static dummy data — no HTTP calls.
class ThemePreviewPanel extends StatelessWidget {
  /// The compiled ShadThemeData to preview.
  final ShadThemeData candidateTheme;

  const ThemePreviewPanel({super.key, required this.candidateTheme});

  @override
  Widget build(BuildContext context) {
    return ShadTheme(
      data: candidateTheme,
      child: Builder(
        builder: (context) {
          final theme = ShadTheme.of(context);
          return DefaultTextStyle(
            style: TextStyle(color: theme.colorScheme.foreground),
            child: Container(
              color: theme.colorScheme.background,
              child: Row(
                children: [
                  _SidebarMock(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DashboardSection(),
                            const SizedBox(height: 32),
                            _ProductsTableSection(),
                            const SizedBox(height: 32),
                            _OrdersTableSection(),
                            const SizedBox(height: 32),
                            _AnalyticsPlaceholder(),
                            const SizedBox(height: 32),
                            _ProductDetailMock(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Dummy Data ───────────────────────────────────────────────────────────────

class _DummyProduct {
  final int id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final String status;

  const _DummyProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.status,
  });
}

class _DummyOrder {
  final String orderId;
  final String customer;
  final double amount;
  final String status;
  final String date;

  const _DummyOrder({
    required this.orderId,
    required this.customer,
    required this.amount,
    required this.status,
    required this.date,
  });
}

const _dummyProducts = [
  _DummyProduct(
    id: 1,
    name: 'Classic White Sneakers',
    category: 'Footwear',
    price: 2499,
    stock: 45,
    status: 'active',
  ),
  _DummyProduct(
    id: 2,
    name: 'Denim Slim Fit Jeans',
    category: 'Apparel',
    price: 1899,
    stock: 120,
    status: 'active',
  ),
  _DummyProduct(
    id: 3,
    name: 'Leather Crossbody Bag',
    category: 'Accessories',
    price: 3200,
    stock: 0,
    status: 'inactive',
  ),
  _DummyProduct(
    id: 4,
    name: 'Organic Cotton T-Shirt',
    category: 'Apparel',
    price: 799,
    stock: 300,
    status: 'active',
  ),
  _DummyProduct(
    id: 5,
    name: 'Running Performance Shoes',
    category: 'Footwear',
    price: 4999,
    stock: 18,
    status: 'draft',
  ),
];

const _dummyOrders = [
  _DummyOrder(
    orderId: 'ORD-1024',
    customer: 'Priya Sharma',
    amount: 4398,
    status: 'delivered',
    date: '2025-01-15',
  ),
  _DummyOrder(
    orderId: 'ORD-1025',
    customer: 'Rahul Verma',
    amount: 2499,
    status: 'shipped',
    date: '2025-01-16',
  ),
  _DummyOrder(
    orderId: 'ORD-1026',
    customer: 'Anita Desai',
    amount: 7199,
    status: 'pending',
    date: '2025-01-16',
  ),
  _DummyOrder(
    orderId: 'ORD-1027',
    customer: 'Vikram Singh',
    amount: 1598,
    status: 'cancelled',
    date: '2025-01-17',
  ),
  _DummyOrder(
    orderId: 'ORD-1028',
    customer: 'Meera Patel',
    amount: 3200,
    status: 'confirmed',
    date: '2025-01-17',
  ),
];

// ─── Sidebar Mock ─────────────────────────────────────────────────────────────

class _SidebarMock extends StatelessWidget {
  static final _menuItems = [
    (icon: LucideIcons.layoutDashboard, label: 'Dashboard', active: true),
    (icon: LucideIcons.package, label: 'Products', active: false),
    (icon: LucideIcons.shoppingCart, label: 'Orders', active: false),
    (icon: LucideIcons.users, label: 'Customers', active: false),
    (icon: LucideIcons.chartBarBig, label: 'Analytics', active: false),
    (icon: LucideIcons.settings, label: 'Settings', active: false),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sidebarBg = isDark ? theme.colorScheme.card : const Color(0xFF0F172A);
    final activeBg = isDark
        ? theme.colorScheme.muted.withValues(alpha: 0.3)
        : const Color(0xFF1E293B);

    return Container(
      width: 220,
      color: sidebarBg,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    LucideIcons.zap,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Nextronix',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          ..._menuItems.map(
            (item) => _SidebarItem(
              icon: item.icon,
              label: item.label,
              isActive: item.active,
              activeBg: activeBg,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeBg;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? activeBg : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: isActive ? Colors.white : Colors.white60, size: 18),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white60,
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dashboard Section ────────────────────────────────────────────────────────

class _DashboardSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Dashboard',
          subtitle: 'Welcome back! Here\'s your store overview.',
          actions: [
            ShadButton(
              size: ShadButtonSize.sm,
              child: const Text('Export'),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.6,
              children: const [
                StatCard(
                  title: 'Total Revenue',
                  value: '₹12,45,000',
                  icon: LucideIcons.indianRupee,
                  color: Color(0xFF10B981),
                  subtitle: '+12.5% from last month',
                ),
                StatCard(
                  title: 'Orders',
                  value: '342',
                  icon: LucideIcons.shoppingCart,
                  color: Color(0xFF6366F1),
                  subtitle: '+8.2% from last month',
                ),
                StatCard(
                  title: 'Products',
                  value: '156',
                  icon: LucideIcons.package,
                  color: Color(0xFFF59E0B),
                  subtitle: '12 low stock',
                ),
                StatCard(
                  title: 'Customers',
                  value: '1,204',
                  icon: LucideIcons.users,
                  color: Color(0xFF06B6D4),
                  subtitle: '+24 this week',
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ─── Products Table Section ───────────────────────────────────────────────────

class _ProductsTableSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(title: 'Products', subtitle: 'Manage your product catalog'),
        const SizedBox(height: 16),
        FilterBar(
          children: [
            SizedBox(
              width: 200,
              child: ShadInput(placeholder: const Text('Search products...')),
            ),
            ShadButton.outline(
              size: ShadButtonSize.sm,
              child: const Text('All Categories'),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 360,
          child: AppListTable<_DummyProduct>(
            columns: const [
              AppTableColumn(label: 'Product', flex: 3),
              AppTableColumn(label: 'Category', flex: 2),
              AppTableColumn(label: 'Price', flex: 1),
              AppTableColumn(label: 'Stock', flex: 1),
              AppTableColumn(label: 'Status', flex: 1),
            ],
            items: _dummyProducts,
            currentPage: 1,
            totalPages: 1,
            totalItems: _dummyProducts.length,
            itemLabel: 'products',
            onPageChanged: (_) {},
            rowBuilder: (product, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      product.name,
                      style: theme.textTheme.p.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: theme.colorScheme.foreground,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      product.category,
                      style: theme.textTheme.muted.copyWith(
                        fontSize: 12,
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '₹${product.price.toStringAsFixed(0)}',
                      style: theme.textTheme.p.copyWith(
                        fontSize: 12,
                        color: theme.colorScheme.foreground,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${product.stock}',
                      style: theme.textTheme.p.copyWith(
                        fontSize: 12,
                        color: theme.colorScheme.foreground,
                      ),
                    ),
                  ),
                  Expanded(flex: 1, child: StatusBadge(status: product.status)),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Orders Table Section ─────────────────────────────────────────────────────

class _OrdersTableSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Orders',
          subtitle: 'Track and manage customer orders',
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 360,
          child: AppListTable<_DummyOrder>(
            columns: const [
              AppTableColumn(label: 'Order ID', flex: 2),
              AppTableColumn(label: 'Customer', flex: 3),
              AppTableColumn(label: 'Amount', flex: 1),
              AppTableColumn(label: 'Status', flex: 2),
              AppTableColumn(label: 'Date', flex: 2),
            ],
            items: _dummyOrders,
            currentPage: 1,
            totalPages: 1,
            totalItems: _dummyOrders.length,
            itemLabel: 'orders',
            onPageChanged: (_) {},
            rowBuilder: (order, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      order.orderId,
                      style: theme.textTheme.p.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: theme.colorScheme.foreground,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        UserAvatar(name: order.customer, radius: 14),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            order.customer,
                            style: theme.textTheme.p.copyWith(
                              fontSize: 12,
                              color: theme.colorScheme.foreground,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '₹${order.amount.toStringAsFixed(0)}',
                      style: theme.textTheme.p.copyWith(
                        fontSize: 12,
                        color: theme.colorScheme.foreground,
                      ),
                    ),
                  ),
                  Expanded(flex: 2, child: StatusBadge(status: order.status)),
                  Expanded(
                    flex: 2,
                    child: Text(
                      order.date,
                      style: theme.textTheme.muted.copyWith(
                        fontSize: 11,
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Analytics Placeholder ────────────────────────────────────────────────────

class _AnalyticsPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(title: 'Analytics', subtitle: 'Sales performance overview'),
        const SizedBox(height: 16),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.border),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.chartBarBig,
                  size: 40,
                  color: theme.colorScheme.mutedForeground,
                ),
                const SizedBox(height: 12),
                Text(
                  'Sales Chart Preview',
                  style: theme.textTheme.muted.copyWith(
                    fontSize: 14,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Charts will render with your theme colors',
                  style: theme.textTheme.muted.copyWith(
                    fontSize: 11,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Product Detail Mock ──────────────────────────────────────────────────────

class _ProductDetailMock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Product Detail',
          subtitle: 'Classic White Sneakers',
          onBack: () {},
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  LucideIcons.image,
                  size: 32,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
              const SizedBox(width: 24),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Classic White Sneakers',
                      style: theme.textTheme.h3.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.foreground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Footwear • SKU: SNK-001',
                      style: theme.textTheme.muted.copyWith(
                        fontSize: 12,
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          '₹2,499',
                          style: theme.textTheme.h4.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '₹3,499',
                          style: theme.textTheme.muted.copyWith(
                            fontSize: 13,
                            color: theme.colorScheme.mutedForeground,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const StatusBadge(status: 'active'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ShadButton(
                          size: ShadButtonSize.sm,
                          child: const Text('Edit Product'),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 8),
                        ShadButton.outline(
                          size: ShadButtonSize.sm,
                          child: const Text('View Analytics'),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
