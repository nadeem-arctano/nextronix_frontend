import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/theme/app_theme.dart';
import '../../model/response/response.dart';
import '../../provider/user_provider.dart';
import '../../widgets/app_list_table.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/page_header.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/skeletons.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Restrict the list to customers only (no admin/manager).
      final provider = context.read<UserProvider>();
      provider.setRoleFilter('customer');
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      context.read<UserProvider>().setSearch(
        value.trim().isEmpty ? null : value.trim(),
      );
    });
  }

  Future<void> _pickDateRange(UserProvider provider) async {
    final picked = await showDialog<DateTimeRange>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => _CompactDateRangeDialog(
        initialStart: provider.startDate,
        initialEnd: provider.endDate,
      ),
    );

    if (picked != null) {
      provider.setDateRange(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(title: 'Customers'),
              const SizedBox(height: 20),
              _buildFilters(provider),
              const SizedBox(height: 20),
              Expanded(
                child: provider.isLoading && provider.users.isEmpty
                    ? const TableSkeleton(rows: 8, columns: 5)
                    : provider.error != null && provider.users.isEmpty
                    ? ErrorWidget2(
                        message: provider.error!,
                        onRetry: () => provider.loadUsers(),
                      )
                    : provider.users.isEmpty
                    ? const EmptyWidget(message: 'No customers found')
                    : AppListTable<UserListResult>(
                        columns: const [
                          AppTableColumn(label: 'Customer Name', flex: 3),
                          AppTableColumn(label: 'Email', flex: 3),
                          AppTableColumn(label: 'Mobile', flex: 2),
                          AppTableColumn(label: 'Status', flex: 2),
                          AppTableColumn(label: 'Joined', flex: 2),
                        ],
                        items: provider.users,
                        currentPage: provider.currentPage,
                        totalPages: provider.pagination?.totalPages ?? 1,
                        totalItems: provider.pagination?.totalItems ?? 0,
                        itemLabel: 'customers',
                        onPageChanged: (page) => provider.loadUsers(page: page),
                        rowBuilder: (user, _) => _buildUserRow(user, provider),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilters(UserProvider provider) {
    final theme = ShadTheme.of(context);
    final dateFmt = DateFormat('MMM dd');
    final hasDateRange = provider.startDate != null && provider.endDate != null;
    final dateLabel = hasDateRange
        ? '${dateFmt.format(provider.startDate!)} – ${dateFmt.format(provider.endDate!)}'
        : 'Date range';

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Search
          SizedBox(
            width: 260,
            child: ShadInput(
              controller: _searchController,
              placeholder: const Text('Search name, email...'),
              style: const TextStyle(fontSize: 12),
              onSubmitted: (value) => provider.setSearch(value),
              onChanged: (value) {
                setState(() {});
                _onSearchChanged(value);
              },
            ),
          ),
          const SizedBox(width: 12),

          // Status chips
          _buildChip(
            'All',
            null,
            provider.statusFilter,
            (v) => provider.setStatusFilter(v),
            theme,
          ),
          const SizedBox(width: 6),
          _buildChip(
            'Active',
            'active',
            provider.statusFilter,
            (v) => provider.setStatusFilter(v),
            theme,
          ),
          const SizedBox(width: 6),
          _buildChip(
            'Inactive',
            'inactive',
            provider.statusFilter,
            (v) => provider.setStatusFilter(v),
            theme,
          ),
          const SizedBox(width: 12),

          // Date range
          GestureDetector(
            onTap: () => _pickDateRange(provider),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: hasDateRange
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: hasDateRange
                      ? theme.colorScheme.primary
                      : theme.colorScheme.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.calendar,
                    size: 13,
                    color: hasDateRange
                        ? theme.colorScheme.primaryForeground
                        : theme.colorScheme.mutedForeground,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: hasDateRange
                          ? theme.colorScheme.primaryForeground
                          : theme.colorScheme.mutedForeground,
                    ),
                  ),
                  if (hasDateRange) ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => provider.setDateRange(null, null),
                      child: Icon(
                        LucideIcons.x,
                        size: 13,
                        color: theme.colorScheme.primaryForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    String label,
    String? value,
    String? currentValue,
    ValueChanged<String?> onTap,
    ShadThemeData theme,
  ) {
    final isSelected = currentValue == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.primaryForeground
                : theme.colorScheme.mutedForeground,
          ),
        ),
      ),
    );
  }

  Widget _buildUserRow(UserListResult user, UserProvider provider) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                UserAvatar(name: user.name ?? 'U', radius: 15),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    user.name ?? 'N/A',
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
              user.email ?? '-',
              style: theme.textTheme.p.copyWith(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(user.mobile ?? '-', style: theme.textTheme.muted),
          ),
          Expanded(
            flex: 2,
            child: StatusBadge(status: user.status ?? 'active'),
          ),
          Expanded(
            flex: 2,
            child: Text(
              user.createdAt != null
                  ? DateFormat('MMM dd').format(DateTime.parse(user.createdAt!))
                  : '-',
              style: theme.textTheme.muted,
            ),
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
                if (user.id != null) {
                  provider.updateUserStatus(id: user.id!, status: value);
                }
              },
              itemBuilder: (_) => [
                if (user.status != 'active')
                  const PopupMenuItem(
                    value: 'active',
                    child: Text('Set Active'),
                  ),
                if (user.status != 'inactive')
                  const PopupMenuItem(
                    value: 'inactive',
                    child: Text('Set Inactive'),
                  ),
                if (user.status != 'blocked')
                  PopupMenuItem(
                    value: 'blocked',
                    child: Text(
                      'Block Customer',
                      style: TextStyle(color: AppTheme.dangerColor),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact, web-friendly date range picker shown inside a centered dialog
/// (max ~360px wide) instead of the default full-screen `showDateRangePicker`.
///
/// Flow: user picks the start date, taps "Next", then picks the end date
/// and taps "Apply". Returns a [DateTimeRange] or null if dismissed.
class _CompactDateRangeDialog extends StatefulWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;

  const _CompactDateRangeDialog({this.initialStart, this.initialEnd});

  @override
  State<_CompactDateRangeDialog> createState() =>
      _CompactDateRangeDialogState();
}

class _CompactDateRangeDialogState extends State<_CompactDateRangeDialog> {
  late DateTime _start;
  late DateTime _end;
  bool _editingStart = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _start = widget.initialStart ?? now;
    _end = widget.initialEnd ?? now;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final dateFmt = DateFormat('MMM dd, yyyy');
    final firstDate = DateTime(2020);
    final lastDate = DateTime.now();

    return Dialog(
      backgroundColor: theme.colorScheme.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _editingStart ? 'Select start date' : 'Select end date',
                style: theme.textTheme.h4,
              ),
              const SizedBox(height: 4),
              Text(
                '${dateFmt.format(_start)}  →  ${dateFmt.format(_end)}',
                style: theme.textTheme.muted.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 320,
                child: CalendarDatePicker(
                  key: ValueKey(_editingStart),
                  initialDate: _editingStart ? _start : _end,
                  firstDate: _editingStart ? firstDate : _start,
                  lastDate: lastDate,
                  onDateChanged: (date) {
                    setState(() {
                      if (_editingStart) {
                        _start = date;
                        if (_end.isBefore(_start)) _end = _start;
                      } else {
                        _end = date;
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  if (!_editingStart)
                    TextButton(
                      onPressed: () => setState(() => _editingStart = true),
                      child: const Text('Back'),
                    ),
                  const SizedBox(width: 4),
                  if (_editingStart)
                    FilledButton(
                      onPressed: () => setState(() => _editingStart = false),
                      child: const Text('Next'),
                    )
                  else
                    FilledButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pop(DateTimeRange(start: _start, end: _end)),
                      child: const Text('Apply'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
