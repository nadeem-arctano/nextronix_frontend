import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Common pagination widget for data tables
class DataTablePagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int showingCount;
  final String itemLabel;
  final ValueChanged<int> onPageChanged;

  const DataTablePagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.showingCount,
    this.itemLabel = 'items',
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing $showingCount of $totalItems $itemLabel',
            style: theme.textTheme.muted.copyWith(fontSize: 12),
          ),
          Row(
            children: [
              ShadIconButton.outline(
                icon: const Icon(LucideIcons.chevronLeft, size: 16),
                onPressed: currentPage > 1
                    ? () => onPageChanged(currentPage - 1)
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Page $currentPage of $totalPages',
                  style: theme.textTheme.muted.copyWith(fontSize: 12),
                ),
              ),
              ShadIconButton.outline(
                icon: const Icon(LucideIcons.chevronRight, size: 16),
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(currentPage + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
