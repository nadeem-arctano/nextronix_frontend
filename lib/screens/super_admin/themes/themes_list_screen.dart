import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../model/response/theme_list_response.dart';
import '../../../provider/theme_catalog_provider.dart';
import '../../../widgets/app_list_table.dart';
import '../../../widgets/debounced_search_input.dart';
import '../../../widgets/filter_dropdown.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/page_header.dart';
import '../../../widgets/status_badge.dart';

/// Super Admin → Themes list screen.
///
/// Displays a paginated table of themes with filters for search, mode,
/// and active status. Supports set-default, toggle-status, and delete
/// actions with appropriate guards for permanent themes.
///
/// Validates: Requirements 12.2–12.4, 12.6–12.8
class ThemesListScreen extends StatefulWidget {
  const ThemesListScreen({super.key});

  @override
  State<ThemesListScreen> createState() => _ThemesListScreenState();
}

class _ThemesListScreenState extends State<ThemesListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  Set<String> _hiddenColumns = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ThemeCatalogProvider>().loadThemes(page: 1);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeCatalogProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Themes',
                subtitle: 'Manage platform theme catalog',
                actions: [
                  AppListTableColumnMenu(
                    columns: _columns,
                    hiddenColumns: _hiddenColumns,
                    onChanged: (next) => setState(() => _hiddenColumns = next),
                  ),
                  ShadButton(
                    leading: const Icon(LucideIcons.plus, size: 16),
                    onPressed: () => context.go('/super-admin/themes/new'),
                    child: const Text('Create Theme'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildFilters(provider),
              const SizedBox(height: 20),
              Expanded(child: _buildBody(provider)),
            ],
          ),
        );
      },
    );
  }

  // ─── Filters ────────────────────────────────────────────────────────────────

  Widget _buildFilters(ThemeCatalogProvider provider) {
    final theme = ShadTheme.of(context);
    final hasFilters =
        (provider.search != null && provider.search!.isNotEmpty) ||
        provider.modeFilter != null ||
        provider.statusFilter != null;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          DebouncedSearchInput(
            controller: _searchCtrl,
            placeholder: 'Search themes...',
            initialValue: provider.search,
            onSearch: provider.setSearch,
          ),
          const SizedBox(width: 12),
          FilterDropdown<String>(
            placeholder: 'Mode',
            width: 140,
            value: provider.modeFilter ?? '',
            options: const [
              FilterOption(value: '', label: 'All Modes'),
              FilterOption(value: 'light', label: 'Light'),
              FilterOption(value: 'dark', label: 'Dark'),
            ],
            onChanged: (value) => provider.setModeFilter(
              value == null || value.isEmpty ? null : value,
            ),
          ),
          const SizedBox(width: 12),
          FilterDropdown<String>(
            placeholder: 'Status',
            width: 140,
            value: provider.statusFilter ?? '',
            options: const [
              FilterOption(value: '', label: 'All Status'),
              FilterOption(value: 'true', label: 'Active'),
              FilterOption(value: 'false', label: 'Inactive'),
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
        ],
      ),
    );
  }

  // ─── Body ───────────────────────────────────────────────────────────────────

  Widget _buildBody(ThemeCatalogProvider provider) {
    if (provider.isLoading && provider.themes.isEmpty) {
      return const LoadingWidget(message: 'Loading themes...');
    }
    if (provider.error != null && provider.themes.isEmpty) {
      return ErrorWidget2(
        message: provider.error!,
        onRetry: () => provider.loadThemes(page: 1),
      );
    }
    if (provider.themes.isEmpty) {
      return const EmptyWidget(
        message: 'No themes found',
        icon: LucideIcons.palette,
      );
    }

    final pagination = provider.pagination;
    final totalPages = pagination?.totalPages ?? 1;
    final totalItems = pagination?.totalItems ?? provider.themes.length;

    return AppListTable<ThemeResult>(
      columns: _columns,
      hiddenColumns: _hiddenColumns,
      items: provider.themes,
      currentPage: provider.page,
      totalPages: totalPages,
      totalItems: totalItems,
      itemLabel: 'themes',
      onPageChanged: provider.setPage,
      rowBuilder: (theme, _) => _buildRow(theme, provider),
    );
  }

  // ─── Columns ────────────────────────────────────────────────────────────────

  static const List<AppTableColumn> _columns = [
    AppTableColumn(key: 'name', label: 'Name', flex: 3),
    AppTableColumn(key: 'mode', label: 'Mode', flex: 2),
    AppTableColumn(key: 'active', label: 'Active', flex: 2),
    AppTableColumn(key: 'default', label: 'Default', flex: 2),
    AppTableColumn(key: 'permanent', label: 'Permanent', flex: 2),
  ];

  // ─── Row Builder ────────────────────────────────────────────────────────────

  Widget _buildRow(ThemeResult themeItem, ThemeCatalogProvider provider) {
    final shadTheme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Name column
          if (!AppListTable.isColumnHidden(context, 'name'))
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(themeItem.name, style: shadTheme.textTheme.small),
                  if (themeItem.description != null &&
                      themeItem.description!.isNotEmpty)
                    Text(
                      themeItem.description!,
                      style: shadTheme.textTheme.muted.copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

          // Mode column
          if (!AppListTable.isColumnHidden(context, 'mode'))
            Expanded(
              flex: 2,
              child: StatusBadge(
                status: themeItem.mode,
                colorMap: const {
                  'light': Color(0xFFF59E0B),
                  'dark': Color(0xFF6366F1),
                },
              ),
            ),

          // Active column
          if (!AppListTable.isColumnHidden(context, 'active'))
            Expanded(
              flex: 2,
              child: StatusBadge(
                status: themeItem.isActive ? 'active' : 'inactive',
              ),
            ),

          // Default column
          if (!AppListTable.isColumnHidden(context, 'default'))
            Expanded(
              flex: 2,
              child: themeItem.isDefault
                  ? const StatusBadge(
                      status: 'default',
                      colorMap: {'default': Color(0xFF10B981)},
                    )
                  : Text('—', style: shadTheme.textTheme.muted),
            ),

          // Permanent column
          if (!AppListTable.isColumnHidden(context, 'permanent'))
            Expanded(
              flex: 2,
              child: themeItem.isPermanent
                  ? const StatusBadge(
                      status: 'permanent',
                      colorMap: {'permanent': Color(0xFF6366F1)},
                    )
                  : Text('—', style: shadTheme.textTheme.muted),
            ),

          // Actions column
          SizedBox(width: 40, child: _buildActions(themeItem, provider)),
        ],
      ),
    );
  }

  // ─── Actions ────────────────────────────────────────────────────────────────

  Widget _buildActions(ThemeResult themeItem, ThemeCatalogProvider provider) {
    final theme = ShadTheme.of(context);
    return PopupMenuButton<String>(
      icon: Icon(
        LucideIcons.ellipsis,
        size: 18,
        color: theme.colorScheme.mutedForeground,
      ),
      padding: EdgeInsets.zero,
      onSelected: (value) => _handleAction(value, themeItem, provider),
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
        const PopupMenuItem(
          value: 'preview',
          child: Row(
            children: [
              Icon(LucideIcons.eye, size: 16),
              SizedBox(width: 8),
              Text('Preview'),
            ],
          ),
        ),
        if (!themeItem.isDefault)
          const PopupMenuItem(
            value: 'set_default',
            child: Row(
              children: [
                Icon(LucideIcons.star, size: 16),
                SizedBox(width: 8),
                Text('Set as Default'),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'toggle_status',
          enabled: !themeItem.isPermanent || themeItem.isActive == false,
          child: Row(
            children: [
              Icon(
                themeItem.isActive
                    ? LucideIcons.circleOff
                    : LucideIcons.circleCheck,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(themeItem.isActive ? 'Deactivate' : 'Activate'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          enabled: !themeItem.isPermanent,
          child: Row(
            children: [
              Icon(
                LucideIcons.trash2,
                size: 16,
                color: themeItem.isPermanent
                    ? theme.colorScheme.mutedForeground
                    : theme.colorScheme.destructive,
              ),
              const SizedBox(width: 8),
              Text(
                themeItem.isPermanent ? 'Delete (Permanent)' : 'Delete',
                style: TextStyle(
                  color: themeItem.isPermanent
                      ? theme.colorScheme.mutedForeground
                      : theme.colorScheme.destructive,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Action Handlers ────────────────────────────────────────────────────────

  void _handleAction(
    String action,
    ThemeResult themeItem,
    ThemeCatalogProvider provider,
  ) {
    switch (action) {
      case 'edit':
        context.go('/super-admin/themes/${themeItem.id}');
      case 'preview':
        // Open preview in a new browser tab
        final url = '/super-admin/themes/${themeItem.id}/preview';
        html.window.open(url, '_blank');
      case 'set_default':
        _confirmSetDefault(themeItem, provider);
      case 'toggle_status':
        if (themeItem.isPermanent && themeItem.isActive) {
          _showPermanentTooltip('Permanent themes cannot be deactivated');
        } else {
          _confirmToggleStatus(themeItem, provider);
        }
      case 'delete':
        if (themeItem.isPermanent) {
          _showPermanentTooltip('Permanent themes cannot be deleted');
        } else {
          _confirmDelete(themeItem, provider);
        }
    }
  }

  void _showPermanentTooltip(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _confirmSetDefault(
    ThemeResult themeItem,
    ThemeCatalogProvider provider,
  ) async {
    final confirmed = await showShadDialog<bool>(
      context: context,
      builder: (ctx) => ShadDialog.alert(
        title: const Text('Set as Default'),
        description: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Set "${themeItem.name}" as the default theme? '
            'This will be the fallback for all admins without a selection.',
          ),
        ),
        actions: [
          ShadButton.outline(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ShadButton(
            child: const Text('Set Default'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final err = await provider.setDefault(id: themeItem.id);
      if (err != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err.alertMessage)));
      }
    }
  }

  Future<void> _confirmToggleStatus(
    ThemeResult themeItem,
    ThemeCatalogProvider provider,
  ) async {
    final action = themeItem.isActive ? 'deactivate' : 'activate';
    final confirmed = await showShadDialog<bool>(
      context: context,
      builder: (ctx) => ShadDialog.alert(
        title: Text('${action[0].toUpperCase()}${action.substring(1)} Theme'),
        description: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Are you sure you want to $action "${themeItem.name}"?'),
        ),
        actions: [
          ShadButton.outline(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ShadButton(
            child: Text(action[0].toUpperCase() + action.substring(1)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final err = await provider.toggleStatus(id: themeItem.id);
      if (err != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err.alertMessage)));
      }
    }
  }

  Future<void> _confirmDelete(
    ThemeResult themeItem,
    ThemeCatalogProvider provider,
  ) async {
    final confirmed = await showShadDialog<bool>(
      context: context,
      builder: (ctx) => ShadDialog.alert(
        title: const Text('Delete Theme'),
        description: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Are you sure you want to delete "${themeItem.name}"? '
            'This action cannot be undone.',
          ),
        ),
        actions: [
          ShadButton.outline(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ShadButton.destructive(
            child: const Text('Delete'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final err = await provider.deleteTheme(id: themeItem.id);
      if (err != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err.alertMessage)));
      }
    }
  }
}
