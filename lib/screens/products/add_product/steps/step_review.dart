import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../widgets/forms/forms.dart';
import '../controller/add_product_form.dart';

/// Step 6: review every section's filled values + listing controls
/// (status / featured) before publishing.
class StepReview extends StatefulWidget {
  final AddProductForm form;
  const StepReview({super.key, required this.form});

  @override
  State<StepReview> createState() => _StepReviewState();
}

class _StepReviewState extends State<StepReview> {
  @override
  Widget build(BuildContext context) {
    final form = widget.form;
    final theme = ShadTheme.of(context);
    return Column(
      children: [
        SectionCard(
          title: 'Listing settings',
          subtitle: 'Decide how the product appears in your store.',
          children: [
            FormFieldGrid(
              children: [
                FormFieldBlock(
                  label: 'Status',
                  child: DropdownButtonFormField<String>(
                    initialValue: form.status,
                    decoration: _decoration(),
                    items: const [
                      DropdownMenuItem(
                        value: 'active',
                        child: Text('Active — visible to buyers'),
                      ),
                      DropdownMenuItem(
                        value: 'draft',
                        child: Text('Draft — saved but hidden'),
                      ),
                      DropdownMenuItem(
                        value: 'inactive',
                        child: Text('Inactive — pulled from listings'),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => form.status = v ?? 'active'),
                  ),
                ),
                FormFieldBlock(
                  label: 'Featured product',
                  child: Row(
                    children: [
                      Switch(
                        value: form.isFeatured,
                        onChanged: (v) => setState(() => form.isFeatured = v),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        form.isFeatured
                            ? 'Featured on home page'
                            : 'Not featured',
                        style: theme.textTheme.muted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        SectionCard(
          title: 'Review',
          subtitle: 'Confirm everything before publishing.',
          children: [
            _ReviewBlock(
              icon: LucideIcons.info,
              title: 'Identity',
              rows: [
                ('Name', form.name.text),
                ('Brand', form.brand.text),
                (
                  'Model',
                  [
                    form.modelName.text,
                    form.modelNumber.text,
                  ].where((s) => s.isNotEmpty).join(' / '),
                ),
                ('SKU', form.sku.text),
                ('Pack', '${form.unitCount} ${form.unitType}'),
              ],
            ),
            _ReviewBlock(
              icon: LucideIcons.indianRupee,
              title: 'Pricing',
              rows: [
                ('MRP', '₹${form.mrp.text}'),
                ('Selling', '₹${form.selling.text}'),
                ('GST', '${form.gst.text}%'),
                ('Stock', form.stock.text),
              ],
            ),
            _ReviewBlock(
              icon: LucideIcons.boxes,
              title: 'Specs',
              rows: [
                ('Color', form.color.text),
                ('Material', form.material.text),
                ('Weight', form.weight.text),
                ('Dimensions', form.dimensions.text),
                ('Origin', form.country.text),
              ],
            ),
            _ReviewBlock(
              icon: LucideIcons.shieldCheck,
              title: 'Warranty',
              rows: [
                ('Period', form.warrantyPeriod),
                ('Service', form.serviceType),
                ('Summary', form.warrantySummary.text),
              ],
            ),
            if (!form.images.isEmpty)
              _ReviewBlock(
                icon: LucideIcons.images,
                title: 'Images',
                rows: [
                  ('Total', '${form.images.length}'),
                  ('Primary', form.images.primary?.name ?? '-'),
                ],
              ),
          ],
        ),
      ],
    );
  }

  InputDecoration _decoration() => InputDecoration(
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  );
}

/// Internal helper used only by the review step. Kept inside this file
/// because no other screen needs it yet.
class _ReviewBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<(String, String)> rows;

  const _ReviewBlock({
    required this.icon,
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final filled = rows.where((r) => r.$2.trim().isNotEmpty).toList();
    if (filled.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppTheme.brand),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.small.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...filled.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      r.$1,
                      style: theme.textTheme.muted.copyWith(fontSize: 11),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      r.$2,
                      style: theme.textTheme.small.copyWith(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
