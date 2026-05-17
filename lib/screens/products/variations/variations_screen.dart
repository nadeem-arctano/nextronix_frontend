import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/services/toast_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../model/request/request.dart';
import '../../../model/response/response.dart';
import '../../../provider/product_provider.dart';
import '../../../provider/variant_group_provider.dart';
import '../../../widgets/page_header.dart';
import '../../../widgets/skeletons.dart';

/// Variations management for a single product.
///
/// Reached via `/admin/products/:productId/variations`. The page resolves the
/// "anchor" product (the one passed in), then loads its variant group. If the
/// product is currently standalone, the screen offers a "Make Variant Group"
/// flow that turns it into a parent and lets the user pick same-category
/// standalone products to attach as children.
///
/// Constraints (all enforced server-side, mirrored here for UX):
///   • Only same-category standalone products are pickable.
///   • Source products are never deleted; remove just unlinks them.
///   • Removing the parent dissolves the entire group (we confirm first).
class VariationsScreen extends StatefulWidget {
  final int productId;
  const VariationsScreen({super.key, required this.productId});

  @override
  State<VariationsScreen> createState() => _VariationsScreenState();
}

class _VariationsScreenState extends State<VariationsScreen> {
  ProductResult? _anchor;
  bool _loadingAnchor = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    setState(() => _loadingAnchor = true);
    final productProv = context.read<ProductProvider>();
    final groupProv = context.read<VariantGroupProvider>();

    // Fetch the anchor product so we know its category and current group role.
    await productProv.loadProductById(id: widget.productId);
    _anchor = productProv.selectedProduct;

    // Load the group (returns null if still standalone).
    await groupProv.loadGroup(widget.productId);

    if (mounted) setState(() => _loadingAnchor = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VariantGroupProvider>(
      builder: (context, prov, _) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageHeader(
                    title: _anchor?.name ?? 'Variations',
                    subtitle: prov.hasGroup
                        ? '${prov.childrenCount} variation${prov.childrenCount == 1 ? '' : 's'} linked'
                        : 'Group this product with same-category SKUs to manage them as one variant family.',
                    actions: [
                      ShadButton.outline(
                        leading: const Icon(Icons.arrow_back, size: 14),
                        onPressed: () => context.pop(),
                        child: const Text('Back'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_loadingAnchor || prov.isLoading)
                    const CardSkeleton(lines: 6)
                  else if (_anchor == null)
                    _ErrorBlock(message: prov.error ?? 'Product not found.')
                  else if (!prov.hasGroup)
                    _MakeGroupBlock(anchor: _anchor!)
                  else
                    _GroupView(anchor: _anchor!, group: prov.group!),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Tiny error/empty card ─────────────────────────────────────────────────
class _ErrorBlock extends StatelessWidget {
  final String message;
  const _ErrorBlock({required this.message});
  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(message, style: TextStyle(color: AppTheme.textMuted)),
      ),
    );
  }
}

// ─── No-group state: prompt to create one ───────────────────────────────────
class _MakeGroupBlock extends StatelessWidget {
  final ProductResult anchor;
  const _MakeGroupBlock({required this.anchor});

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.layers_outlined, size: 36, color: AppTheme.brand),
          const SizedBox(height: 12),
          const Text(
            'No variations yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Pick same-category SKUs you have already added — they\'ll become variants of "${anchor.name ?? 'this product'}".',
            style: TextStyle(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 16),
          ShadButton(
            leading: const Icon(Icons.add, size: 14),
            onPressed: () async {
              final added = await showDialog<bool>(
                context: context,
                builder: (_) => _AddVariationDialog(
                  anchorId: anchor.id ?? 0,
                  categoryId: anchor.categoryId ?? 0,
                  isCreatingGroup: true,
                  defaultColor: anchor.color,
                ),
              );
              if (added == true && context.mounted) {
                ToastService.success(context, 'Variant group created');
              }
            },
            child: const Text('Make variant group'),
          ),
        ],
      ),
    );
  }
}

// ─── Active group view: parent + children ──────────────────────────────────
class _GroupView extends StatelessWidget {
  final ProductResult anchor;
  final VariantGroup group;
  const _GroupView({required this.anchor, required this.group});

  @override
  Widget build(BuildContext context) {
    final parent = group.parent;
    final children = group.children;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (parent != null)
          _MemberCard(
            member: parent,
            isParent: true,
            onRemove: () => _confirmRemoveParent(context, parent),
            onPromote: null,
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text(
              'Variations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 12),
            _CountPill(count: children.length),
            const Spacer(),
            ShadButton(
              leading: const Icon(Icons.add, size: 14),
              onPressed: () async {
                final added = await showDialog<bool>(
                  context: context,
                  builder: (_) => _AddVariationDialog(
                    anchorId: parent?.id ?? anchor.id ?? 0,
                    categoryId: anchor.categoryId ?? 0,
                    isCreatingGroup: false,
                  ),
                );
                if (added == true && context.mounted) {
                  ToastService.success(context, 'Variant added');
                }
              },
              child: const Text('Add variation'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (children.isEmpty)
          const _EmptyChildren()
        else
          ...children.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _MemberCard(
                member: c,
                isParent: false,
                onRemove: () => _confirmRemoveChild(context, c),
                onPromote: () => _confirmPromote(context, c),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _confirmRemoveParent(
    BuildContext context,
    VariantGroupMember parent,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dissolve this group?'),
        content: const Text(
          'This product is the group parent. Removing it will turn ALL '
          'variations back into standalone products and dissolve the group entirely. '
          'No data is lost — every product stays as-is.\n\nContinue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Dissolve group'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final prov = context.read<VariantGroupProvider>();
    final err = await prov.removeMember(id: parent.id);
    if (!context.mounted) return;
    if (err != null) {
      ToastService.error(context, err.alertMessage);
    } else {
      ToastService.success(context, 'Group dissolved');
      context.pop();
    }
  }

  Future<void> _confirmRemoveChild(
    BuildContext context,
    VariantGroupMember child,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove this variation?'),
        content: Text(
          '"${child.name}" will become a standalone product again. '
          'It will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final prov = context.read<VariantGroupProvider>();
    final err = await prov.removeMember(id: child.id);
    if (!context.mounted) return;
    if (err != null) {
      ToastService.error(context, err.alertMessage);
    } else {
      ToastService.success(context, 'Variation removed');
    }
  }

  Future<void> _confirmPromote(
    BuildContext context,
    VariantGroupMember child,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Promote to parent?'),
        content: Text(
          '"${child.name}" will become the new parent of this group. '
          'The current parent will be demoted to a child.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Promote'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final prov = context.read<VariantGroupProvider>();
    final err = await prov.promoteToParent(id: child.id);
    if (!context.mounted) return;
    if (err != null) {
      ToastService.error(context, err.alertMessage);
    } else {
      ToastService.success(context, 'Promoted to parent');
    }
  }
}

class _CountPill extends StatelessWidget {
  final int count;
  const _CountPill({required this.count});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.bgColor,
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyChildren extends StatelessWidget {
  const _EmptyChildren();
  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Text(
          'No variations linked yet. Click "Add variation" to attach a same-category SKU.',
          style: TextStyle(color: AppTheme.textMuted),
        ),
      ),
    );
  }
}

// ─── Single member card ────────────────────────────────────────────────────
class _MemberCard extends StatelessWidget {
  final VariantGroupMember member;
  final bool isParent;
  final VoidCallback onRemove;
  final VoidCallback? onPromote;

  const _MemberCard({
    required this.member,
    required this.isParent,
    required this.onRemove,
    this.onPromote,
  });

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Thumbnail(url: member.thumbnailImage),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _RoleBadge(isParent: isParent),
                    const SizedBox(width: 8),
                    if (member.sku != null)
                      Text(
                        member.sku!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  member.name ?? '(unnamed)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if ((member.variantOptionColor ?? '').isNotEmpty)
                      _Chip(
                        icon: Icons.palette_outlined,
                        label: member.variantOptionColor!,
                      ),
                    if ((member.variantOptionSize ?? '').isNotEmpty)
                      _Chip(
                        icon: Icons.straighten,
                        label: member.variantOptionSize!,
                      ),
                    _Chip(
                      icon: Icons.currency_rupee,
                      label: member.sellingPrice.toStringAsFixed(0),
                    ),
                    _Chip(
                      icon: Icons.inventory_2_outlined,
                      label: 'Stock ${member.stockQuantity}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            tooltip: 'Actions',
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              if (onPromote != null)
                const PopupMenuItem(
                  value: 'promote',
                  child: Text('Promote to parent'),
                ),
              const PopupMenuItem(value: 'remove', child: Text('Remove')),
            ],
            onSelected: (v) {
              if (v == 'remove') onRemove();
              if (v == 'promote' && onPromote != null) onPromote!();
            },
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final bool isParent;
  const _RoleBadge({required this.isParent});
  @override
  Widget build(BuildContext context) {
    final color = isParent ? AppTheme.brand : AppTheme.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isParent ? 'PARENT' : 'VARIATION',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String? url;
  const _Thumbnail({required this.url});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 64,
        height: 64,
        child: (url == null || url!.isEmpty)
            ? Container(
                color: AppTheme.bgColor,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: AppTheme.textMuted,
                ),
              )
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: AppTheme.bgColor,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.textMuted),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// ─── Add-variation dialog (also bootstraps a new group) ───────────────────
class _AddVariationDialog extends StatefulWidget {
  final int anchorId;
  final int categoryId;
  final bool isCreatingGroup;
  final String? defaultColor;

  const _AddVariationDialog({
    required this.anchorId,
    required this.categoryId,
    required this.isCreatingGroup,
    this.defaultColor,
  });

  @override
  State<_AddVariationDialog> createState() => _AddVariationDialogState();
}

class _AddVariationDialogState extends State<_AddVariationDialog> {
  final TextEditingController _searchCtrl = TextEditingController();
  final Set<int> _selected = {};
  final Map<int, TextEditingController> _colorCtrls = {};
  final Map<int, TextEditingController> _sizeCtrls = {};
  final TextEditingController _anchorColorCtrl = TextEditingController();
  final TextEditingController _anchorSizeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _anchorColorCtrl.text = widget.defaultColor ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<VariantGroupProvider>().loadGroupable(
        categoryId: widget.categoryId,
        excludeProductId: widget.anchorId,
      );
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _anchorColorCtrl.dispose();
    _anchorSizeCtrl.dispose();
    for (final c in _colorCtrls.values) {
      c.dispose();
    }
    for (final c in _sizeCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _colorCtrl(int id, GroupableProduct p) {
    return _colorCtrls.putIfAbsent(
      id,
      () => TextEditingController(text: p.color ?? ''),
    );
  }

  TextEditingController _sizeCtrl(int id) {
    return _sizeCtrls.putIfAbsent(id, () => TextEditingController());
  }

  Future<void> _runSearch(String q) async {
    await context.read<VariantGroupProvider>().loadGroupable(
      categoryId: widget.categoryId,
      excludeProductId: widget.anchorId,
      search: q.isEmpty ? null : q,
    );
  }

  Future<void> _submit() async {
    if (_selected.isEmpty) {
      ToastService.error(context, 'Pick at least one product');
      return;
    }
    final prov = context.read<VariantGroupProvider>();
    final pool = prov.groupable;
    final picked = pool.where((p) => _selected.contains(p.id)).toList();

    AlertErrorResponse? err;
    if (widget.isCreatingGroup) {
      final options = <int, VariantGroupOption>{
        widget.anchorId: VariantGroupOption(
          color: _anchorColorCtrl.text.trim().isEmpty
              ? null
              : _anchorColorCtrl.text.trim(),
          size: _anchorSizeCtrl.text.trim().isEmpty
              ? null
              : _anchorSizeCtrl.text.trim(),
        ),
      };
      for (final p in picked) {
        final color = _colorCtrl(p.id, p).text.trim();
        final size = _sizeCtrl(p.id).text.trim();
        options[p.id] = VariantGroupOption(
          color: color.isEmpty ? null : color,
          size: size.isEmpty ? null : size,
        );
      }
      err = await prov.createGroup(
        parentId: widget.anchorId,
        childIds: picked.map((p) => p.id).toList(),
        optionsByProduct: options,
      );
    } else {
      for (final p in picked) {
        final color = _colorCtrl(p.id, p).text.trim();
        final size = _sizeCtrl(p.id).text.trim();
        err = await prov.addChild(
          anchorId: widget.anchorId,
          childId: p.id,
          color: color.isEmpty ? null : color,
          size: size.isEmpty ? null : size,
        );
        if (err != null) break;
      }
    }

    if (!mounted) return;
    if (err != null) {
      ToastService.error(context, err.alertMessage);
    } else {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxW = media.size.width > 800 ? 760.0 : media.size.width - 32;

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Consumer<VariantGroupProvider>(
            builder: (context, prov, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.isCreatingGroup
                            ? 'Make variant group'
                            : 'Add variation',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Only same-category, standalone SKUs are listed. Free-text variant names are not supported — pick from existing products.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  if (widget.isCreatingGroup) ...[
                    const Text(
                      'Parent (this product) labels',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ShadInput(
                            controller: _anchorColorCtrl,
                            placeholder: const Text('Color'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ShadInput(
                            controller: _anchorSizeCtrl,
                            placeholder: const Text('Size'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  ShadInput(
                    controller: _searchCtrl,
                    placeholder: const Text('Search by name or SKU…'),
                    onChanged: _runSearch,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: prov.isLoadingGroupable
                        ? const Center(child: CircularProgressIndicator())
                        : prov.groupable.isEmpty
                        ? Center(
                            child: Text(
                              'No eligible standalone products in this category.',
                              style: TextStyle(color: AppTheme.textMuted),
                            ),
                          )
                        : ListView.separated(
                            itemCount: prov.groupable.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              final p = prov.groupable[i];
                              return _PickRow(
                                product: p,
                                selected: _selected.contains(p.id),
                                colorCtrl: _colorCtrl(p.id, p),
                                sizeCtrl: _sizeCtrl(p.id),
                                onToggle: () => setState(() {
                                  if (_selected.contains(p.id)) {
                                    _selected.remove(p.id);
                                  } else {
                                    _selected.add(p.id);
                                  }
                                }),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShadButton.outline(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ShadButton(
                        onPressed: prov.isSaving ? null : _submit,
                        child: Text(
                          prov.isSaving
                              ? 'Saving…'
                              : widget.isCreatingGroup
                              ? 'Create group'
                              : 'Add ${_selected.length} variation${_selected.length == 1 ? '' : 's'}',
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PickRow extends StatelessWidget {
  final GroupableProduct product;
  final bool selected;
  final TextEditingController colorCtrl;
  final TextEditingController sizeCtrl;
  final VoidCallback onToggle;

  const _PickRow({
    required this.product,
    required this.selected,
    required this.colorCtrl,
    required this.sizeCtrl,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: selected ? AppTheme.brand.withValues(alpha: 0.08) : null,
        border: Border.all(
          color: selected ? AppTheme.brand : AppTheme.borderColor,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Checkbox(value: selected, onChanged: (_) => onToggle()),
          _Thumbnail(url: product.thumbnailImage),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name ?? '(unnamed)',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (product.sku != null)
                  Text(
                    product.sku!,
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
              ],
            ),
          ),
          if (selected) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 110,
              child: ShadInput(
                controller: colorCtrl,
                placeholder: const Text('Color'),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 90,
              child: ShadInput(
                controller: sizeCtrl,
                placeholder: const Text('Size'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
