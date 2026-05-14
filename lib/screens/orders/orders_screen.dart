import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../provider/order_provider.dart';
import '../../widgets/data_table_pagination.dart';
import '../../widgets/filter_bar.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/page_header.dart';
import '../../widgets/status_badge.dart';
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
              const PageHeader(
                title: 'Orders',
                subtitle: 'Manage customer orders',
              ),
              const SizedBox(height: 24),

              // Status filter chips
              FilterBar(
                children: [
                  _buildFilterChip('All', null, provider),
                  _buildFilterChip('Pending', 'pending', provider),
                  _buildFilterChip('Confirmed', 'confirmed', provider),
                  _buildFilterChip('Shipped', 'shipped', provider),
                  _buildFilterChip('Delivered', 'delivered', provider),
                  _buildFilterChip('Cancelled', 'cancelled', provider),
                  _buildFilterChip('Returned', 'returned', provider),
                ],
              ),
              const SizedBox(height: 16),

              // Orders Table
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

  Widget _buildOrdersTable(OrderProvider provider) {
    return Column(
      children: [
        Expanded(
          child: Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 24,
                  headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                  columns: const [
                    DataColumn(label: Text('ORDER #')),
                    DataColumn(label: Text('CUSTOMER')),
                    DataColumn(label: Text('AMOUNT')),
                    DataColumn(label: Text('PAYMENT')),
                    DataColumn(label: Text('STATUS')),
                    DataColumn(label: Text('DATE')),
                    DataColumn(label: Text('ACTIONS')),
                  ],
                  rows: provider.orders.map((order) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            order.orderNumber ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              UserAvatar(
                                name: order.customerName ?? 'N',
                                radius: 14,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    order.customerName ?? 'N/A',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    order.customerEmail ?? '',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(
                            '₹${(order.totalAmount ?? 0).toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        DataCell(
                          StatusBadge(status: order.paymentStatus ?? 'pending'),
                        ),
                        DataCell(
                          StatusBadge(status: order.orderStatus ?? 'pending'),
                        ),
                        DataCell(
                          Text(
                            order.createdAt != null
                                ? DateFormat(
                                    'dd MMM yyyy',
                                  ).format(DateTime.parse(order.createdAt!))
                                : '-',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.visibility_outlined,
                                  size: 18,
                                ),
                                onPressed: () =>
                                    context.go('/orders/${order.id}'),
                                tooltip: 'View Details',
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, size: 18),
                                onSelected: (status) =>
                                    provider.updateOrderStatus(
                                      id: order.id!,
                                      status: status,
                                    ),
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(
                                    value: 'confirmed',
                                    child: Text('Confirm'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'packed',
                                    child: Text('Pack'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'shipped',
                                    child: Text('Ship'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delivered',
                                    child: Text('Deliver'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'cancelled',
                                    child: Text('Cancel'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),

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

  Widget _buildFilterChip(
    String label,
    String? status,
    OrderProvider provider,
  ) {
    final isSelected = provider.statusFilter == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => provider.setStatusFilter(status),
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
