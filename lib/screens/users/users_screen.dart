import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../model/response/response.dart';
import '../../provider/user_provider.dart';
import '../../widgets/app_list_table.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/page_header.dart';
import '../../widgets/role_badge.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/user_avatar.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              const PageHeader(title: 'Users'),
              const SizedBox(height: 20),
              _buildFilters(provider),
              const SizedBox(height: 20),
              Expanded(
                child: provider.isLoading && provider.users.isEmpty
                    ? const LoadingWidget(message: 'Loading users...')
                    : provider.error != null && provider.users.isEmpty
                    ? ErrorWidget2(
                        message: provider.error!,
                        onRetry: () => provider.loadUsers(),
                      )
                    : provider.users.isEmpty
                    ? const EmptyWidget(message: 'No users found')
                    : AppListTable<UserListResult>(
                        columns: const [
                          AppTableColumn(label: 'User', flex: 3),
                          AppTableColumn(label: 'Email', flex: 3),
                          AppTableColumn(label: 'Mobile', flex: 2),
                          AppTableColumn(label: 'Role', flex: 2),
                          AppTableColumn(label: 'Status', flex: 2),
                          AppTableColumn(label: 'Joined', flex: 2),
                        ],
                        items: provider.users,
                        currentPage: provider.currentPage,
                        totalPages: provider.pagination?.totalPages ?? 1,
                        totalItems: provider.pagination?.totalItems ?? 0,
                        itemLabel: 'users',
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Search
          SizedBox(
            width: 240,
            height: 36,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search name, email...',
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearch('');
                          provider.loadUsers();
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              style: const TextStyle(fontSize: 13),
              onSubmitted: (value) {
                provider.setSearch(value);
                provider.loadUsers();
              },
              onChanged: (value) => setState(() {}),
            ),
          ),
          const SizedBox(width: 12),

          // Role chips
          _buildChip(
            'All',
            null,
            provider.roleFilter,
            (v) => provider.setRoleFilter(v),
          ),
          const SizedBox(width: 6),
          _buildChip(
            'Admin',
            'admin',
            provider.roleFilter,
            (v) => provider.setRoleFilter(v),
          ),
          const SizedBox(width: 6),
          _buildChip(
            'Customer',
            'customer',
            provider.roleFilter,
            (v) => provider.setRoleFilter(v),
          ),
          const SizedBox(width: 12),

          // Date range
          GestureDetector(
            onTap: () => _selectDateRange(provider),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    provider.startDate != null
                        ? '${DateFormat('dd/MM').format(provider.startDate!)} - ${DateFormat('dd/MM').format(provider.endDate ?? DateTime.now())}'
                        : 'Date',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (provider.startDate != null) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => provider.setDateRange(null, null),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: AppTheme.textSecondary,
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
  ) {
    final isSelected = currentValue == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.sidebarColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.sidebarColor : AppTheme.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateRange(UserProvider provider) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: provider.startDate != null
          ? DateTimeRange(
              start: provider.startDate!,
              end: provider.endDate ?? DateTime.now(),
            )
          : null,
    );
    if (picked != null) {
      provider.setDateRange(picked.start, picked.end);
    }
  }

  Widget _buildUserRow(UserListResult user, UserProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // User (avatar + name)
          Expanded(
            flex: 3,
            child: Row(
              children: [
                UserAvatar(name: user.name ?? 'U', radius: 15),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    user.name ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Email
          Expanded(
            flex: 3,
            child: Text(
              user.email ?? '-',
              style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Mobile
          Expanded(
            flex: 2,
            child: Text(
              user.mobile ?? '-',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),

          // Role
          Expanded(flex: 2, child: RoleBadge(role: user.role ?? 'customer')),

          // Status
          Expanded(
            flex: 2,
            child: StatusBadge(status: user.status ?? 'active'),
          ),

          // Joined
          Expanded(
            flex: 2,
            child: Text(
              user.createdAt != null
                  ? DateFormat('MMM dd').format(DateTime.parse(user.createdAt!))
                  : '-',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),

          // Actions
          SizedBox(
            width: 40,
            child: PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_horiz,
                size: 18,
                color: AppTheme.textSecondary,
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
                  const PopupMenuItem(
                    value: 'blocked',
                    child: Text(
                      'Block User',
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
