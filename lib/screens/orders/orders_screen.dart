import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/theme/app_theme.dart';
import '../../model/response/response.dart';
import '../../provider/order_provider.dart';
import '../../widgets/app_list_table.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/page_header.dart';
import '../../widgets/user_avatar.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OrderProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(title: 'Orders'),
              const SizedBox(height: 20),
              _buildFilterRow(provider),
              const SizedBox(height: 20),
              Expanded(
                child: provider.isLoading
                    ? const LoadingWidget()
                    : provider.orders.isEmpty
                    ? const EmptyWidget(message: 'No orders found')
                    : AppListTable<OrderResult>(
                        columns: const [
                          AppTableColumn(label: 'Order', flex: 2),
                          AppTableColumn(label: 'Customer', flex: 3),
                          AppTableColumn(label: 'Status', flex: 2),
                          AppTableColumn(label: 'Total', flex: 2),
                          AppTableColumn(label: 'Date', flex: 2),
                        ],
                        items: provider.orders,
                        currentPage: provider.currentPage,
                        totalPages: provider.totalPages,
                        totalItems: provider.totalItems,
                        itemLabel: 'orders',
                        onPageChanged: (page) =>
                            provider.loadOrders(page: page),
                        rowBuilder: (order, _) =>
                            _buildOrderRow(order, provider),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterRow(OrderProvider provider) {
    final theme = ShadTheme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip('All', null, provider, theme),
          const SizedBox(width: 8),
          _buildChip('Pending', 'pending', provider, theme),
          const SizedBox(width: 8),
          _buildChip('Confirmed', 'confirmed', provider, theme),
          const SizedBox(width: 8),
          _buildChip('Shipped', 'shipped', provider, theme),
          const SizedBox(width: 8),
          _buildChip('Delivered', 'delivered', provider, theme),
          const SizedBox(width: 8),
          _buildChip('Cancelled', 'cancelled', provider, theme),
          const SizedBox(width: 8),
          _buildChip('Returned', 'returned', provider, theme),
        ],
      ),
    );
  }

  Widget _buildChip(
    String label,
    String? status,
    OrderProvider provider,
    ShadThemeData theme,
  ) {
    final isSelected = provider.statusFilter == status;
    return GestureDetector(
      onTap: () => provider.setStatusFilter(status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.border,
          ),
        ),
        child: Text(
          label,
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

  Widget _buildOrderRow(OrderResult order, OrderProvider provider) {
    final theme = ShadTheme.of(context);
    return InkWell(
      onTap: () => context.go('/admin/orders/${order.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                '#${order.orderNumber ?? ''}',
                style: theme.textTheme.small,
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  UserAvatar(name: order.customerName ?? 'N', radius: 15),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.customerName ?? 'N/A',
                          style: theme.textTheme.small,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (order.customerEmail != null)
                          Text(
                            order.customerEmail!,
                            style: theme.textTheme.muted.copyWith(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusDot(order.paymentStatus ?? 'pending'),
                  const SizedBox(height: 2),
                  _buildStatusDot(order.orderStatus ?? 'pending'),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '₹${_formatAmount(order.totalAmount ?? 0)}',
                style: theme.textTheme.small,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                order.createdAt != null
                    ? DateFormat(
                        'MMM dd',
                      ).format(DateTime.parse(order.createdAt!))
                    : '-',
                style: theme.textTheme.muted,
              ),
            ),
            SizedBox(
              width: 40,
              child: PopupMenuButton<String>(
                icon: Icon(
                  LucideIcons.ellipsis,
                  size: 18,
                  color: theme.colorScheme.mutedForeground,
                ),
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  if (value == 'view') {
                    context.go('/admin/orders/${order.id}');
                  } else {
                    provider.updateOrderStatus(id: order.id!, status: value);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(LucideIcons.eye, size: 16),
                        SizedBox(width: 8),
                        Text('View Details'),
                      ],
                    ),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(value: 'confirmed', child: Text('Confirm')),
                  PopupMenuItem(value: 'shipped', child: Text('Ship')),
                  PopupMenuItem(value: 'delivered', child: Text('Deliver')),
                  PopupMenuItem(
                    value: 'cancelled',
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: AppTheme.dangerColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDot(String status) {
    final color = AppTheme.getStatusColor(status);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          status.replaceAll('_', ' ').substring(0, 1).toUpperCase() +
              status.replaceAll('_', ' ').substring(1),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return NumberFormat('#,##,###').format(amount.toInt());
    }
    return amount.toStringAsFixed(0);
  }
}
