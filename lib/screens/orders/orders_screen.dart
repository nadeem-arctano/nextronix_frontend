import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../model/response/response.dart';
import '../../provider/order_provider.dart';
import '../../widgets/data_table_pagination.dart';
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
              // Header
              const PageHeader(title: 'Orders'),
              const SizedBox(height: 20),

              // Filter chips row
              _buildFilterRow(provider),
              const SizedBox(height: 20),

              // Table
              Expanded(
                child: provider.isLoading
                    ? const LoadingWidget()
                    : provider.orders.isEmpty
                    ? const EmptyWidget(message: 'No orders found')
                    : _buildOrdersTable(provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterRow(OrderProvider provider) {
    return Row(
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

  Widget _buildOrdersTable(OrderProvider provider) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Column(
              children: [
                // Table header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppTheme.borderColor),
                    ),
                  ),
                  child: Row(
                    children: [
                      _headerCell('Order', flex: 2),
                      _headerCell('Customer', flex: 3),
                      _headerCell('Status', flex: 2),
                      _headerCell('Total', flex: 2),
                      _headerCell('Date', flex: 2),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                // Table rows
                Expanded(
                  child: ListView.separated(
                    itemCount: provider.orders.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: AppTheme.dividerColor),
                    itemBuilder: (context, index) {
                      final order = provider.orders[index];
                      return _buildOrderRow(order, provider);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Pagination
        DataTablePagination(
          currentPage: provider.currentPage,
          totalPages: provider.totalPages,
          totalItems: provider.totalItems,
          showingCount: provider.orders.length,
          itemLabel: 'orders',
          onPageChanged: (page) => provider.loadOrders(page: page),
        ),
      ],
    );
  }

  Widget _headerCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppTheme.textSecondary,
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

            // Status (payment + order)
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
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('View Details'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'confirmed',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 16),
                        SizedBox(width: 8),
                        Text('Confirm'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'shipped',
                    child: Row(
                      children: [
                        Icon(Icons.local_shipping_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('Ship'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delivered',
                    child: Row(
                      children: [
                        Icon(Icons.done_all, size: 16),
                        SizedBox(width: 8),
                        Text('Deliver'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'cancelled',
                    child: Row(
                      children: [
                        Icon(
                          Icons.cancel_outlined,
                          size: 16,
                          color: AppTheme.dangerColor,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Cancel',
                          style: TextStyle(color: AppTheme.dangerColor),
                        ),
                      ],
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
        color = AppTheme.successColor;
        icon = Icons.check;
        break;
      case 'delivered':
        color = AppTheme.successColor;
        icon = Icons.check;
        break;
      case 'pending':
        color = AppTheme.warningColor;
        icon = null;
        break;
      case 'confirmed':
        color = AppTheme.infoColor;
        icon = Icons.check;
        break;
      case 'shipped':
        color = AppTheme.primaryColor;
        icon = Icons.check;
        break;
      case 'cancelled':
        color = AppTheme.dangerColor;
        icon = Icons.close;
        break;
      case 'refunded':
        color = Colors.orange;
        icon = Icons.replay;
        break;
      case 'failed':
        color = AppTheme.dangerColor;
        icon = Icons.close;
        break;
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
