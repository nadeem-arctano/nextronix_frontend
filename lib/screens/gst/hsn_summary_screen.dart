import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/navigation_utils.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../provider/gst_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/page_header.dart';

class HsnSummaryScreen extends StatefulWidget {
  const HsnSummaryScreen({super.key});

  @override
  State<HsnSummaryScreen> createState() => _HsnSummaryScreenState();
}

class _HsnSummaryScreenState extends State<HsnSummaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GstProvider>().loadHsnSummary();
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
                title: 'HSN Summary',
                subtitle: 'GST grouped by HSN code',
                onBack: () => smartBack(context, '/admin/gst'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: p.isLoading && p.hsnData.isEmpty
                    ? const LoadingWidget()
                    : p.hsnData.isEmpty
                    ? const EmptyWidget(message: 'No HSN data available')
                    : ShadCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            _header(theme),
                            Expanded(
                              child: ListView.separated(
                                itemCount: p.hsnData.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  color: theme.colorScheme.border,
                                ),
                                itemBuilder: (_, i) {
                                  final h = p.hsnData[i];
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
                                            h.hsnCode,
                                            style: theme.textTheme.small
                                                .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'monospace',
                                                ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            h.description,
                                            style: theme.textTheme.small
                                                .copyWith(fontSize: 12),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '${h.gstPercent}%',
                                            style: theme.textTheme.small,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            '${h.totalQuantity}',
                                            style: theme.textTheme.small,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            '₹${h.taxableValue.toStringAsFixed(0)}',
                                            style: theme.textTheme.small,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            '₹${h.totalGst.toStringAsFixed(0)}',
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
          _hCell('HSN CODE', 2, theme),
          _hCell('DESCRIPTION', 4, theme),
          _hCell('GST %', 1, theme),
          _hCell('QUANTITY', 2, theme),
          _hCell('TAXABLE', 2, theme),
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
