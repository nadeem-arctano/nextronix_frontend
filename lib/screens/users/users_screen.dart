import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
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
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserProvider>().loadUsers();
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
    final theme = ShadTheme.of(context);
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

          // Role chips
          _buildChip(
            'All',
            null,
            provider.roleFilter,
            (v) => provider.setRoleFilter(v),
            theme,
          ),
          const SizedBox(width: 6),
          _buildChip(
            'Admin',
            'admin',
            provider.roleFilter,
            (v) => provider.setRoleFilter(v),
            theme,
          ),
          const SizedBox(width: 6),
          _buildChip(
            'Customer',
            'customer',
            provider.roleFilter,
            (v) => provider.setRoleFilter(v),
            theme,
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
          Expanded(flex: 2, child: RoleBadge(role: user.role ?? 'customer')),
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
