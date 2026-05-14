import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip('All', null, provider),
          const SizedBox(width: 8),
          _buildChip('Pending', 'pending', provider),
          const SizedBox(width: 8),
          _buildChip('Confirmed', 'confirmed', provider),
          const SizedBox(width: 8),
          _buildChip('Shipped', 'shipped', provider),
          const SizedBox(width: 8),
          _buildChip('Delivered', 'delivered', provider),
          const SizedBox(width: 8),
          _buildChip('Cancelled', 'cancelled', provider),
          const SizedBox(width: 8),
          _buildChip('Returned', 'returned', provider),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String? status, OrderProvider provider) {
    final isSelected = provider.statusFilter == status;
    return GestureDetector(
      onTap: () => provider.setStatusFilter(status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.sidebarColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.sidebarColor : AppTheme.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderRow(OrderResult order, OrderProvider provider) {
    return InkWell(
      onTap: () => context.go('/orders/${order.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Order number
            Expanded(
              flex: 2,
              child: Text(
                '#${order.orderNumber ?? ''}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),

            // Customer
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
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (order.customerEmail != null)
                          Text(
                            order.customerEmail!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Status
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusText(order.paymentStatus ?? 'pending'),
                  const SizedBox(height: 2),
                  _buildStatusText(order.orderStatus ?? 'pending'),
                ],
              ),
            ),

            // Total
            Expanded(
              flex: 2,
              child: Text(
                '₹${_formatAmount(order.totalAmount ?? 0)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),

            // Date
            Expanded(
              flex: 2,
              child: Text(
                order.createdAt != null
                    ? DateFormat(
                        'MMM dd',
                      ).format(DateTime.parse(order.createdAt!))
                    : '-',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),

            // Actions
            SizedBox(
              width: 40,
              child: PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_horiz,
                  size: 18,
                  color: AppTheme.textSecondary,
                ),
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  if (value == 'view') {
                    context.go('/orders/${order.id}');
                  } else {
                    provider.updateOrderStatus(id: order.id!, status: value);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_outlined, size: 16),
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

  Widget _buildStatusText(String status) {
    Color color;
    IconData? icon;
    switch (status.toLowerCase()) {
      case 'paid':
      case 'delivered':
        color = AppTheme.successColor;
        icon = Icons.check;
      case 'pending':
        color = AppTheme.warningColor;
        icon = null;
      case 'confirmed':
        color = AppTheme.infoColor;
        icon = Icons.check;
      case 'shipped':
        color = AppTheme.primaryColor;
        icon = Icons.check;
      case 'cancelled':
      case 'failed':
        color = AppTheme.dangerColor;
        icon = Icons.close;
      case 'refunded':
        color = Colors.orange;
        icon = Icons.replay;
      default:
        color = AppTheme.textSecondary;
        icon = null;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
        ],
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
