import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../provider/user_provider.dart';
import '../../widgets/data_table_pagination.dart';
import '../../widgets/filter_bar.dart';
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
              const PageHeader(
                title: 'Users',
                subtitle: 'Manage all registered users',
              ),
              const SizedBox(height: 24),

              // Filters
              _buildFilters(provider),
              const SizedBox(height: 16),

              // Users Table
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
                    : _buildUsersTable(provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilters(UserProvider provider) {
    return FilterBar(
      children: [
        // Search
        SizedBox(
          width: 250,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search name, email, mobile...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        provider.setSearch('');
                        provider.loadUsers();
                      },
                    )
                  : null,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            onSubmitted: (value) {
              provider.setSearch(value);
              provider.loadUsers();
            },
            onChanged: (value) => setState(() {}),
          ),
        ),

        // Role filter
        SizedBox(
          width: 140,
          child: DropdownButtonFormField<String>(
            value: provider.roleFilter,
            decoration: const InputDecoration(
              labelText: 'Role',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('All')),
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
              DropdownMenuItem(value: 'customer', child: Text('Customer')),
              DropdownMenuItem(value: 'manager', child: Text('Manager')),
            ],
            onChanged: (value) => provider.setRoleFilter(value),
          ),
        ),

        // Status filter
        SizedBox(
          width: 140,
          child: DropdownButtonFormField<String>(
            value: provider.statusFilter,
            decoration: const InputDecoration(
              labelText: 'Status',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('All')),
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
              DropdownMenuItem(value: 'blocked', child: Text('Blocked')),
            ],
            onChanged: (value) => provider.setStatusFilter(value),
          ),
        ),

        // Date range
        SizedBox(
          width: 220,
          child: InkWell(
            onTap: () => _selectDateRange(provider),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Created At',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                suffixIcon: provider.startDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => provider.setDateRange(null, null),
                      )
                    : const Icon(Icons.calendar_today, size: 18),
              ),
              child: Text(
                provider.startDate != null
                    ? '${DateFormat('dd/MM/yy').format(provider.startDate!)} - ${DateFormat('dd/MM/yy').format(provider.endDate ?? DateTime.now())}'
                    : 'Select date range',
                style: TextStyle(
                  fontSize: 13,
                  color: provider.startDate != null
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        ),

        // Clear filters
        if (provider.search.isNotEmpty ||
            provider.roleFilter != null ||
            provider.statusFilter != null ||
            provider.startDate != null)
          TextButton.icon(
            onPressed: () {
              _searchController.clear();
              provider.clearFilters();
            },
            icon: const Icon(Icons.clear_all, size: 18),
            label: const Text('Clear'),
          ),
      ],
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

  Widget _buildUsersTable(UserProvider provider) {
    return Column(
      children: [
        Expanded(
          child: Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 24,
                  headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                  columns: const [
                    DataColumn(label: Text('USER')),
                    DataColumn(label: Text('EMAIL')),
                    DataColumn(label: Text('MOBILE')),
                    DataColumn(label: Text('ROLE')),
                    DataColumn(label: Text('STATUS')),
                    DataColumn(label: Text('JOINED')),
                    DataColumn(label: Text('ACTIONS')),
                  ],
                  rows: provider.users.map((user) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              UserAvatar(name: user.name ?? 'U', radius: 16),
                              const SizedBox(width: 10),
                              Text(
                                user.name ?? 'N/A',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(Text(user.email ?? '')),
                        DataCell(Text(user.mobile ?? '-')),
                        DataCell(RoleBadge(role: user.role ?? 'customer')),
                        DataCell(StatusBadge(status: user.status ?? 'active')),
                        DataCell(
                          Text(
                            user.createdAt != null
                                ? DateFormat(
                                    'dd MMM yyyy',
                                  ).format(DateTime.parse(user.createdAt!))
                                : '-',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        DataCell(
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 18),
                            onSelected: (value) {
                              if (user.id != null) {
                                provider.updateUserStatus(
                                  id: user.id!,
                                  status: value,
                                );
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
                                  child: Text('Block User'),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),

        // Pagination
        if (provider.pagination != null)
          DataTablePagination(
            currentPage: provider.currentPage,
            totalPages: provider.pagination!.totalPages ?? 1,
            totalItems: provider.pagination!.totalItems ?? 0,
            showingCount: provider.users.length,
            itemLabel: 'users',
            onPageChanged: (page) => provider.loadUsers(page: page),
          ),
      ],
    );
  }
}
