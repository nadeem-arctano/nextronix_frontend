import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/app_theme.dart';
import '../../../api/base_url.dart';
import '../../../static_values/static_values.dart';
import '../../../widgets/app_list_table.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/page_header.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/skeletons.dart';

/// HSN Master CRUD screen for Super Admin.
/// Calls `/api/super-admin/masters/hsn` endpoints.
class HsnMasterScreen extends StatefulWidget {
  const HsnMasterScreen({super.key});

  @override
  State<HsnMasterScreen> createState() => _HsnMasterScreenState();
}

class _HsnMasterScreenState extends State<HsnMasterScreen> {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: BaseUrl.baseurl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  List<_HsnMasterItem> _hsnCodes = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (globalAccessToken != null) {
            options.headers['Authorization'] = 'Bearer $globalAccessToken';
          }
          handler.next(options);
        },
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadHsnCodes();
    });
  }

  Future<void> _loadHsnCodes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _dio.get('super-admin/masters/hsn');
      final data = response.data;
      final List<dynamic> rows = data['data'] ?? [];
      setState(() {
        _hsnCodes = rows.map((e) => _HsnMasterItem.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = _extractErrorMessage(e) ?? 'Failed to load HSN codes';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'HSN Codes',
            actions: [
              ShadButton(
                leading: const Icon(LucideIcons.plus, size: 16),
                onPressed: () => _showHsnDialog(context),
                child: const Text('Add HSN Code'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: _isLoading
                ? const TableSkeleton(rows: 6, columns: 5)
                : _hsnCodes.isEmpty
                ? const EmptyWidget(message: 'No HSN codes found')
                : AppListTable<_HsnMasterItem>(
                    columns: const [
                      AppTableColumn(label: 'HSN Code', flex: 3),
                      AppTableColumn(label: 'GST %', flex: 2),
                      AppTableColumn(label: 'Description', flex: 5),
                      AppTableColumn(label: 'Status', flex: 2),
                    ],
                    items: _hsnCodes,
                    currentPage: 1,
                    totalPages: 1,
                    totalItems: _hsnCodes.length,
                    itemLabel: 'HSN codes',
                    onPageChanged: (_) {},
                    rowBuilder: (hsn, _) => _buildHsnRow(hsn),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHsnRow(_HsnMasterItem hsn) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(hsn.hsnCode ?? '-', style: theme.textTheme.small),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${hsn.gstPercent?.toStringAsFixed(1) ?? '0'}%',
              style: theme.textTheme.small,
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              hsn.description ?? '-',
              style: theme.textTheme.muted.copyWith(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(flex: 2, child: StatusBadge(status: hsn.status ?? 'active')),
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
                switch (value) {
                  case 'edit':
                    _showHsnDialog(context, hsn: hsn);
                  case 'delete':
                    _confirmDelete(context, hsn);
                }
              },
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
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.trash2,
                        size: 16,
                        color: AppTheme.dangerColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Delete',
                        style: TextStyle(color: AppTheme.dangerColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHsnDialog(BuildContext context, {_HsnMasterItem? hsn}) {
    final hsnCodeController = TextEditingController(text: hsn?.hsnCode ?? '');
    final gstController = TextEditingController(
      text: hsn?.gstPercent?.toStringAsFixed(1) ?? '',
    );
    final descController = TextEditingController(text: hsn?.description ?? '');
    String status = hsn?.status ?? 'active';
    String? fieldError;

    showShadDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => ShadDialog(
          title: Text(hsn == null ? 'Add HSN Code' : 'Edit HSN Code'),
          description: Text(
            hsn == null
                ? 'Create a new HSN code with GST rate'
                : 'Update HSN code details',
          ),
          actions: [
            ShadButton.outline(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(ctx),
            ),
            ShadButton(
              child: Text(hsn == null ? 'Create' : 'Update'),
              onPressed: () async {
                if (hsnCodeController.text.isEmpty ||
                    gstController.text.isEmpty) {
                  return;
                }

                final gst = double.tryParse(gstController.text);
                if (gst == null) return;

                setDialogState(() => fieldError = null);

                try {
                  final body = {
                    'hsnCode': hsnCodeController.text,
                    'gstPercent': gst,
                    'description': descController.text.isNotEmpty
                        ? descController.text
                        : null,
                    'status': status,
                  };

                  if (hsn == null) {
                    await _dio.post('super-admin/masters/hsn', data: body);
                  } else {
                    await _dio.put(
                      'super-admin/masters/hsn/${hsn.id}',
                      data: body,
                    );
                  }

                  if (ctx.mounted) Navigator.pop(ctx);
                  _loadHsnCodes();
                } on DioException catch (e) {
                  final data = e.response?.data;
                  if (data is Map<String, dynamic> &&
                      data['code'] == 'DUPLICATE_FIELD') {
                    setDialogState(
                      () => fieldError = data['message']?.toString(),
                    );
                  } else {
                    setDialogState(
                      () => fieldError =
                          _extractErrorMessage(e) ?? 'Something went wrong',
                    );
                  }
                }
              },
            ),
          ],
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                if (fieldError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.dangerColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 16,
                          color: AppTheme.dangerColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            fieldError!,
                            style: TextStyle(
                              color: AppTheme.dangerColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                const Text('HSN Code *'),
                const SizedBox(height: 6),
                ShadInput(
                  controller: hsnCodeController,
                  placeholder: const Text('Enter HSN code'),
                ),
                const SizedBox(height: 16),
                const Text('GST Percent *'),
                const SizedBox(height: 6),
                ShadInput(
                  controller: gstController,
                  placeholder: const Text('Enter GST percentage'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Text('Description'),
                const SizedBox(height: 6),
                ShadInput(
                  controller: descController,
                  placeholder: const Text('Enter description'),
                ),
                const SizedBox(height: 16),
                const Text('Status'),
                const SizedBox(height: 6),
                ShadSelect<String>(
                  initialValue: status,
                  options: const [
                    ShadOption(value: 'active', child: Text('Active')),
                    ShadOption(value: 'inactive', child: Text('Inactive')),
                  ],
                  selectedOptionBuilder: (context, value) => Text(value),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => status = v);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, _HsnMasterItem hsn) {
    showShadDialog(
      context: context,
      builder: (ctx) => ShadDialog.alert(
        title: const Text('Delete HSN Code'),
        description: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Are you sure you want to delete "${hsn.hsnCode}"?'),
        ),
        actions: [
          ShadButton.outline(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ShadButton.destructive(
            child: const Text('Delete'),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _deleteHsn(hsn);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteHsn(_HsnMasterItem hsn) async {
    try {
      await _dio.delete('super-admin/masters/hsn/${hsn.id}');
      _loadHsnCodes();
    } on DioException catch (e) {
      if (!mounted) return;
      final data = e.response?.data;
      if (e.response?.statusCode == 409 &&
          data is Map<String, dynamic> &&
          data['code'] == 'MASTER_IN_USE') {
        final count = data['referencingProductCount'] ?? 0;
        _showMasterInUseDialog(context, hsn, count);
      } else {
        _showErrorSnackbar(
          _extractErrorMessage(e) ?? 'Failed to delete HSN code',
        );
      }
    }
  }

  void _showMasterInUseDialog(
    BuildContext context,
    _HsnMasterItem hsn,
    int productCount,
  ) {
    showShadDialog(
      context: context,
      builder: (ctx) => ShadDialog.alert(
        title: const Text('Cannot Delete HSN Code'),
        description: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HSN code "${hsn.hsnCode}" is currently used by '
                '$productCount product${productCount == 1 ? '' : 's'}.',
              ),
              const SizedBox(height: 8),
              const Text(
                'Remove all product references before deleting this HSN code, '
                'or set its status to inactive instead.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          ShadButton.outline(
            child: const Text('OK'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.dangerColor),
    );
  }

  String? _extractErrorMessage(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        return data['message']?.toString();
      }
    }
    return null;
  }
}

/// Internal model for HSN master items (includes status for super admin view).
class _HsnMasterItem {
  final int? id;
  final String? hsnCode;
  final double? gstPercent;
  final String? description;
  final String? status;
  final String? createdAt;

  _HsnMasterItem({
    this.id,
    this.hsnCode,
    this.gstPercent,
    this.description,
    this.status,
    this.createdAt,
  });

  factory _HsnMasterItem.fromJson(Map<String, dynamic> json) => _HsnMasterItem(
    id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
    hsnCode: json['hsnCode']?.toString(),
    gstPercent: json['gstPercent'] is double
        ? json['gstPercent']
        : double.tryParse('${json['gstPercent']}'),
    description: json['description']?.toString(),
    status: json['status']?.toString(),
    createdAt: json['createdAt']?.toString(),
  );
}
