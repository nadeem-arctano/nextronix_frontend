import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/navigation_utils.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../provider/gst_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/page_header.dart';
import '../../widgets/skeletons.dart';

class StateWiseGstScreen extends StatefulWidget {
  const StateWiseGstScreen({super.key});

  @override
  State<StateWiseGstScreen> createState() => _StateWiseGstScreenState();
}

class _StateWiseGstScreenState extends State<StateWiseGstScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GstProvider>().loadStateWise();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Consumer<GstProvider>(
      builder: (context, p, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'State-wise GST',
                subtitle: 'GST collection grouped by shipping state',
                onBack: () => smartBack(context, '/admin/gst'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: p.isLoading && p.stateData.isEmpty
                    ? const ChartSkeleton(height: 280)
                    : p.stateData.isEmpty
                    ? const EmptyWidget(message: 'No data available')
                    : ShadCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            _header(theme),
                            Expanded(
                              child: ListView.separated(
                                itemCount: p.stateData.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  color: theme.colorScheme.border,
                                ),
                                itemBuilder: (_, i) {
                                  final s = p.stateData[i];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            s.state,
                                            style: theme.textTheme.small
                                                .copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '${s.orderCount}',
                                            style: theme.textTheme.small,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            '₹${s.taxableAmount.toStringAsFixed(0)}',
                                            style: theme.textTheme.small,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            '₹${s.cgst.toStringAsFixed(0)}',
                                            style: theme.textTheme.small,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            '₹${s.sgst.toStringAsFixed(0)}',
                                            style: theme.textTheme.small,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            '₹${s.igst.toStringAsFixed(0)}',
                                            style: theme.textTheme.small,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            '₹${s.totalGst.toStringAsFixed(0)}',
                                            style: theme.textTheme.small
                                                .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
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
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _header(ShadThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.3),
        border: Border(bottom: BorderSide(color: theme.colorScheme.border)),
      ),
      child: Row(
        children: [
          _hCell('STATE', 3, theme),
          _hCell('ORDERS', 1, theme),
          _hCell('TAXABLE', 2, theme),
          _hCell('CGST', 2, theme),
          _hCell('SGST', 2, theme),
          _hCell('IGST', 2, theme),
          _hCell('TOTAL GST', 2, theme),
        ],
      ),
    );
  }

  Widget _hCell(String t, int f, ShadThemeData theme) => Expanded(
    flex: f,
    child: Text(
      t,
      style: theme.textTheme.muted.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  );
}
