import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/api_constants.dart';
import '../../model/response/response.dart';
import '../../provider/category_provider.dart';
import '../../widgets/app_list_table.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/page_header.dart';
import '../../widgets/status_badge.dart';

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
                  ElevatedButton.icon(
                    onPressed: () => _showCategoryDialog(context, provider),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Category'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: provider.isLoading
                    ? const LoadingWidget()
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Category (image + name + description)
          Expanded(
            flex: 4,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 36,
                    height: 36,
                    color: AppTheme.dividerColor,
                    child: category.image != null
                        ? Image.network(
                            ApiConstants.getImageUrl(category.image),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const Icon(Icons.category, size: 16),
                          )
                        : const Icon(
                            Icons.category,
                            size: 16,
                            color: AppTheme.textMuted,
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
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (category.description != null &&
                          category.description!.isNotEmpty)
                        Text(
                          category.description!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Products count
          Expanded(
            flex: 2,
            child: Text(
              '${category.productCount ?? 0}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),

          // Status
          Expanded(
            flex: 2,
            child: StatusBadge(status: category.status ?? 'active'),
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
                switch (value) {
                  case 'edit':
                    _showCategoryDialog(context, provider, category: category);
                  case 'delete':
                    _confirmDelete(context, provider, category);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 16),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: AppTheme.dangerColor,
                      ),
                      SizedBox(width: 8),
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

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(category == null ? 'Add Category' : 'Edit Category'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name *',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(
                      value: 'inactive',
                      child: Text('Inactive'),
                    ),
                  ],
                  onChanged: (v) => setDialogState(() => status = v!),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.image,
                    );
                    if (result != null) {
                      setDialogState(() => imageFile = result.files.first);
                    }
                  },
                  icon: const Icon(Icons.image_outlined, size: 16),
                  label: Text(
                    imageFile != null ? imageFile!.name : 'Select Image',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
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
              child: Text(category == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    CategoryProvider provider,
    CategoryResult category,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerColor,
            ),
            onPressed: () {
              provider.deleteCategory(id: category.id!);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
