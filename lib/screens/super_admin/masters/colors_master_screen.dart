import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/app_theme.dart';
import '../../../model/response/response.dart';
import '../../../provider/color_master_provider.dart';
import '../../../provider/material_master_provider.dart' show MasterInUseError;
import '../../../widgets/app_list_table.dart';
import '../../../widgets/page_header.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/skeletons.dart';
import '../../../widgets/loading_widget.dart';

class ColorsMasterScreen extends StatefulWidget {
  const ColorsMasterScreen({super.key});

  @override
  State<ColorsMasterScreen> createState() => _ColorsMasterScreenState();
}

class _ColorsMasterScreenState extends State<ColorsMasterScreen> {
  /// Locally-managed hidden-columns set so the column-toggle button can
  /// live in the page header actions alongside the Add Color button.
  Set<String> _hiddenColumns = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ColorMasterProvider>().loadColors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ColorMasterProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Colors',
                actions: [
                  AppListTableColumnMenu(
                    columns: const [
                      AppTableColumn(key: 'color', label: 'Color'),
                      AppTableColumn(key: 'hex', label: 'Hex Code'),
                      AppTableColumn(key: 'status', label: 'Status'),
                    ],
                    hiddenColumns: _hiddenColumns,
                    onChanged: (next) => setState(() => _hiddenColumns = next),
                  ),
                  ShadButton(
                    leading: const Icon(LucideIcons.plus, size: 16),
                    onPressed: () => _showColorDialog(context, provider),
                    child: const Text('Add Color'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: provider.isLoading
                    ? const TableSkeleton(rows: 6, columns: 4)
                    : provider.colors.isEmpty
                    ? const EmptyWidget(message: 'No colors found')
                    : AppListTable<ColorResult>(
                        columns: const [
                          AppTableColumn(key: 'color', label: 'Color', flex: 4),
                          AppTableColumn(
                            key: 'hex',
                            label: 'Hex Code',
                            flex: 2,
                          ),
                          AppTableColumn(
                            key: 'status',
                            label: 'Status',
                            flex: 2,
                          ),
                        ],
                        hiddenColumns: _hiddenColumns,
                        items: provider.colors,
                        currentPage: 1,
                        totalPages: 1,
                        totalItems: provider.colors.length,
                        itemLabel: 'colors',
                        onPageChanged: (_) {},
                        rowBuilder: (color, _) =>
                            _buildColorRow(color, provider),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorSwatch(String? hexCode) {
    Color swatchColor = Colors.grey.shade300;
    if (hexCode != null && hexCode.isNotEmpty) {
      try {
        String hex = hexCode.replaceAll('#', '');
        if (hex.length == 6) {
          swatchColor = Color(int.parse('FF$hex', radix: 16));
        }
      } catch (_) {
        // Keep default grey if hex is invalid
      }
    }
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: swatchColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
      ),
    );
  }

  Widget _buildColorRow(ColorResult color, ColorMasterProvider provider) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (!AppListTable.isColumnHidden(context, 'color'))
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  _buildColorSwatch(color.hexCode),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      color.name ?? '',
                      style: theme.textTheme.small,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          if (!AppListTable.isColumnHidden(context, 'hex'))
            Expanded(
              flex: 2,
              child: Text(
                color.hexCode ?? '—',
                style: theme.textTheme.small.copyWith(fontFamily: 'monospace'),
              ),
            ),
          if (!AppListTable.isColumnHidden(context, 'status'))
            Expanded(
              flex: 2,
              child: StatusBadge(status: color.status ?? 'active'),
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
                    _showColorDialog(context, provider, color: color);
                  case 'delete':
                    _confirmDelete(context, provider, color);
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

  void _showColorDialog(
    BuildContext context,
    ColorMasterProvider provider, {
    ColorResult? color,
  }) {
    final nameController = TextEditingController(text: color?.name ?? '');
    final hexController = TextEditingController(text: color?.hexCode ?? '');
    String status = color?.status ?? 'active';

    showShadDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => ShadDialog(
          title: Text(color == null ? 'Add Color' : 'Edit Color'),
          description: Text(
            color == null
                ? 'Create a new color for products'
                : 'Update color details',
          ),
          actions: [
            ShadButton.outline(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(ctx),
            ),
            ShadButton(
              child: Text(color == null ? 'Create' : 'Update'),
              onPressed: () async {
                if (nameController.text.isEmpty) return;

                dynamic result;
                if (color == null) {
                  result = await provider.createColor(
                    name: nameController.text,
                    hexCode: hexController.text.isNotEmpty
                        ? hexController.text
                        : null,
                    status: status,
                  );
                } else {
                  result = await provider.updateColor(
                    id: color.id!,
                    name: nameController.text,
                    hexCode: hexController.text.isNotEmpty
                        ? hexController.text
                        : null,
                    status: status,
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
                const Text('Color Name *'),
                const SizedBox(height: 6),
                ShadInput(
                  controller: nameController,
                  placeholder: const Text('Enter color name'),
                ),
                const SizedBox(height: 16),
                const Text('Hex Code'),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ShadInput(
                        controller: hexController,
                        placeholder: const Text('#FF5733'),
                        onChanged: (_) => setDialogState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildColorSwatch(hexController.text),
                  ],
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

  void _confirmDelete(
    BuildContext context,
    ColorMasterProvider provider,
    ColorResult color,
  ) {
    showShadDialog(
      context: context,
      builder: (ctx) => ShadDialog.alert(
        title: const Text('Delete Color'),
        description: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Are you sure you want to delete "${color.name}"?'),
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
              final result = await provider.deleteColor(id: color.id!);
              if (result is MasterInUseError && mounted) {
                _showMasterInUseDialog(context, result);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showMasterInUseDialog(BuildContext context, MasterInUseError error) {
    showShadDialog(
      context: context,
      builder: (ctx) => ShadDialog.alert(
        title: const Text('Cannot Delete Color'),
        description: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'This color is currently referenced by ${error.referencingProductCount} product(s). '
            'Remove the color from all products before deleting.',
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
}
