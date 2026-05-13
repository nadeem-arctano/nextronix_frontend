import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/category_provider.dart';
import '../../models/category_model.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/loading_widget.dart';

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
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showCategoryDialog(context, provider),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Category'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Card(
                child: provider.isLoading
                    ? const SizedBox(height: 300, child: LoadingWidget())
                    : provider.categories.isEmpty
                    ? const SizedBox(
                        height: 300,
                        child: EmptyWidget(message: 'No categories found'),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 30,
                          columns: const [
                            DataColumn(label: Text('IMAGE')),
                            DataColumn(label: Text('NAME')),
                            DataColumn(label: Text('PRODUCTS')),
                            DataColumn(label: Text('STATUS')),
                            DataColumn(label: Text('ACTIONS')),
                          ],
                          rows: provider.categories.map((category) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      color: AppTheme.bgColor,
                                      child: category.image != null
                                          ? Image.network(
                                              ApiConstants.getImageUrl(
                                                category.image,
                                              ),
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                    Icons.category,
                                                    size: 20,
                                                  ),
                                            )
                                          : const Icon(
                                              Icons.category,
                                              size: 20,
                                              color: AppTheme.textSecondary,
                                            ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        category.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (category.description != null)
                                        Text(
                                          category.description!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                                DataCell(Text('${category.productCount}')),
                                DataCell(StatusBadge(status: category.status)),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 18,
                                        ),
                                        onPressed: () => _showCategoryDialog(
                                          context,
                                          provider,
                                          category: category,
                                        ),
                                        tooltip: 'Edit',
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          size: 18,
                                          color: AppTheme.dangerColor,
                                        ),
                                        onPressed: () => _confirmDelete(
                                          context,
                                          provider,
                                          category,
                                        ),
                                        tooltip: 'Delete',
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
            ],
          ),
        );
      },
    );
  }

  void _showCategoryDialog(
    BuildContext context,
    CategoryProvider provider, {
    CategoryModel? category,
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
                  value: status,
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
                  icon: const Icon(Icons.image_outlined),
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

                final formData = FormData.fromMap({
                  'name': nameController.text,
                  'description': descController.text,
                  'status': status,
                });

                if (imageFile != null && imageFile!.bytes != null) {
                  formData.files.add(
                    MapEntry(
                      'image',
                      MultipartFile.fromBytes(
                        imageFile!.bytes!,
                        filename: imageFile!.name,
                      ),
                    ),
                  );
                }

                bool success;
                if (category == null) {
                  success = await provider.createCategory(formData);
                } else {
                  success = await provider.updateCategory(
                    category.id,
                    formData,
                  );
                }

                if (success && ctx.mounted) Navigator.pop(ctx);
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
    CategoryModel category,
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
              provider.deleteCategory(category.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
