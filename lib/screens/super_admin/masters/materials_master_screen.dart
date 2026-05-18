import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../model/response/response.dart';
import '../../../provider/material_master_provider.dart';
import '../../../widgets/app_list_table.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/page_header.dart';
import '../../../widgets/skeletons.dart';
import '../../../widgets/status_badge.dart';

class MaterialsMasterScreen extends StatefulWidget {
  const MaterialsMasterScreen({super.key});

  @override
  State<MaterialsMasterScreen> createState() => _MaterialsMasterScreenState();
}

class _MaterialsMasterScreenState extends State<MaterialsMasterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MaterialMasterProvider>().loadMaterials();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MaterialMasterProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Materials',
                actions: [
                  ShadButton(
                    leading: const Icon(LucideIcons.plus, size: 16),
                    onPressed: () => _showMaterialDialog(context, provider),
                    child: const Text('Add Material'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: provider.isLoading
                    ? const TableSkeleton(rows: 6, columns: 3)
                    : provider.materials.isEmpty
                    ? const EmptyWidget(message: 'No materials found')
                    : AppListTable<MaterialMasterItem>(
                        columns: const [
                          AppTableColumn(label: 'Name', flex: 3),
                          AppTableColumn(label: 'Description', flex: 5),
                          AppTableColumn(label: 'Status', flex: 2),
                        ],
                        items: provider.materials,
                        currentPage: 1,
                        totalPages: 1,
                        totalItems: provider.materials.length,
                        itemLabel: 'materials',
                        onPageChanged: (_) {},
                        rowBuilder: (material, _) =>
                            _buildMaterialRow(material, provider),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMaterialRow(
    MaterialMasterItem material,
    MaterialMasterProvider provider,
  ) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(material.name, style: theme.textTheme.small),
          ),
          Expanded(
            flex: 5,
            child: Text(
              material.description ?? '-',
              style: theme.textTheme.muted.copyWith(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(flex: 2, child: StatusBadge(status: material.status)),
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
                    _showMaterialDialog(context, provider, material: material);
                  case 'delete':
                    _confirmDelete(context, provider, material);
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

  void _showMaterialDialog(
    BuildContext context,
    MaterialMasterProvider provider, {
    MaterialMasterItem? material,
  }) {
    final nameController = TextEditingController(text: material?.name ?? '');
    final descController = TextEditingController(
      text: material?.description ?? '',
    );
    String selectedStatus = material?.status ?? 'active';

    showShadDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => ShadDialog(
          title: Text(material == null ? 'Add Material' : 'Edit Material'),
          description: Text(
            material == null
                ? 'Create a new material type'
                : 'Update material details',
          ),
          actions: [
            ShadButton.outline(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(ctx),
            ),
            ShadButton(
              child: Text(material == null ? 'Create' : 'Update'),
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;

                dynamic result;
                if (material == null) {
                  result = await provider.createMaterial(
                    name: nameController.text.trim(),
                    description: descController.text.trim().isNotEmpty
                        ? descController.text.trim()
                        : null,
                    status: selectedStatus,
                  );
                } else {
                  result = await provider.updateMaterial(
                    id: material.id,
                    name: nameController.text.trim(),
                    description: descController.text.trim().isNotEmpty
                        ? descController.text.trim()
                        : null,
                    status: selectedStatus,
                  );
                }

                if (result == null && ctx.mounted) Navigator.pop(ctx);
                if (result != null && ctx.mounted) {
                  _showErrorSnackbar(
                    ctx,
                    (result as AlertErrorResponse).alertMessage,
                  );
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
                const Text('Name *'),
                const SizedBox(height: 6),
                ShadInput(
                  controller: nameController,
                  placeholder: const Text('Enter material name'),
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
                  initialValue: selectedStatus,
                  placeholder: const Text('Select status'),
                  options: const [
                    ShadOption(value: 'active', child: Text('Active')),
                    ShadOption(value: 'inactive', child: Text('Inactive')),
                  ],
                  selectedOptionBuilder: (ctx, value) =>
                      Text(value == 'active' ? 'Active' : 'Inactive'),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedStatus = value);
                    }
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

  void _confirmDelete(
    BuildContext context,
    MaterialMasterProvider provider,
    MaterialMasterItem material,
  ) {
    showShadDialog(
      context: context,
      builder: (ctx) => ShadDialog.alert(
        title: const Text('Delete Material'),
        description: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Are you sure you want to delete "${material.name}"?'),
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
              final result = await provider.deleteMaterial(id: material.id);
              if (result is MasterInUseError && context.mounted) {
                _showMasterInUseDialog(context, result);
              } else if (result is AlertErrorResponse && context.mounted) {
                _showErrorSnackbar(context, result.alertMessage);
              }
            },
          ),
        ],
      ),
    );
  }

  /// Shows a modal dialog when the backend returns MASTER_IN_USE (HTTP 409).
  void _showMasterInUseDialog(BuildContext context, MasterInUseError error) {
    showShadDialog(
      context: context,
      builder: (ctx) => ShadDialog.alert(
        title: const Text('Cannot Delete Material'),
        description: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'This material is currently referenced by '
            '${error.referencingProductCount} product(s). '
            'Remove or reassign these products before deleting.',
          ),
        ),
        actions: [
          ShadButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
