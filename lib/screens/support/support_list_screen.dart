import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../model/response/response.dart';
import '../../provider/support_provider.dart';
import '../../widgets/app_list_table.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/page_header.dart';
import '../../widgets/status_badge.dart';
import 'widgets/priority_badge.dart';

class SupportListScreen extends StatefulWidget {
  const SupportListScreen({super.key});

  @override
  State<SupportListScreen> createState() => _SupportListScreenState();
}

class _SupportListScreenState extends State<SupportListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<SupportProvider>();
      p.loadStats();
      p.loadTickets();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<SupportProvider>().setSearch(
        value.trim().isEmpty ? null : value.trim(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SupportProvider>(
      builder: (context, p, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Support Tickets',
                subtitle: 'Manage customer support requests',
                actions: [
                  ShadButton.outline(
                    size: ShadButtonSize.sm,
                    leading: const Icon(LucideIcons.mail, size: 14),
                    onPressed: () => context.go('/admin/contact-messages'),
                    child: const Text('Contact Messages'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (p.stats != null) _buildStats(p.stats!),
              const SizedBox(height: 16),
              _buildFilters(p),
              const SizedBox(height: 16),
              Expanded(
                child: p.isLoading && p.tickets.isEmpty
                    ? const LoadingWidget(message: 'Loading tickets...')
                    : p.tickets.isEmpty
                    ? const EmptyWidget(message: 'No tickets found')
                    : AppListTable<Ticket>(
                        columns: const [
                          AppTableColumn(label: 'Ticket', flex: 2),
                          AppTableColumn(label: 'Subject', flex: 4),
                          AppTableColumn(label: 'Customer', flex: 3),
                          AppTableColumn(label: 'Priority', flex: 1),
                          AppTableColumn(label: 'Status', flex: 2),
                          AppTableColumn(label: 'Created', flex: 2),
                        ],
                        items: p.tickets,
                        currentPage: p.currentPage,
                        totalPages: p.pagination?.totalPages ?? 1,
                        totalItems: p.pagination?.totalItems ?? 0,
                        itemLabel: 'tickets',
                        onPageChanged: (page) => p.loadTickets(page: page),
                        rowBuilder: (t, _) => _buildRow(t),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStats(TicketStats stats) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            'Total',
            stats.totalTickets.toString(),
            const Color(0xFF4F46E5),
            LucideIcons.inbox,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            'Open',
            stats.openTickets.toString(),
            const Color(0xFF059669),
            LucideIcons.circleDot,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            'Pending',
            stats.pendingTickets.toString(),
            const Color(0xFFF59E0B),
            LucideIcons.clock,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            'Resolved',
            stats.resolvedTickets.toString(),
            const Color(0xFF10B981),
            LucideIcons.circleCheck,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            'Urgent',
            stats.urgentTickets.toString(),
            const Color(0xFFDC2626),
            LucideIcons.triangleAlert,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    final theme = ShadTheme.of(context);
    return ShadCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: theme.textTheme.h4.copyWith(fontSize: 16)),
                Text(
                  label,
                  style: theme.textTheme.muted.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(SupportProvider p) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
            width: 260,
            child: ShadInput(
              controller: _searchController,
              placeholder: const Text('Search tickets...'),
              style: const TextStyle(fontSize: 12),
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(width: 12),
          _chip('All', null, p.statusFilter, p.setStatusFilter),
          const SizedBox(width: 6),
          _chip('Open', 'open', p.statusFilter, p.setStatusFilter),
          const SizedBox(width: 6),
          _chip('Pending', 'pending', p.statusFilter, p.setStatusFilter),
          const SizedBox(width: 6),
          _chip('Resolved', 'resolved', p.statusFilter, p.setStatusFilter),
          const SizedBox(width: 6),
          _chip('Closed', 'closed', p.statusFilter, p.setStatusFilter),
          const SizedBox(width: 24),
          _chip('All priority', null, p.priorityFilter, p.setPriorityFilter),
          const SizedBox(width: 6),
          _chip('Urgent', 'urgent', p.priorityFilter, p.setPriorityFilter),
          const SizedBox(width: 6),
          _chip('High', 'high', p.priorityFilter, p.setPriorityFilter),
        ],
      ),
    );
  }

  Widget _chip(
    String label,
    String? value,
    String? current,
    ValueChanged<String?> onTap,
  ) {
    final theme = ShadTheme.of(context);
    final selected = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected
                ? theme.colorScheme.primaryForeground
                : theme.colorScheme.mutedForeground,
          ),
        ),
      ),
    );
  }

  Widget _buildRow(Ticket t) {
    final theme = ShadTheme.of(context);
    return InkWell(
      onTap: () => context.go('/admin/support/${t.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                t.ticketNumber,
                style: theme.textTheme.small.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 4,
              child: Text(
                t.subject,
                style: theme.textTheme.small,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.customerName ?? '-',
                    style: theme.textTheme.small.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    t.customerEmail ?? '',
                    style: theme.textTheme.muted.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Expanded(flex: 1, child: PriorityBadge(priority: t.priority)),
            Expanded(flex: 2, child: StatusBadge(status: t.status)),
            Expanded(
              flex: 2,
              child: Text(
                t.createdAt != null
                    ? DateFormat(
                        'MMM dd, yyyy',
                      ).format(DateTime.parse(t.createdAt!))
                    : '-',
                style: theme.textTheme.muted.copyWith(fontSize: 12),
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}
