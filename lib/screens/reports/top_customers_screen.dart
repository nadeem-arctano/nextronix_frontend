import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/navigation_utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../provider/report_provider.dart';
import '../../widgets/page_header.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/user_avatar.dart';
import 'widgets/date_range_filter.dart';
import 'widgets/export_buttons.dart';

class TopCustomersScreen extends StatefulWidget {
  const TopCustomersScreen({super.key});

  @override
  State<TopCustomersScreen> createState() => _TopCustomersScreenState();
}

class _TopCustomersScreenState extends State<TopCustomersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().loadTopCustomers();
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
                title: 'Top Customers',
                subtitle:
                    'Highest spending customers ranked by total purchases',
                onBack: () => smartBack(context, '/admin/reports'),
                actions: const [ExportButtons(reportType: 'top-customers')],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  DateRangeFilter(
                    startDate: provider.startDate,
                    endDate: provider.endDate,
                    onChanged: (range) {
                      if (range != null) {
                        provider.setDateRange(range.start, range.end);
                        provider.loadTopCustomers();
                      }
                    },
                    onClear: () {
                      provider.setDateRange(null, null);
                      provider.loadTopCustomers();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: provider.isLoading
                    ? const LoadingWidget(message: 'Loading report...')
                    : provider.error != null
                    ? Center(child: Text(provider.error!))
                    : provider.topCustomers.isEmpty
                    ? const Center(child: Text('No customer data available'))
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
                _headerCell('#', 0, theme, width: 40),
                _headerCell('CUSTOMER', 3, theme),
                _headerCell('EMAIL', 3, theme),
                _headerCell('ORDERS', 1, theme),
                _headerCell('TOTAL SPENDING', 2, theme),
                _headerCell('LAST ORDER', 2, theme),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: provider.topCustomers.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: theme.colorScheme.border),
              itemBuilder: (context, index) {
                final item = provider.topCustomers[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          '${index + 1}',
                          style: theme.textTheme.muted.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            UserAvatar(name: item.name ?? 'U', radius: 14),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.name ?? 'N/A',
                                style: theme.textTheme.small,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.email ?? '-',
                          style: theme.textTheme.muted.copyWith(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${item.totalOrders}',
                          style: theme.textTheme.small,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹${item.totalSpending.toStringAsFixed(0)}',
                          style: theme.textTheme.small.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.lastOrderDate != null
                              ? DateFormat(
                                  'MMM dd, yyyy',
                                ).format(DateTime.parse(item.lastOrderDate!))
                              : '-',
                          style: theme.textTheme.muted.copyWith(fontSize: 12),
                        ),
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

  Widget _headerCell(
    String text,
    int flex,
    ShadThemeData theme, {
    double? width,
  }) {
    final child = Text(
      text,
      style: theme.textTheme.muted.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
    if (width != null) return SizedBox(width: width, child: child);
    return Expanded(flex: flex, child: child);
  }
}
