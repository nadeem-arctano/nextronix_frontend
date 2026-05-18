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

/// Categories Master CRUD screen for Super Admin.
/// Calls `/api/super-admin/masters/categories` endpoints.
class CategoriesMasterScreen extends StatefulWidget {
  const CategoriesMasterScreen({super.key});

  @override
  State<CategoriesMasterScreen> createState() => _CategoriesMasterScreenState();
}

class _CategoriesMasterScreenState extends State<CategoriesMasterScreen> {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: BaseUrl.baseurl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  List<_CategoryMasterItem> _categories = [];
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
      _loadCategories();
    });
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _dio.get('super-admin/masters/categories');
      final data = response.data;
      final List<dynamic> rows = data['data'] ?? [];
      setState(() {
        _categories = rows.map((e) => _CategoryMasterItem.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = _extractErrorMessage(e) ?? 'Failed to load categories';
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
            title: 'Categories',
            actions: [
              ShadButton(
                leading: const Icon(LucideIcons.plus, size: 16),
                onPressed: () => _showCategoryDialog(context),
                child: const Text('Add Category'),
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
                ? const TableSkeleton(rows: 6, columns: 4)
                : _categories.isEmpty
                ? const EmptyWidget(message: 'No categories found')
                : AppListTable<_CategoryMasterItem>(
                    columns: const [
                      AppTableColumn(label: 'Category', flex: 4),
                      AppTableColumn(label: 'Slug', flex: 3),
                      AppTableColumn(label: 'Status', flex: 2),
                    ],
                    items: _categories,
                    currentPage: 1,
                    totalPages: 1,
                    totalItems: _categories.length,
                    itemLabel: 'categories',
                    onPageChanged: (_) {},
                    rowBuilder: (category, _) => _buildCategoryRow(category),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(_CategoryMasterItem category) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name ?? '-',
                  style: theme.textTheme.small,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (category.description != null &&
                    category.description!.isNotEmpty)
                  Text(
                    category.description!,
                    style: theme.textTheme.muted.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              category.slug ?? '-',
              style: theme.textTheme.muted.copyWith(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: StatusBadge(status: category.status ?? 'active'),
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
                switch (value) {
                  case 'edit':
                    _showCategoryDialog(context, category: category);
                  case 'delete':
                    _confirmDelete(context, category);
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

  void _showCategoryDialog(
    BuildContext context, {
    _CategoryMasterItem? category,
  }) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final descController = TextEditingController(
      text: category?.description ?? '',
    );
    String status = category?.status ?? 'active';
    String? fieldError;

    showShadDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => ShadDialog(
          title: Text(category == null ? 'Add Category' : 'Edit Category'),
          description: Text(
            category == null
                ? 'Create a new product category'
                : 'Update category details',
          ),
          actions: [
            ShadButton.outline(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(ctx),
            ),
            ShadButton(
              child: Text(category == null ? 'Create' : 'Update'),
              onPressed: () async {
                if (nameController.text.isEmpty) return;

                setDialogState(() => fieldError = null);

                try {
                  final body = {
                    'name': nameController.text,
                    'description': descController.text.isNotEmpty
                        ? descController.text
                        : null,
                    'status': status,
                  };

                  if (category == null) {
                    await _dio.post(
                      'super-admin/masters/categories',
                      data: body,
                    );
                  } else {
                    await _dio.put(
                      'super-admin/masters/categories/${category.id}',
                      data: body,
                    );
                  }

                  if (ctx.mounted) Navigator.pop(ctx);
                  _loadCategories();
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
                      color: AppTheme.dangerColor.withValues(alpha: 0.1),
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
                const Text('Category Name *'),
                const SizedBox(height: 6),
                ShadInput(
                  controller: nameController,
                  placeholder: const Text('Enter category name'),
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

  void _confirmDelete(BuildContext context, _CategoryMasterItem category) {
    showShadDialog(
      context: context,
      builder: (ctx) => ShadDialog.alert(
        title: const Text('Delete Category'),
        description: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Are you sure you want to delete "${category.name}"?'),
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
              await _deleteCategory(category);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(_CategoryMasterItem category) async {
    try {
      await _dio.delete('super-admin/masters/categories/${category.id}');
      _loadCategories();
    } on DioException catch (e) {
      if (!mounted) return;
      final data = e.response?.data;
      if (e.response?.statusCode == 409 &&
          data is Map<String, dynamic> &&
          data['code'] == 'MASTER_IN_USE') {
        final count = data['referencingProductCount'] ?? 0;
        _showMasterInUseDialog(context, category, count);
      } else {
        _showErrorSnackbar(
          _extractErrorMessage(e) ?? 'Failed to delete category',
        );
      }
    }
  }

  void _showMasterInUseDialog(
    BuildContext context,
    _CategoryMasterItem category,
    int productCount,
  ) {
    showShadDialog(
      context: context,
      builder: (ctx) => ShadDialog.alert(
        title: const Text('Cannot Delete Category'),
        description: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Category "${category.name}" is currently used by '
                '$productCount product${productCount == 1 ? '' : 's'}.',
              ),
              const SizedBox(height: 8),
              const Text(
                'Remove all product references before deleting this category, '
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

/// Internal model for category master items (includes inactive for super admin).
class _CategoryMasterItem {
  final int? id;
  final String? name;
  final String? slug;
  final String? image;
  final String? description;
  final String? status;
  final String? createdAt;

  _CategoryMasterItem({
    this.id,
    this.name,
    this.slug,
    this.image,
    this.description,
    this.status,
    this.createdAt,
  });

  factory _CategoryMasterItem.fromJson(Map<String, dynamic> json) =>
      _CategoryMasterItem(
        id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
        name: json['name']?.toString(),
        slug: json['slug']?.toString(),
        image: json['image']?.toString(),
        description: json['description']?.toString(),
        status: json['status']?.toString(),
        createdAt: json['createdAt']?.toString(),
      );
}
