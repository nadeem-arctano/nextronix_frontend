import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/admins_table_provider.dart';
import '../../../static_values/static_values.dart';
import '../../../widgets/advanced_data_table.dart';
import '../../../widgets/debounced_search_input.dart';
import '../../../widgets/filter_dropdown.dart';
import '../../../widgets/page_header.dart';
import '../../../widgets/skeletons.dart';

/// Super Admin → Admins table screen.
///
/// Displays a paginated table of brand admins with per-row stats:
/// usersCount, managersCount, productsCount, todayOrdersCount,
/// todaySalesAmount. Includes search, status filter, and action buttons
/// (edit, suspend, delete).
///
/// Uses the shared [DebouncedSearchInput] and [FilterDropdown] widgets so
/// the search/filter UX matches the products screen (auto-debounced search,
/// ShadSelect-based dropdowns).
///
/// Validates Requirements 10.1, 10.2, 10.3, 10.4, 10.5.
class AdminsTableScreen extends StatefulWidget {
  const AdminsTableScreen({super.key});

  @override
  State<AdminsTableScreen> createState() => _AdminsTableScreenState();
}

class _AdminsTableScreenState extends State<AdminsTableScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  /// Locally-managed hidden-columns set so the column-toggle button can
  /// live inside the filter row (alongside search and status filter)
  /// instead of inside the table's own toolbar.
  Set<String> _hiddenColumns = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final token = globalAccessToken;
      debugPrint(
        '[AdminsTableScreen] initState postFrame, token=${token != null ? "present" : "NULL"}',
      );
      if (token != null) {
        context.read<AdminsTableProvider>().loadAdmins(page: 1);
      } else {
        // Retry after a short delay to let auth bootstrap complete
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          debugPrint(
            '[AdminsTableScreen] retry, token=${globalAccessToken != null ? "present" : "NULL"}',
          );
          context.read<AdminsTableProvider>().loadAdmins(page: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminsTableProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'Admins',
                subtitle: 'Manage brand admin accounts',
              ),
              const SizedBox(height: 20),
              _buildFilters(provider),
              const SizedBox(height: 20),
              if (provider.isLoading && provider.rows.isEmpty)
                const Expanded(child: TableSkeleton(rows: 8, columns: 7))
              else
                Expanded(child: _buildTable(provider)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilters(AdminsTableProvider provider) {
    final theme = ShadTheme.of(context);
    final hasFilters =
        (provider.search != null && provider.search!.isNotEmpty) ||
        (provider.statusFilter != null && provider.statusFilter!.isNotEmpty);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Auto-debounced search (matches products screen behaviour).
          DebouncedSearchInput(
            controller: _searchCtrl,
            placeholder: 'Search by name or email',
            initialValue: provider.search,
            onSearch: provider.setSearch,
          ),
          const SizedBox(width: 12),

          // Status filter dropdown using the shared widget.
          FilterDropdown<String>(
            placeholder: 'Status',
            width: 140,
            value: provider.statusFilter ?? '',
            options: const [
              FilterOption(value: '', label: 'All'),
              FilterOption(value: 'active', label: 'Active'),
              FilterOption(value: 'blocked', label: 'Blocked'),
            ],
            onChanged: (value) => provider.setStatusFilter(
              value == null || value.isEmpty ? null : value,
            ),
          ),

          if (hasFilters) ...[
            const SizedBox(width: 12),
            ShadButton.ghost(
              size: ShadButtonSize.sm,
              onPressed: () {
                _searchCtrl.clear();
                provider.clearFilters();
              },
              child: Text(
                'Clear All',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],

          const SizedBox(width: 12),
          // Column-visibility toggle — same icon/menu as the table toolbar,
          // but rendered here so it sits next to the other filters.
          ColumnVisibilityMenu<AdminRow>(
            columns: _columnsFor(provider),
            hiddenColumns: _hiddenColumns,
            onChanged: (next) => setState(() => _hiddenColumns = next),
          ),
        ],
      ),
    );
  }

  /// Column definitions shared between [_buildTable] and the standalone
  /// [ColumnVisibilityMenu] in the filter row, so toggling a column in
  /// either place stays in sync.
  List<AdvancedTableColumn<AdminRow>> _columnsFor(
    AdminsTableProvider provider,
  ) {
    final theme = ShadTheme.of(context);
    return [
      AdvancedTableColumn<AdminRow>(
        key: 'name',
        label: 'Name',
        flex: 3,
        cellBuilder: (admin, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(admin.name, style: theme.textTheme.small),
              Text(
                admin.email,
                style: theme.textTheme.muted.copyWith(fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      ),
      AdvancedTableColumn<AdminRow>(
        key: 'status',
        label: 'Status',
        flex: 2,
        cellBuilder: (admin, _) => _StatusBadge(status: admin.status),
      ),
      AdvancedTableColumn<AdminRow>(
        key: 'usersCount',
        label: 'Users',
        flex: 1,
        align: TextAlign.right,
        cellBuilder: (admin, _) => Text(
          admin.usersCount.toString(),
          style: theme.textTheme.muted.copyWith(fontSize: 12),
        ),
      ),
      AdvancedTableColumn<AdminRow>(
        key: 'managersCount',
        label: 'Managers',
        flex: 1,
        align: TextAlign.right,
        cellBuilder: (admin, _) => Text(
          admin.managersCount.toString(),
          style: theme.textTheme.muted.copyWith(fontSize: 12),
        ),
      ),
      AdvancedTableColumn<AdminRow>(
        key: 'productsCount',
        label: 'Products',
        flex: 1,
        align: TextAlign.right,
        cellBuilder: (admin, _) => Text(
          admin.productsCount.toString(),
          style: theme.textTheme.muted.copyWith(fontSize: 12),
        ),
      ),
      AdvancedTableColumn<AdminRow>(
        key: 'todayOrdersCount',
        label: "Today's Orders",
        flex: 2,
        align: TextAlign.right,
        cellBuilder: (admin, _) => Text(
          admin.todayOrdersCount.toString(),
          style: theme.textTheme.muted.copyWith(fontSize: 12),
        ),
      ),
      AdvancedTableColumn<AdminRow>(
        key: 'todaySalesAmount',
        label: "Today's Sales",
        flex: 2,
        align: TextAlign.right,
        cellBuilder: (admin, _) => Text(
          '₹${admin.todaySalesAmount.toStringAsFixed(2)}',
          style: theme.textTheme.muted.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      AdvancedTableColumn<AdminRow>(
        key: 'actions',
        label: '',
        flex: 2,
        align: TextAlign.right,
        hideable: false,
        cellBuilder: (admin, _) => _ActionButtons(
          admin: admin,
          onEdit: () => _onEdit(admin),
          onSuspend: () => _onSuspend(admin),
          onDelete: () => _onDelete(admin),
        ),
      ),
    ];
  }

  Widget _buildTable(AdminsTableProvider provider) {
    final theme = ShadTheme.of(context);

    // Show pageSize inline error if present (Requirement 10.5).
    if (provider.fieldErrors.containsKey('pageSize')) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 36,
              color: theme.colorScheme.destructive,
            ),
            const SizedBox(height: 10),
            Text(
              provider.fieldErrors['pageSize']!,
              style: TextStyle(color: theme.colorScheme.destructive),
            ),
          ],
        ),
      );
    }

    return AdvancedDataTable<AdminRow>(
      columns: _columnsFor(provider),
      hiddenColumns: _hiddenColumns,
      onHiddenColumnsChanged: (next) => setState(() => _hiddenColumns = next),
      showColumnToggle: false,
      items: provider.rows,
      idOf: (admin) => admin.id,
      currentPage: provider.page,
      totalPages: provider.totalPages,
      totalItems: provider.totalCount,
      itemLabel: 'admins',
      onPageChanged: (page) => provider.loadAdmins(page: page),
    );
  }

  void _onEdit(AdminRow admin) {
    // Navigate to admin edit screen.
    // GoRouter navigation can be wired once the admin form screen (task 13.4)
    // is implemented.
  }

  Future<void> _onSuspend(AdminRow admin) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Suspend Admin'),
        content: Text(
          'Are you sure you want to suspend "${admin.name}"? '
          'They and their managers will be unable to log in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final err = await context.read<AdminsTableProvider>().suspendAdmin(
        admin.id,
      );
      if (err != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err.alertMessage)));
      }
    }
  }

  Future<void> _onDelete(AdminRow admin) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Admin'),
        content: Text(
          'Are you sure you want to delete "${admin.name}"? '
          'This will block the admin account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final err = await context.read<AdminsTableProvider>().deleteAdmin(
        admin.id,
      );
      if (err != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err.alertMessage)));
      }
    }
  }
}

/// Status badge widget for admin status display.
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'active';
    final color = isActive ? AppTheme.brand : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Row action buttons: edit, suspend, delete.
class _ActionButtons extends StatelessWidget {
  final AdminRow admin;
  final VoidCallback onEdit;
  final VoidCallback onSuspend;
  final VoidCallback onDelete;

  const _ActionButtons({
    required this.admin,
    required this.onEdit,
    required this.onSuspend,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(LucideIcons.pencil, size: 14),
          tooltip: 'Edit',
          onPressed: onEdit,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        ),
        if (admin.status == 'active')
          IconButton(
            icon: const Icon(LucideIcons.ban, size: 14),
            tooltip: 'Suspend',
            onPressed: onSuspend,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        IconButton(
          icon: Icon(LucideIcons.trash2, size: 14, color: Colors.red[400]),
          tooltip: 'Delete',
          onPressed: onDelete,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        ),
      ],
    );
  }
}
