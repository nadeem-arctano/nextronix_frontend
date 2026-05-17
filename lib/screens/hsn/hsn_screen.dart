import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/theme/app_theme.dart';
import '../../model/response/response.dart';
import '../../provider/hsn_provider.dart';
import '../../widgets/app_list_table.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/page_header.dart';
import '../../widgets/skeletons.dart';

class HsnScreen extends StatefulWidget {
  const HsnScreen({super.key});

  @override
  State<HsnScreen> createState() => _HsnScreenState();
}

class _HsnScreenState extends State<HsnScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HsnProvider>().loadHsnCodes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HsnProvider>(
      builder: (context, provider, _) {
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
                    onPressed: () => _showHsnDialog(context, provider),
                    child: const Text('Add HSN Code'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: provider.isLoading
                    ? const TableSkeleton(rows: 6, columns: 4)
                    : provider.hsnCodes.isEmpty
                    ? const EmptyWidget(message: 'No HSN codes found')
                    : AppListTable<HsnResult>(
                        columns: const [
                          AppTableColumn(label: 'HSN Code', flex: 3),
                          AppTableColumn(label: 'GST %', flex: 2),
                          AppTableColumn(label: 'Products', flex: 2),
                          AppTableColumn(label: 'Description', flex: 5),
                        ],
                        items: provider.hsnCodes,
                        currentPage: 1,
                        totalPages: 1,
                        totalItems: provider.hsnCodes.length,
                        itemLabel: 'HSN codes',
                        onPageChanged: (_) {},
                        rowBuilder: (hsn, _) => _buildHsnRow(hsn, provider),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHsnRow(HsnResult hsn, HsnProvider provider) {
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
              '${hsn.gstPercent?.toStringAsFixed(0) ?? '0'}%',
              style: theme.textTheme.small,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${hsn.productCount ?? 0}',
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
                    _showHsnDialog(context, provider, hsn: hsn);
                  case 'delete':
                    _confirmDelete(context, provider, hsn);
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

  void _showHsnDialog(
    BuildContext context,
    HsnProvider provider, {
    HsnResult? hsn,
  }) {
    final hsnCodeController = TextEditingController(text: hsn?.hsnCode ?? '');
    final gstController = TextEditingController(
      text: hsn?.gstPercent?.toStringAsFixed(0) ?? '',
    );
    final descController = TextEditingController(text: hsn?.description ?? '');

    showShadDialog(
      context: context,
      builder: (ctx) => ShadDialog(
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
              if (hsnCodeController.text.isEmpty || gstController.text.isEmpty)
                return;

              final gst = double.tryParse(gstController.text);
              if (gst == null) return;

              dynamic result;
              if (hsn == null) {
                result = await provider.createHsn(
                  hsnCode: hsnCodeController.text,
                  gstPercent: gst,
                  description: descController.text.isNotEmpty
                      ? descController.text
                      : null,
                );
              } else {
                result = await provider.updateHsn(
                  id: hsn.id!,
                  hsnCode: hsnCodeController.text,
                  gstPercent: gst,
                  description: descController.text.isNotEmpty
                      ? descController.text
                      : null,
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
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    HsnProvider provider,
    HsnResult hsn,
  ) {
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
            onPressed: () {
              provider.deleteHsn(id: hsn.id!);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
