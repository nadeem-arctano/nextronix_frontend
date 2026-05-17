import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/theme/app_theme.dart';
import '../../model/response/response.dart';
import '../../provider/coupon_provider.dart';
import '../../widgets/app_list_table.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/page_header.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/skeletons.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CouponProvider>().loadCoupons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CouponProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Coupons',
                actions: [
                  ShadButton(
                    leading: const Icon(LucideIcons.plus, size: 16),
                    onPressed: () => _showCouponDialog(context, provider),
                    child: const Text('Add Coupon'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: provider.isLoading
                    ? const TableSkeleton(rows: 6, columns: 5)
                    : provider.coupons.isEmpty
                    ? const EmptyWidget(message: 'No coupons found')
                    : AppListTable<CouponResult>(
                        columns: const [
                          AppTableColumn(label: 'Code', flex: 3),
                          AppTableColumn(label: 'Discount', flex: 2),
                          AppTableColumn(label: 'Min Order', flex: 2),
                          AppTableColumn(label: 'Usage', flex: 2),
                          AppTableColumn(label: 'Expiry', flex: 2),
                          AppTableColumn(label: 'Status', flex: 2),
                        ],
                        items: provider.coupons,
                        currentPage: 1,
                        totalPages: 1,
                        totalItems: provider.coupons.length,
                        itemLabel: 'coupons',
                        onPageChanged: (_) {},
                        rowBuilder: (coupon, _) =>
                            _buildCouponRow(coupon, provider),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCouponRow(CouponResult coupon, CouponProvider provider) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              coupon.code ?? '-',
              style: theme.textTheme.small.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(coupon.discountDisplay, style: theme.textTheme.small),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '₹${coupon.minOrderAmount?.toStringAsFixed(0) ?? '0'}',
              style: theme.textTheme.muted.copyWith(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${coupon.usedCount ?? 0}/${coupon.usageLimit == 0 ? '∞' : coupon.usageLimit}',
              style: theme.textTheme.muted.copyWith(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              coupon.expiryDate != null
                  ? DateFormat(
                      'dd MMM yyyy',
                    ).format(DateTime.parse(coupon.expiryDate!))
                  : 'No expiry',
              style: theme.textTheme.muted.copyWith(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: StatusBadge(status: coupon.status ?? 'active'),
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
                switch (value) {
                  case 'edit':
                    _showCouponDialog(context, provider, coupon: coupon);
                  case 'delete':
                    _confirmDelete(context, provider, coupon);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(LucideIcons.pencil, size: 16),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.trash2,
                        size: 16,
                        color: AppTheme.dangerColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Delete',
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
    );
  }

  void _showCouponDialog(
    BuildContext context,
    CouponProvider provider, {
    CouponResult? coupon,
  }) {
    final codeController = TextEditingController(text: coupon?.code ?? '');
    final valueController = TextEditingController(
      text: coupon?.discountValue?.toStringAsFixed(0) ?? '',
    );
    final minOrderController = TextEditingController(
      text: coupon?.minOrderAmount?.toStringAsFixed(0) ?? '',
    );
    final usageLimitController = TextEditingController(
      text: (coupon?.usageLimit ?? 0) > 0 ? coupon!.usageLimit.toString() : '',
    );
    final expiryController = TextEditingController(
      text: coupon?.expiryDate ?? '',
    );
    String discountType = coupon?.discountType ?? 'percentage';
    String status = coupon?.status ?? 'active';

    showShadDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => ShadDialog(
          title: Text(coupon == null ? 'Add Coupon' : 'Edit Coupon'),
          description: Text(
            coupon == null
                ? 'Create a new discount coupon'
                : 'Update coupon details',
          ),
          actions: [
            ShadButton.outline(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(ctx),
            ),
            ShadButton(
              child: Text(coupon == null ? 'Create' : 'Update'),
              onPressed: () async {
                if (codeController.text.isEmpty || valueController.text.isEmpty)
                  return;

                final value = double.tryParse(valueController.text);
                if (value == null) return;

                final minOrder = double.tryParse(minOrderController.text);
                final usageLimit = int.tryParse(usageLimitController.text);

                dynamic result;
                if (coupon == null) {
                  result = await provider.createCoupon(
                    code: codeController.text,
                    discountType: discountType,
                    discountValue: value,
                    minOrderAmount: minOrder,
                    expiryDate: expiryController.text.isNotEmpty
                        ? expiryController.text
                        : null,
                    usageLimit: usageLimit,
                    status: status,
                  );
                } else {
                  result = await provider.updateCoupon(
                    id: coupon.id!,
                    code: codeController.text,
                    discountType: discountType,
                    discountValue: value,
                    minOrderAmount: minOrder,
                    expiryDate: expiryController.text.isNotEmpty
                        ? expiryController.text
                        : null,
                    usageLimit: usageLimit,
                    status: status,
                  );
                }

                if (result == null && ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
          child: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text('Coupon Code *'),
                const SizedBox(height: 6),
                ShadInput(
                  controller: codeController,
                  placeholder: const Text('e.g. SAVE20'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Discount Type *'),
                          const SizedBox(height: 6),
                          ShadSelect<String>(
                            initialValue: discountType,
                            options: const [
                              ShadOption(
                                value: 'percentage',
                                child: Text('Percentage'),
                              ),
                              ShadOption(
                                value: 'fixed',
                                child: Text('Fixed Amount'),
                              ),
                            ],
                            selectedOptionBuilder: (context, value) => Text(
                              value == 'percentage'
                                  ? 'Percentage'
                                  : 'Fixed Amount',
                            ),
                            onChanged: (v) {
                              if (v != null) {
                                setDialogState(() => discountType = v);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            discountType == 'percentage'
                                ? 'Discount % *'
                                : 'Discount ₹ *',
                          ),
                          const SizedBox(height: 6),
                          ShadInput(
                            controller: valueController,
                            placeholder: Text(
                              discountType == 'percentage'
                                  ? 'e.g. 20'
                                  : 'e.g. 100',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Min Order Amount'),
                          const SizedBox(height: 6),
                          ShadInput(
                            controller: minOrderController,
                            placeholder: const Text('₹0'),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Usage Limit'),
                          const SizedBox(height: 6),
                          ShadInput(
                            controller: usageLimitController,
                            placeholder: const Text('0 = Unlimited'),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Expiry Date'),
                          const SizedBox(height: 6),
                          ShadInput(
                            controller: expiryController,
                            placeholder: const Text('YYYY-MM-DD'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Status'),
                          const SizedBox(height: 6),
                          ShadSelect<String>(
                            initialValue: status,
                            options: const [
                              ShadOption(
                                value: 'active',
                                child: Text('Active'),
                              ),
                              ShadOption(
                                value: 'inactive',
                                child: Text('Inactive'),
                              ),
                            ],
                            selectedOptionBuilder: (context, value) =>
                                Text(value),
                            onChanged: (v) {
                              if (v != null) {
                                setDialogState(() => status = v);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    CouponProvider provider,
    CouponResult coupon,
  ) {
    showShadDialog(
      context: context,
      builder: (ctx) => ShadDialog.alert(
        title: const Text('Delete Coupon'),
        description: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Are you sure you want to delete "${coupon.code}"?'),
        ),
        actions: [
          ShadButton.outline(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ShadButton.destructive(
            child: const Text('Delete'),
            onPressed: () {
              provider.deleteCoupon(id: coupon.id!);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
