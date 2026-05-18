import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/navigation_utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../model/response/response.dart';
import '../../provider/support_provider.dart';
import '../../widgets/app_list_table.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/page_header.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/skeletons.dart';

class ContactMessagesScreen extends StatefulWidget {
  const ContactMessagesScreen({super.key});

  @override
  State<ContactMessagesScreen> createState() => _ContactMessagesScreenState();
}

class _ContactMessagesScreenState extends State<ContactMessagesScreen> {
  /// Locally-managed hidden-columns set for the column-toggle button.
  Set<String> _hiddenColumns = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SupportProvider>().loadContactMessages();
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
                title: 'Contact Messages',
                subtitle: 'Messages submitted via the contact form',
                onBack: () => smartBack(context, '/admin/support'),
                actions: [
                  AppListTableColumnMenu(
                    columns: const [
                      AppTableColumn(key: 'name', label: 'Name'),
                      AppTableColumn(key: 'email', label: 'Email'),
                      AppTableColumn(key: 'subject', label: 'Subject'),
                      AppTableColumn(key: 'message', label: 'Message'),
                      AppTableColumn(key: 'status', label: 'Status'),
                      AppTableColumn(key: 'date', label: 'Date'),
                    ],
                    hiddenColumns: _hiddenColumns,
                    onChanged: (next) => setState(() => _hiddenColumns = next),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: p.isLoadingContact && p.contactMessages.isEmpty
                    ? const TableSkeleton(rows: 8, columns: 4)
                    : p.contactMessages.isEmpty
                    ? const EmptyWidget(message: 'No contact messages')
                    : AppListTable<ContactMessage>(
                        columns: const [
                          AppTableColumn(key: 'name', label: 'Name', flex: 2),
                          AppTableColumn(key: 'email', label: 'Email', flex: 3),
                          AppTableColumn(
                            key: 'subject',
                            label: 'Subject',
                            flex: 3,
                          ),
                          AppTableColumn(
                            key: 'message',
                            label: 'Message',
                            flex: 4,
                          ),
                          AppTableColumn(
                            key: 'status',
                            label: 'Status',
                            flex: 1,
                          ),
                          AppTableColumn(key: 'date', label: 'Date', flex: 2),
                        ],
                        hiddenColumns: _hiddenColumns,
                        items: p.contactMessages,
                        currentPage: p.contactPagination?.currentPage ?? 1,
                        totalPages: p.contactPagination?.totalPages ?? 1,
                        totalItems: p.contactPagination?.totalItems ?? 0,
                        itemLabel: 'messages',
                        onPageChanged: (page) =>
                            p.loadContactMessages(page: page),
                        rowBuilder: (m, _) => _buildRow(m, p),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(ContactMessage m, SupportProvider p) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          if (!AppListTable.isColumnHidden(context, 'name'))
            Expanded(
              flex: 2,
              child: Text(
                m.name,
                style: theme.textTheme.small.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (!AppListTable.isColumnHidden(context, 'email'))
            Expanded(
              flex: 3,
              child: Text(
                m.email,
                style: theme.textTheme.muted.copyWith(fontSize: 12),
              ),
            ),
          if (!AppListTable.isColumnHidden(context, 'subject'))
            Expanded(
              flex: 3,
              child: Text(
                m.subject ?? '-',
                style: theme.textTheme.small,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (!AppListTable.isColumnHidden(context, 'message'))
            Expanded(
              flex: 4,
              child: Text(
                m.message,
                style: theme.textTheme.muted.copyWith(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (!AppListTable.isColumnHidden(context, 'status'))
            Expanded(flex: 1, child: StatusBadge(status: m.status)),
          if (!AppListTable.isColumnHidden(context, 'date'))
            Expanded(
              flex: 2,
              child: Text(
                m.createdAt != null
                    ? DateFormat('MMM dd').format(DateTime.parse(m.createdAt!))
                    : '-',
                style: theme.textTheme.muted.copyWith(fontSize: 12),
              ),
            ),
          SizedBox(
            width: 40,
            child: PopupMenuButton<String>(
              icon: Icon(
                LucideIcons.ellipsis,
                size: 16,
                color: theme.colorScheme.mutedForeground,
              ),
              padding: EdgeInsets.zero,
              onSelected: (value) => p.markContactStatus(m.id, value),
              itemBuilder: (_) => [
                if (m.status != 'read')
                  const PopupMenuItem(
                    value: 'read',
                    child: Text('Mark as Read'),
                  ),
                if (m.status != 'replied')
                  const PopupMenuItem(
                    value: 'replied',
                    child: Text('Mark as Replied'),
                  ),
                if (m.status != 'archived')
                  const PopupMenuItem(
                    value: 'archived',
                    child: Text('Archive'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
