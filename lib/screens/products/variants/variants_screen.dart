import 'dart:typed_data';

import 'package:dio/dio.dart' show MultipartFile;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/services/toast_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/navigation_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../model/response/response.dart';
import '../../../provider/variant_provider.dart';
import '../../../static_values/static_values.dart';
import '../../../widgets/page_header.dart';
import '../../../widgets/skeletons.dart';
import '../../../widgets/status_badge.dart';

/// Variant CRUD for a single product. Reached via `/admin/products/:id/variants`.
class VariantsScreen extends StatefulWidget {
  final int productId;
  const VariantsScreen({super.key, required this.productId});

  @override
  State<VariantsScreen> createState() => _VariantsScreenState();
}

class _VariantsScreenState extends State<VariantsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<VariantProvider>().loadFor(widget.productId);
    });
  }

  Future<void> _openForm({ProductVariant? variant}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) =>
          _VariantFormDialog(productId: widget.productId, variant: variant),
    );
    if (saved == true && mounted) {
      ToastService.success(
        context,
        variant == null ? 'Variant created' : 'Variant updated',
      );
    }
  }

  Future<void> _confirmDelete(ProductVariant v) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete variant?'),
        content: Text(
          '"${v.variantName}" will be removed permanently. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ShadButton.destructive(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final err = await context.read<VariantProvider>().delete(v.id);
    if (!mounted) return;
    if (err == null) {
      ToastService.success(context, 'Variant deleted');
    } else {
      ToastService.fromError(context, err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VariantProvider>(
      builder: (context, p, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Variants',
                subtitle:
                    'Manage colour / size combinations and per-variant inventory',
                onBack: () => smartBack(context, '/admin/products'),
                actions: [
                  ShadButton(
                    leading: const Icon(LucideIcons.plus, size: 14),
                    onPressed: () => _openForm(),
                    child: const Text('Add Variant'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (p.isLoading && p.items.isEmpty)
                const Expanded(child: TableSkeleton(rows: 6, columns: 6))
              else if (p.items.isEmpty)
                Expanded(child: _buildEmpty())
              else
                Expanded(child: _buildList(p)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    final theme = ShadTheme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.muted.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              LucideIcons.layers,
              size: 28,
              color: theme.colorScheme.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          Text('No variants yet', style: theme.textTheme.h4),
          const SizedBox(height: 6),
          Text(
            'Variants let you sell different sizes / colours of the same product.',
            style: theme.textTheme.muted,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ShadButton(
            leading: const Icon(LucideIcons.plus, size: 14),
            onPressed: () => _openForm(),
            child: const Text('Add your first variant'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(VariantProvider p) {
    final theme = ShadTheme.of(context);
    return ShadCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.muted.withValues(alpha: 0.3),
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.border),
              ),
            ),
            child: Row(
              children: [
                _h('VARIANT', 3),
                _h('SKU', 2),
                _h('PRICE', 2),
                _h('STOCK', 2),
                _h('STATUS', 1),
                const SizedBox(width: 80),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: p.items.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: theme.colorScheme.border),
              itemBuilder: (_, i) => _row(p.items[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(ProductVariant v) {
    final theme = ShadTheme.of(context);
    final low = v.stock <= v.minStockAlert;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _Thumb(image: v.image),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v.variantName ?? '-',
                        style: theme.textTheme.small,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (v.color != null || v.size != null)
                        Text(
                          [v.color, v.size].whereType<String>().join(' • '),
                          style: theme.textTheme.muted.copyWith(fontSize: 11),
                        ),
                    ],
                  ),
                ),
                if (v.isDefault)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.brand.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'DEFAULT',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppTheme.brand,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              v.sku ?? '-',
              style: theme.textTheme.muted.copyWith(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${v.sellingPrice.toStringAsFixed(2)}',
                  style: theme.textTheme.small.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (v.mrp > v.sellingPrice)
                  Text(
                    '₹${v.mrp.toStringAsFixed(2)}',
                    style: theme.textTheme.muted.copyWith(
                      fontSize: 11,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(
                  '${v.stock}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: low
                        ? AppTheme.warningColor
                        : theme.colorScheme.foreground,
                  ),
                ),
                if (low) ...[
                  const SizedBox(width: 4),
                  Icon(
                    LucideIcons.triangleAlert,
                    size: 12,
                    color: AppTheme.warningColor,
                  ),
                ],
              ],
            ),
          ),
          Expanded(flex: 1, child: StatusBadge(status: v.status)),
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    LucideIcons.pencil,
                    size: 14,
                    color: theme.colorScheme.mutedForeground,
                  ),
                  tooltip: 'Edit',
                  onPressed: () => _openForm(variant: v),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    LucideIcons.trash2,
                    size: 14,
                    color: AppTheme.dangerColor,
                  ),
                  tooltip: 'Delete',
                  onPressed: () => _confirmDelete(v),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _h(String text, int flex) {
    final theme = ShadTheme.of(context);
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: theme.textTheme.muted.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String? image;
  const _Thumb({required this.image});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    if (image == null || image!.isEmpty) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.muted.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          LucideIcons.image,
          size: 14,
          color: theme.colorScheme.mutedForeground,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        '$uploadsBaseUrl/$image',
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 36,
          height: 36,
          color: theme.colorScheme.muted,
          child: const Icon(LucideIcons.image, size: 14),
        ),
      ),
    );
  }
}

// ─── Form dialog ──────────────────────────────────────────────────────────────

class _VariantFormDialog extends StatefulWidget {
  final int productId;
  final ProductVariant? variant;
  const _VariantFormDialog({required this.productId, this.variant});

  bool get isEdit => variant != null;

  @override
  State<_VariantFormDialog> createState() => _VariantFormDialogState();
}

class _VariantFormDialogState extends State<_VariantFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _color = TextEditingController();
  final _size = TextEditingController();
  final _sku = TextEditingController();
  final _barcode = TextEditingController();
  final _mrp = TextEditingController();
  final _selling = TextEditingController();
  final _stock = TextEditingController();
  final _minStock = TextEditingController(text: '5');
  final _weight = TextEditingController();
  String _status = 'active';
  bool _isDefault = false;

  Uint8List? _pickedImageBytes;
  String? _pickedImageName;

  @override
  void initState() {
    super.initState();
    final v = widget.variant;
    if (v != null) {
      _name.text = v.variantName ?? '';
      _color.text = v.color ?? '';
      _size.text = v.size ?? '';
      _sku.text = v.sku ?? '';
      _barcode.text = v.barcode ?? '';
      _mrp.text = v.mrp.toString();
      _selling.text = v.sellingPrice.toString();
      _stock.text = v.stock.toString();
      _minStock.text = v.minStockAlert.toString();
      _weight.text = v.weight ?? '';
      _status = v.status;
      _isDefault = v.isDefault;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _color.dispose();
    _size.dispose();
    _sku.dispose();
    _barcode.dispose();
    _mrp.dispose();
    _selling.dispose();
    _stock.dispose();
    _minStock.dispose();
    _weight.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    setState(() {
      _pickedImageBytes = result.files.first.bytes;
      _pickedImageName = result.files.first.name;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final p = context.read<VariantProvider>();
    final fields = <String, dynamic>{
      'variantName': _name.text.trim(),
      'color': _color.text.trim(),
      'size': _size.text.trim(),
      'sku': _sku.text.trim(),
      'barcode': _barcode.text.trim(),
      'mrp': _mrp.text.trim(),
      'sellingPrice': _selling.text.trim(),
      'stock': _stock.text.trim(),
      'minStockAlert': _minStock.text.trim(),
      'weight': _weight.text.trim(),
      'status': _status,
      'isDefault': _isDefault,
    };
    final image = _pickedImageBytes != null
        ? MultipartFile.fromBytes(
            _pickedImageBytes!,
            filename: _pickedImageName ?? 'variant.png',
          )
        : null;

    final err = widget.isEdit
        ? await p.update(id: widget.variant!.id, fields: fields, image: image)
        : await p.create(
            productId: widget.productId,
            fields: fields,
            image: image,
          );

    if (!mounted) return;
    if (err != null) {
      ToastService.fromError(context, err);
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 700),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.isEdit ? 'Edit variant' : 'Add variant',
                  style: theme.textTheme.h3,
                ),
                const SizedBox(height: 4),
                Text(
                  'Each variant has its own SKU, price and stock.',
                  style: theme.textTheme.muted,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _Field(
                        label: 'Variant name',
                        child: TextFormField(
                          controller: _name,
                          validator: Validators.required(),
                          decoration: _decoration(
                            LucideIcons.tag,
                            'e.g. Red — Large',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Field(
                        label: 'Color',
                        child: TextFormField(
                          controller: _color,
                          decoration: _decoration(LucideIcons.palette, 'Red'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Field(
                        label: 'Size',
                        child: TextFormField(
                          controller: _size,
                          decoration: _decoration(LucideIcons.ruler, 'L'),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        label: 'SKU',
                        child: TextFormField(
                          controller: _sku,
                          validator: Validators.sku(),
                          decoration: _decoration(
                            LucideIcons.barcode,
                            'BRAND-RED-L',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Field(
                        label: 'Barcode',
                        child: TextFormField(
                          controller: _barcode,
                          decoration: _decoration(
                            LucideIcons.scanLine,
                            'optional',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        label: 'MRP (₹)',
                        child: TextFormField(
                          controller: _mrp,
                          keyboardType: TextInputType.number,
                          validator: Validators.number(min: 0),
                          decoration: _decoration(
                            LucideIcons.indianRupee,
                            '0.00',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Field(
                        label: 'Selling (₹)',
                        child: TextFormField(
                          controller: _selling,
                          keyboardType: TextInputType.number,
                          validator: Validators.number(min: 0),
                          decoration: _decoration(
                            LucideIcons.indianRupee,
                            '0.00',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Field(
                        label: 'Weight',
                        child: TextFormField(
                          controller: _weight,
                          decoration: _decoration(LucideIcons.weight, '500g'),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        label: 'Stock',
                        child: TextFormField(
                          controller: _stock,
                          keyboardType: TextInputType.number,
                          validator: Validators.integer(min: 0),
                          decoration: _decoration(LucideIcons.package, '0'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Field(
                        label: 'Low-stock alert',
                        child: TextFormField(
                          controller: _minStock,
                          keyboardType: TextInputType.number,
                          validator: Validators.integer(min: 0),
                          decoration: _decoration(LucideIcons.bell, '5'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Field(
                        label: 'Status',
                        child: DropdownButtonFormField<String>(
                          initialValue: _status,
                          decoration: _decoration(
                            LucideIcons.activity,
                            'Status',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'active',
                              child: Text('Active'),
                            ),
                            DropdownMenuItem(
                              value: 'inactive',
                              child: Text('Inactive'),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _status = v ?? 'active'),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Switch(
                      value: _isDefault,
                      onChanged: (v) => setState(() => _isDefault = v),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Mark as default variant',
                      style: theme.textTheme.small,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Field(
                  label: 'Variant image',
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.muted.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _pickedImageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  _pickedImageBytes!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : widget.variant?.image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  '$uploadsBaseUrl/${widget.variant!.image}',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(LucideIcons.image),
                                ),
                              )
                            : Icon(
                                LucideIcons.image,
                                color: theme.colorScheme.mutedForeground,
                              ),
                      ),
                      const SizedBox(width: 12),
                      ShadButton.outline(
                        leading: const Icon(LucideIcons.upload, size: 14),
                        onPressed: _pickImage,
                        child: const Text('Upload image'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Consumer<VariantProvider>(
                      builder: (_, p, __) => Row(
                        children: [
                          ShadButton.outline(
                            onPressed: p.isSaving
                                ? null
                                : () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 10),
                          ShadButton(
                            leading: p.isSaving
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    widget.isEdit
                                        ? LucideIcons.check
                                        : LucideIcons.plus,
                                    size: 14,
                                  ),
                            onPressed: p.isSaving ? null : _submit,
                            child: Text(
                              p.isSaving
                                  ? 'Saving...'
                                  : widget.isEdit
                                  ? 'Save changes'
                                  : 'Create variant',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(IconData icon, String hint) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, size: 16),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  );
}

class _Field extends StatelessWidget {
  final String label;
  final Widget child;
  const _Field({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.small.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}
