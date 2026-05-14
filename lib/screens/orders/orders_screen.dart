import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../provider/order_provider.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/loading_widget.dart';

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
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Orders',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Status filter chips
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
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
                ),
              ),
              const SizedBox(height: 16),

              // Orders Table
              Card(
                child: provider.isLoading
                    ? const SizedBox(height: 300, child: LoadingWidget())
                    : provider.orders.isEmpty
                    ? const SizedBox(
                        height: 300,
                        child: EmptyWidget(message: 'No orders found'),
                      )
                    : Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 24,
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
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                    ),
                                    DataCell(
                                      Text(
                                        '₹${(order.totalAmount ?? 0).toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      StatusBadge(
                                        status:
                                            order.paymentStatus ?? 'pending',
                                      ),
                                    ),
                                    DataCell(
                                      StatusBadge(
                                        status: order.orderStatus ?? 'pending',
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        order.createdAt != null
                                            ? DateFormat('dd MMM yyyy').format(
                                                DateTime.parse(
                                                  order.createdAt!,
                                                ),
                                              )
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
                                            onPressed: () => context.go(
                                              '/orders/${order.id}',
                                            ),
                                            tooltip: 'View Details',
                                          ),
                                          PopupMenuButton<String>(
                                            icon: const Icon(
                                              Icons.more_vert,
                                              size: 18,
                                            ),
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
                          // Pagination
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Showing ${provider.orders.length} of ${provider.totalItems} orders',
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.chevron_left),
                                      onPressed: provider.currentPage > 1
                                          ? () => provider.loadOrders(
                                              page: provider.currentPage - 1,
                                            )
                                          : null,
                                    ),
                                    Text(
                                      'Page ${provider.currentPage} of ${provider.totalPages}',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.chevron_right),
                                      onPressed:
                                          provider.currentPage <
                                              provider.totalPages
                                          ? () => provider.loadOrders(
                                              page: provider.currentPage + 1,
                                            )
                                          : null,
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
          ),
        );
      },
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
      selectedColor: AppTheme.primaryColor.withOpacity(0.15),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
