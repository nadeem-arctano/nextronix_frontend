import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../model/response/response.dart';
import '../../provider/audit_provider.dart';
import '../../widgets/advanced_data_table.dart';
import '../../widgets/debounced_search_input.dart';
import '../../widgets/filter_dropdown.dart';
import '../../widgets/page_header.dart';
import '../../widgets/skeletons.dart';

/// Brand-scoped audit log view: filter by module/action/search/date range.
/// Click a row to open the full detail (incl. old + new payload diff).
class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  /// Locally-managed hidden-columns set so the column-toggle button can
  /// live inside the filter row (alongside search and dropdowns) instead
  /// of inside the table's own toolbar — matches the admins screen.
  Set<String> _hiddenColumns = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final p = context.read<AuditProvider>();
      p.loadFilters();
      p.load(page: 1);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuditProvider>(
      builder: (context, p, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'Audit Logs',
                subtitle: 'Activity trail across this brand',
              ),
              const SizedBox(height: 20),
              _buildFilters(p),
              const SizedBox(height: 16),
              if (p.isLoading && p.items.isEmpty)
                const Expanded(child: TableSkeleton(rows: 8, columns: 6))
              else
                Expanded(child: _buildTable(p)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilters(AuditProvider p) {
    final theme = ShadTheme.of(context);
    final hasFilters =
        (p.searchTerm != null && p.searchTerm!.isNotEmpty) ||
        p.moduleFilter != null ||
        p.actionFilter != null;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Auto-debounced search using the shared widget.
          DebouncedSearchInput(
            controller: _searchCtrl,
            placeholder: 'Search by module / action / user',
            width: 240,
            initialValue: p.searchTerm,
            onSearch: p.setSearch,
          ),
          const SizedBox(width: 12),

          // Module filter — list comes from the provider's discovered values.
          FilterDropdown<String>(
            placeholder: 'Module',
            width: 160,
            value: p.moduleFilter ?? '',
            options: [
              const FilterOption(value: '', label: 'All Modules'),
              ...p.knownModules.map((m) => FilterOption(value: m, label: m)),
            ],
            onChanged: (v) => p.setModule(v == null || v.isEmpty ? null : v),
          ),
          const SizedBox(width: 8),

          // Action filter
          FilterDropdown<String>(
            placeholder: 'Action',
            width: 160,
            value: p.actionFilter ?? '',
            options: [
              const FilterOption(value: '', label: 'All Actions'),
              ...p.knownActions.map((a) => FilterOption(value: a, label: a)),
            ],
            onChanged: (v) => p.setAction(v == null || v.isEmpty ? null : v),
          ),

          if (hasFilters) ...[
            const SizedBox(width: 12),
            ShadButton.ghost(
              size: ShadButtonSize.sm,
              onPressed: () {
                _searchCtrl.clear();
                p.clearFilters();
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
          // Column-visibility toggle, same icon as the table's built-in
          // toolbar but rendered here so it sits alongside the filters.
          ColumnVisibilityMenu<AuditLog>(
            columns: _columnsFor(),
            hiddenColumns: _hiddenColumns,
            onChanged: (next) => setState(() => _hiddenColumns = next),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(AuditProvider p) {
    return AdvancedDataTable<AuditLog>(
      columns: _columnsFor(),
      hiddenColumns: _hiddenColumns,
      onHiddenColumnsChanged: (next) => setState(() => _hiddenColumns = next),
      showColumnToggle: false,
      items: p.items,
      idOf: (a) => a.id,
      currentPage: p.pagination?.currentPage ?? p.currentPage,
      totalPages: p.pagination?.totalPages ?? 1,
      totalItems: p.pagination?.totalItems ?? 0,
      itemLabel: 'logs',
      onPageChanged: (page) => p.load(page: page),
    );
  }

  /// Column definitions shared between [_buildTable] and the standalone
  /// [ColumnVisibilityMenu] in the filter row, so toggling a column in
  /// either place stays in sync.
  List<AdvancedTableColumn<AuditLog>> _columnsFor() {
    return [
      AdvancedTableColumn<AuditLog>(
        key: 'when',
        label: 'When',
        flex: 2,
        cellBuilder: (a, _) => Text(
          a.createdAt != null
              ? DateFormat(
                  'MMM dd, HH:mm',
                ).format(DateTime.parse(a.createdAt!).toLocal())
              : '-',
          style: ShadTheme.of(context).textTheme.muted.copyWith(fontSize: 12),
        ),
      ),
      AdvancedTableColumn<AuditLog>(
        key: 'user',
        label: 'User',
        flex: 3,
        cellBuilder: (a, _) {
          final theme = ShadTheme.of(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(a.userName ?? '-', style: theme.textTheme.small),
              if (a.userEmail != null)
                Text(
                  a.userEmail!,
                  style: theme.textTheme.muted.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          );
        },
      ),
      AdvancedTableColumn<AuditLog>(
        key: 'module',
        label: 'Module',
        flex: 2,
        cellBuilder: (a, _) => _Tag(text: a.module),
      ),
      AdvancedTableColumn<AuditLog>(
        key: 'action',
        label: 'Action',
        flex: 2,
        cellBuilder: (a, _) => _Tag(text: a.action, color: AppTheme.brand),
      ),
      AdvancedTableColumn<AuditLog>(
        key: 'entity',
        label: 'Entity',
        flex: 3,
        cellBuilder: (a, _) {
          final theme = ShadTheme.of(context);
          final type = a.entityType ?? '-';
          final id = a.entityId != null ? '#${a.entityId}' : '';
          return Text(
            '$type $id'.trim(),
            style: theme.textTheme.muted.copyWith(fontSize: 12),
          );
        },
      ),
      AdvancedTableColumn<AuditLog>(
        key: 'actions',
        label: '',
        flex: 1,
        align: TextAlign.right,
        hideable: false,
        cellBuilder: (a, _) => IconButton(
          icon: const Icon(LucideIcons.eye, size: 14),
          tooltip: 'View',
          onPressed: () => _openDetail(a),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        ),
      ),
    ];
  }

  Future<void> _openDetail(AuditLog a) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _AuditDetailDialog(log: a),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color? color;
  const _Tag({required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final c = color ?? theme.colorScheme.foreground;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _AuditDetailDialog extends StatelessWidget {
  final AuditLog log;
  const _AuditDetailDialog({required this.log});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _Tag(text: log.module),
                  const SizedBox(width: 6),
                  _Tag(text: log.action, color: AppTheme.brand),
                  const Spacer(),
                  Text(
                    log.createdAt != null
                        ? DateFormat(
                            'MMM dd, yyyy HH:mm:ss',
                          ).format(DateTime.parse(log.createdAt!).toLocal())
                        : '-',
                    style: theme.textTheme.muted,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Audit log #${log.id}', style: theme.textTheme.h3),
              const SizedBox(height: 4),
              Text(
                'By ${log.userName ?? "system"} (${log.userRole ?? "-"}) — ${log.userEmail ?? "-"}',
                style: theme.textTheme.muted,
              ),
              if (log.entityType != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Entity: ${log.entityType} #${log.entityId ?? "-"}',
                  style: theme.textTheme.muted,
                ),
              ],
              if (log.ipAddress != null) ...[
                const SizedBox(height: 4),
                Text(
                  'IP: ${log.ipAddress}',
                  style: theme.textTheme.muted.copyWith(fontSize: 11),
                ),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DiffBlock(label: 'Before', data: log.oldData),
                      const SizedBox(height: 12),
                      _DiffBlock(label: 'After', data: log.newData),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ShadButton.outline(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiffBlock extends StatelessWidget {
  final String label;
  final dynamic data;
  const _DiffBlock({required this.label, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    if (data == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.muted.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('$label: (none)', style: theme.textTheme.muted),
      );
    }
    final pretty = data is Map || data is List
        ? const JsonPrettyPrinter().pretty(data)
        : data.toString();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.small.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          SelectableText(
            pretty,
            style: const TextStyle(
              fontFamily: 'Courier',
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class JsonPrettyPrinter {
  const JsonPrettyPrinter();
  String pretty(dynamic value) {
    try {
      // Manual indent so we don't pull dart:convert again here.
      return _stringify(value, 0);
    } catch (_) {
      return value.toString();
    }
  }

  String _stringify(dynamic v, int indent) {
    final pad = '  ' * indent;
    final innerPad = '  ' * (indent + 1);
    if (v is Map) {
      if (v.isEmpty) return '{}';
      final entries = v.entries
          .map((e) => '$innerPad"${e.key}": ${_stringify(e.value, indent + 1)}')
          .join(',\n');
      return '{\n$entries\n$pad}';
    }
    if (v is List) {
      if (v.isEmpty) return '[]';
      final items = v
          .map((e) => '$innerPad${_stringify(e, indent + 1)}')
          .join(',\n');
      return '[\n$items\n$pad]';
    }
    if (v is String) return '"$v"';
    if (v == null) return 'null';
    return v.toString();
  }
}
