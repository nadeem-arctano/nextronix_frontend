import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/theme/app_theme.dart';
import '../../provider/order_provider.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/loading_widget.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrderById(id: widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Consumer<OrderProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.selectedOrder == null) {
          return const LoadingWidget(message: 'Loading order...');
        }

        final order = provider.selectedOrder;
        if (order == null) {
          return const EmptyWidget(message: 'Order not found');
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ShadIconButton.ghost(
                    icon: const Icon(LucideIcons.arrowLeft),
                    onPressed: () => context.go('/orders'),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Order ${order.orderNumber ?? ''}',
                    style: theme.textTheme.h2,
                  ),
                  const SizedBox(width: 16),
                  StatusBadge(status: order.orderStatus ?? 'pending'),
                ],
              ),
              const SizedBox(height: 24),

              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 900) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildOrderDetails(order, theme),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 2,
                          child: _buildOrderSidebar(order, provider, theme),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _buildOrderDetails(order, theme),
                      const SizedBox(height: 24),
                      _buildOrderSidebar(order, provider, theme),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderDetails(dynamic order, ShadThemeData theme) {
    return Column(
      children: [
        // Order Items
        ShadCard(
          padding: const EdgeInsets.all(20),
          title: Text('Order Items', style: theme.textTheme.h4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              if (order.items != null && order.items!.isNotEmpty)
                ...order.items!.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.muted,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            LucideIcons.image,
                            color: theme.colorScheme.mutedForeground,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName ?? '',
                                style: theme.textTheme.small,
                              ),
                              Text(
                                'Qty: ${item.quantity ?? 0} × ₹${(item.price ?? 0).toStringAsFixed(0)}',
                                style: theme.textTheme.muted,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${(item.totalPrice ?? 0).toStringAsFixed(0)}',
                          style: theme.textTheme.small,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Text('No items', style: theme.textTheme.muted),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Order Summary
        ShadCard(
          padding: const EdgeInsets.all(20),
          title: Text('Order Summary', style: theme.textTheme.h4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildSummaryRow(
                'Subtotal',
                '₹${(order.subtotal ?? 0).toStringAsFixed(2)}',
                theme,
              ),
              _buildSummaryRow(
                'GST',
                '₹${(order.gstAmount ?? 0).toStringAsFixed(2)}',
                theme,
              ),
              _buildSummaryRow(
                'Shipping',
                '₹${(order.shippingCharge ?? 0).toStringAsFixed(2)}',
                theme,
              ),
              if ((order.discountAmount ?? 0) > 0)
                _buildSummaryRow(
                  'Discount',
                  '-₹${(order.discountAmount ?? 0).toStringAsFixed(2)}',
                  theme,
                  isDiscount: true,
                ),
              Divider(color: theme.colorScheme.border),
              _buildSummaryRow(
                'Total',
                '₹${(order.totalAmount ?? 0).toStringAsFixed(2)}',
                theme,
                isBold: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSidebar(
    dynamic order,
    OrderProvider provider,
    ShadThemeData theme,
  ) {
    return Column(
      children: [
        // Customer Info
        ShadCard(
          padding: const EdgeInsets.all(20),
          title: Text('Customer', style: theme.textTheme.h4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(order.customerName ?? 'N/A', style: theme.textTheme.small),
              const SizedBox(height: 4),
              Text(order.customerEmail ?? '', style: theme.textTheme.muted),
              if (order.customerMobile != null) ...[
                const SizedBox(height: 4),
                Text(order.customerMobile!, style: theme.textTheme.muted),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Payment Info
        ShadCard(
          padding: const EdgeInsets.all(20),
          title: Text('Payment', style: theme.textTheme.h4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Method', style: theme.textTheme.muted),
                  Text(
                    (order.paymentMethod ?? 'cod').toUpperCase(),
                    style: theme.textTheme.small,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Status', style: theme.textTheme.muted),
                  StatusBadge(status: order.paymentStatus ?? 'pending'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Update Status
        ShadCard(
          padding: const EdgeInsets.all(20),
          title: Text('Update Status', style: theme.textTheme.h4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text('Order Status'),
              const SizedBox(height: 6),
              ShadSelect<String>(
                initialValue: order.orderStatus ?? 'pending',
                options: const [
                  ShadOption(value: 'pending', child: Text('Pending')),
                  ShadOption(value: 'confirmed', child: Text('Confirmed')),
                  ShadOption(value: 'packed', child: Text('Packed')),
                  ShadOption(value: 'shipped', child: Text('Shipped')),
                  ShadOption(
                    value: 'out_for_delivery',
                    child: Text('Out for Delivery'),
                  ),
                  ShadOption(value: 'delivered', child: Text('Delivered')),
                  ShadOption(value: 'cancelled', child: Text('Cancelled')),
                  ShadOption(value: 'returned', child: Text('Returned')),
                ],
                selectedOptionBuilder: (context, value) => Text(
                  value.replaceAll('_', ' ').substring(0, 1).toUpperCase() +
                      value.replaceAll('_', ' ').substring(1),
                ),
                onChanged: (v) {
                  if (v != null) {
                    provider.updateOrderStatus(id: order.id!, status: v);
                  }
                },
              ),
              const SizedBox(height: 12),
              const Text('Payment Status'),
              const SizedBox(height: 6),
              ShadSelect<String>(
                initialValue: order.paymentStatus ?? 'pending',
                options: const [
                  ShadOption(value: 'pending', child: Text('Pending')),
                  ShadOption(value: 'paid', child: Text('Paid')),
                  ShadOption(value: 'failed', child: Text('Failed')),
                  ShadOption(value: 'refunded', child: Text('Refunded')),
                ],
                selectedOptionBuilder: (context, value) => Text(
                  value.substring(0, 1).toUpperCase() + value.substring(1),
                ),
                onChanged: (v) {
                  if (v != null) {
                    provider.updatePaymentStatus(
                      id: order.id!,
                      paymentStatus: v,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    ShadThemeData theme, {
    bool isBold = false,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold ? theme.textTheme.large : theme.textTheme.p,
          ),
          Text(
            value,
            style: isBold
                ? theme.textTheme.large
                : theme.textTheme.small.copyWith(
                    color: isDiscount ? AppTheme.successColor : null,
                  ),
          ),
        ],
      ),
    );
  }
}
