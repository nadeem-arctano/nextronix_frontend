import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/navigation_utils.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../provider/report_provider.dart';
import '../../widgets/page_header.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/status_badge.dart';
import 'widgets/export_buttons.dart';

class CouponReportScreen extends StatefulWidget {
  const CouponReportScreen({super.key});

  @override
  State<CouponReportScreen> createState() => _CouponReportScreenState();
}

class _CouponReportScreenState extends State<CouponReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().loadCouponReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Consumer<ReportProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Coupon Usage Report',
                subtitle: 'Coupon performance and discount analysis',
                onBack: () => smartBack(context, '/admin/reports'),
                actions: const [ExportButtons(reportType: 'coupon-report')],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: provider.isLoading
                    ? const LoadingWidget(message: 'Loading report...')
                    : provider.error != null
                    ? Center(child: Text(provider.error!))
                    : provider.couponReport.isEmpty
                    ? const Center(child: Text('No coupon data available'))
                    : _buildTable(provider, theme),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTable(ReportProvider provider, ShadThemeData theme) {
    return ShadCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.muted.withValues(alpha: 0.3),
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.border),
              ),
            ),
            child: Row(
              children: [
                _headerCell('CODE', 2, theme),
                _headerCell('TYPE', 2, theme),
                _headerCell('VALUE', 1, theme),
                _headerCell('USAGE', 1, theme),
                _headerCell('DISCOUNT GIVEN', 2, theme),
                _headerCell('REVENUE', 2, theme),
                _headerCell('STATUS', 1, theme),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: provider.couponReport.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: theme.colorScheme.border),
              itemBuilder: (context, index) {
                final item = provider.couponReport[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.code,
                          style: theme.textTheme.small.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.discountType,
                          style: theme.textTheme.small,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          item.discountType == 'percentage'
                              ? '${item.discountValue.toStringAsFixed(0)}%'
                              : '₹${item.discountValue.toStringAsFixed(0)}',
                          style: theme.textTheme.small,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${item.totalUsage}${item.usageLimit != null ? '/${item.usageLimit}' : ''}',
                          style: theme.textTheme.small,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹${item.totalDiscountGiven.toStringAsFixed(0)}',
                          style: theme.textTheme.small,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹${item.revenueGenerated.toStringAsFixed(0)}',
                          style: theme.textTheme.small,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: StatusBadge(status: item.status),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String text, int flex, ShadThemeData theme) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: theme.textTheme.muted.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
