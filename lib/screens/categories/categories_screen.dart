import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/api_constants.dart';
import '../../model/response/response.dart';
import '../../provider/category_provider.dart';
import '../../widgets/app_list_table.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/page_header.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/skeletons.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, _) {
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
                    onPressed: () => _showCategoryDialog(context, provider),
                    child: const Text('Add Category'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: provider.isLoading
                    ? const TableSkeleton(rows: 6, columns: 4)
                    : provider.categories.isEmpty
                    ? const EmptyWidget(message: 'No categories found')
                    : AppListTable<CategoryResult>(
                        columns: const [
                          AppTableColumn(label: 'Category', flex: 4),
                          AppTableColumn(label: 'Products', flex: 2),
                          AppTableColumn(label: 'Status', flex: 2),
                        ],
                        items: provider.categories,
                        currentPage: 1,
                        totalPages: 1,
                        totalItems: provider.categories.length,
                        itemLabel: 'categories',
                        onPageChanged: (_) {},
                        rowBuilder: (category, _) =>
                            _buildCategoryRow(category, provider),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryRow(CategoryResult category, CategoryProvider provider) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 36,
                    height: 36,
                    color: theme.colorScheme.muted,
                    child: category.image != null
                        ? Image.network(
                            ApiConstants.getImageUrl(category.image),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(LucideIcons.layers, size: 16),
                          )
                        : Icon(
                            LucideIcons.layers,
                            size: 16,
                            color: theme.colorScheme.mutedForeground,
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name ?? '',
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
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${category.productCount ?? 0}',
              style: theme.textTheme.small,
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
                    _showCategoryDialog(context, provider, category: category);
                  case 'delete':
                    _confirmDelete(context, provider, category);
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
    BuildContext context,
    CategoryProvider provider, {
    CategoryResult? category,
  }) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final descController = TextEditingController(
      text: category?.description ?? '',
    );
    String status = category?.status ?? 'active';
    PlatformFile? imageFile;

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

                MultipartFile? imageMultipart;
                if (imageFile != null && imageFile!.bytes != null) {
                  imageMultipart = MultipartFile.fromBytes(
                    imageFile!.bytes!,
                    filename: imageFile!.name,
                  );
                }

                dynamic result;
                if (category == null) {
                  result = await provider.createCategory(
                    name: nameController.text,
                    description: descController.text,
                    status: status,
                    image: imageMultipart,
                  );
                } else {
                  result = await provider.updateCategory(
                    id: category.id!,
                    name: nameController.text,
                    description: descController.text,
                    status: status,
                    image: imageMultipart,
                  );
                }

                if (result == null && ctx.mounted) Navigator.pop(ctx);
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
                ShadButton.outline(
                  leading: const Icon(LucideIcons.image, size: 16),
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.image,
                    );
                    if (result != null) {
                      setDialogState(() => imageFile = result.files.first);
                    }
                  },
                  child: Text(
                    imageFile != null ? imageFile!.name : 'Select Image',
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    CategoryProvider provider,
    CategoryResult category,
  ) {
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
            onPressed: () {
              provider.deleteCategory(id: category.id!);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
