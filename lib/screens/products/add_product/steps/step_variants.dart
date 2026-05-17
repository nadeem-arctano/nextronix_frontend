import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../widgets/forms/forms.dart';
import '../controller/add_product_form.dart';
import '../widgets/tag_input_field.dart';

/// Step 6: Variants matrix (Color × Size).
///
/// Mirrors the Amazon "List variations" UI but limited to the two
/// dimensions our schema supports. The matrix below the chip inputs
/// is auto-generated whenever the user adds/removes a Color or Size,
/// and the SKU/price/stock the user types stays attached to its
/// combination key across rebuilds (see `VariantRowDraft`).
class StepVariants extends StatefulWidget {
  final AddProductForm form;
  const StepVariants({super.key, required this.form});

  @override
  State<StepVariants> createState() => _StepVariantsState();
}

class _StepVariantsState extends State<StepVariants> {
  @override
  Widget build(BuildContext context) {
    final form = widget.form;
    final theme = ShadTheme.of(context);

    return Column(
      children: [
        SectionCard(
          title: 'Does this product have variants?',
          subtitle:
              'Variants let you sell the same product in different colours '
              'or sizes. Each variant carries its own SKU, price and stock.',
          children: [
            Row(
              children: [
                Switch(
                  value: form.hasVariants,
                  onChanged: (v) {
                    setState(() {
                      form.hasVariants = v;
                      // Clearing on toggle-off is safer — prevents stale
                      // matrix rows from being submitted on Save.
                      if (!v) {
                        form.colorOptions.clear();
                        form.sizeOptions.clear();
                        for (final r in form.variantRows.values) {
                          r.dispose();
                        }
                        form.variantRows.clear();
                      }
                    });
                  },
                ),
                const SizedBox(width: 12),
                Text(
                  form.hasVariants
                      ? 'Variants enabled'
                      : 'Single product (no variants)',
                  style: theme.textTheme.small,
                ),
              ],
            ),
          ],
        ),
        if (form.hasVariants) ...[
          SectionCard(
            title: 'Variation type',
            subtitle:
                'Add the colours and sizes available for this product. '
                'Press Enter or tap Add after typing each value.',
            children: [
              TagInputField(
                label: 'Color',
                hintText: 'e.g. Crimson red',
                example: 'Jet Black',
                values: form.colorOptions,
                onChanged: (next) {
                  setState(() {
                    form.colorOptions
                      ..clear()
                      ..addAll(next);
                    form.pruneOrphanRows();
                  });
                },
              ),
              TagInputField(
                label: 'Size',
                hintText: 'e.g. M',
                example: 'L, M, S or 32, 34, 36',
                values: form.sizeOptions,
                onChanged: (next) {
                  setState(() {
                    form.sizeOptions
                      ..clear()
                      ..addAll(next);
                    form.pruneOrphanRows();
                  });
                },
              ),
            ],
          ),
          SectionCard(
            title: 'Variant matrix',
            subtitle:
                'One row per Color × Size combination. Fill in SKU, '
                'selling price and stock for each.',
            children: [_buildMatrix(form, theme)],
          ),
        ],
      ],
    );
  }

  Widget _buildMatrix(AddProductForm form, ShadThemeData theme) {
    final combos = form.variantCombinations;
    if (combos.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.muted.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.border),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                LucideIcons.layers,
                size: 24,
                color: theme.colorScheme.mutedForeground,
              ),
              const SizedBox(height: 8),
              Text(
                'Add at least one Color or Size above to see the matrix',
                style: theme.textTheme.muted,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.muted.withValues(alpha: 0.4),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: theme.colorScheme.border),
          ),
          child: Row(
            children: [
              _h('COLOR', 2, theme),
              _h('SIZE', 1, theme),
              _h('SKU', 3, theme),
              _h('PRICE (₹)', 2, theme),
              _h('STOCK', 2, theme),
              const SizedBox(width: 32),
            ],
          ),
        ),
        // Rows
        Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: theme.colorScheme.border),
              right: BorderSide(color: theme.colorScheme.border),
              bottom: BorderSide(color: theme.colorScheme.border),
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(8),
            ),
          ),
          child: Column(
            children: [
              for (var i = 0; i < combos.length; i++) ...[
                _row(form, combos[i], theme),
                if (i < combos.length - 1)
                  Divider(height: 1, color: theme.colorScheme.border),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${combos.length} variant${combos.length == 1 ? '' : 's'} will be created.',
          style: theme.textTheme.muted.copyWith(fontSize: 11),
        ),
      ],
    );
  }

  Widget _h(String text, int flex, ShadThemeData theme) => Expanded(
    flex: flex,
    child: Text(
      text,
      style: theme.textTheme.muted.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),
  );

  Widget _row(
    AddProductForm form,
    ({String color, String size}) combo,
    ShadThemeData theme,
  ) {
    final draft = form.rowFor(combo.color, combo.size);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Color label
          Expanded(
            flex: 2,
            child: combo.color.isEmpty
                ? Text('—', style: theme.textTheme.muted)
                : Text(
                    combo.color,
                    style: theme.textTheme.small.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
          // Size label
          Expanded(
            flex: 1,
            child: combo.size.isEmpty
                ? Text('—', style: theme.textTheme.muted)
                : Text(combo.size, style: theme.textTheme.small),
          ),
          // SKU
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: ShadTextInput(
                controller: draft.sku,
                hint:
                    'TR-${combo.color.toUpperCase()}-${combo.size.toUpperCase()}',
              ),
            ),
          ),
          // Price
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: ShadTextInput(
                controller: draft.sellingPrice,
                hint: '0.00',
                prefix: '₹',
                keyboardType: TextInputType.number,
              ),
            ),
          ),
          // Stock
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: ShadTextInput(
                controller: draft.stock,
                hint: '0',
                keyboardType: TextInputType.number,
              ),
            ),
          ),
          // Delete row (also removes the corresponding tag if it leaves
          // the matrix empty in that dimension).
          SizedBox(
            width: 32,
            child: IconButton(
              tooltip: 'Remove this variant',
              icon: const Icon(
                LucideIcons.trash2,
                size: 14,
                color: AppTheme.dangerColor,
              ),
              onPressed: () {
                setState(() {
                  // Just dispose this row; the source-of-truth is the tag
                  // lists, so to truly drop it we'd have to remove the
                  // tag too. We choose the gentler behaviour: zero its
                  // values out so it's effectively a "skip this combo".
                  draft.sku.clear();
                  draft.sellingPrice.clear();
                  draft.stock.text = '0';
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
