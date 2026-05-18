import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/validators.dart';
import '../../../../provider/category_provider.dart';
import '../../../../provider/product_provider.dart';
import '../../../../widgets/forms/forms.dart';
import '../controller/add_product_form.dart';

/// Step 1 of the Add Product wizard: identity, classification and
/// descriptions. Owns nothing — every field reads/writes the shared
/// `AddProductForm` instance.
class StepInfo extends StatefulWidget {
  final AddProductForm form;
  const StepInfo({super.key, required this.form});

  @override
  State<StepInfo> createState() => _StepInfoState();
}

class _StepInfoState extends State<StepInfo> {
  late final TextEditingController _packCountCtrl;

  @override
  void initState() {
    super.initState();
    _packCountCtrl = TextEditingController(
      text: widget.form.unitCount.toString(),
    );
  }

  @override
  void dispose() {
    _packCountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = widget.form;
    final categories = context.watch<CategoryProvider>().categories;
    final hsn = context.watch<ProductProvider>().hsnCodes;

    return Form(
      key: form.infoKey,
      child: Column(
        children: [
          SectionCard(
            title: 'Identity',
            subtitle: 'How buyers find this product',
            children: [
              FormFieldGrid(
                children: [
                  FormFieldBlock(
                    label: 'Product name',
                    required: true,
                    child: ShadTextInput(
                      controller: form.name,
                      hint: 'Cotton Casual T-Shirt',
                      validator: Validators.required('Name is required'),
                    ),
                  ),
                  FormFieldBlock(
                    label: 'Brand',
                    child: ShadTextInput(
                      controller: form.brand,
                      hint: 'Tronix',
                    ),
                  ),
                ],
              ),
              FormFieldGrid(
                children: [
                  FormFieldBlock(
                    label: 'Model name',
                    child: ShadTextInput(
                      controller: form.modelName,
                      hint: 'Aurora Lite',
                    ),
                  ),
                  FormFieldBlock(
                    label: 'Model number',
                    child: ShadTextInput(
                      controller: form.modelNumber,
                      hint: 'TR-12-RED',
                    ),
                  ),
                ],
              ),
              FormFieldGrid(
                children: [
                  FormFieldBlock(
                    label: 'SKU',
                    child: ShadTextInput(
                      controller: form.sku,
                      hint: 'TR-CST-RED-M',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? null
                          : Validators.sku()(v),
                    ),
                  ),
                  FormFieldBlock(
                    label: 'Barcode (UPC/EAN)',
                    child: ShadTextInput(
                      controller: form.barcode,
                      hint: '8901234567890',
                    ),
                  ),
                ],
              ),
            ],
          ),
          SectionCard(
            title: 'Classification',
            subtitle: 'Category controls where the product appears',
            children: [
              FormFieldGrid(
                children: [
                  FormFieldBlock(
                    label: 'Category',
                    required: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<int>(
                          initialValue: form.categoryId,
                          decoration: _decoration('Select category').copyWith(
                            errorText: form.getFieldError('categoryId'),
                          ),
                          items: categories
                              .map(
                                (c) => DropdownMenuItem<int>(
                                  value: c.id,
                                  child: Text(c.name ?? '-'),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            form.clearFieldError('categoryId');
                            setState(() => form.categoryId = v);
                          },
                        ),
                      ],
                    ),
                  ),
                  FormFieldBlock(
                    label: 'HSN code',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<int>(
                          initialValue: form.hsnId,
                          decoration: _decoration(
                            'Select HSN',
                          ).copyWith(errorText: form.getFieldError('hsnId')),
                          items: hsn
                              .map(
                                (h) => DropdownMenuItem<int>(
                                  value: h.id,
                                  child: Text(h.displayLabel),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            form.clearFieldError('hsnId');
                            setState(() => form.hsnId = v);
                            // Auto-fill GST from the picked HSN row.
                            final match = hsn
                                .where((h) => h.id == v)
                                .firstOrNull;
                            if (match != null && match.gstPercent != null) {
                              form.gst.text = match.gstPercent!.toStringAsFixed(
                                0,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              FormFieldGrid(
                children: [
                  FormFieldBlock(
                    label: 'Pack size',
                    child: Row(
                      children: [
                        SizedBox(
                          width: 90,
                          child: ShadTextInput(
                            controller: _packCountCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (v) {
                              final n = int.tryParse(v);
                              if (n != null) form.unitCount = n;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: form.unitType,
                            decoration: _decoration(),
                            items: const [
                              DropdownMenuItem(
                                value: 'piece',
                                child: Text('piece(s)'),
                              ),
                              DropdownMenuItem(
                                value: 'pack',
                                child: Text('pack(s)'),
                              ),
                              DropdownMenuItem(
                                value: 'set',
                                child: Text('set(s)'),
                              ),
                              DropdownMenuItem(
                                value: 'pair',
                                child: Text('pair(s)'),
                              ),
                              DropdownMenuItem(
                                value: 'box',
                                child: Text('box(es)'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => form.unitType = v ?? 'piece'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FormFieldBlock(
                    label: 'Tags',
                    hint: 'Comma separated keywords',
                    child: ShadTextInput(
                      controller: form.tags,
                      hint: 'casual, summer, cotton',
                    ),
                  ),
                ],
              ),
            ],
          ),
          SectionCard(
            title: 'Description',
            subtitle: 'Sell your product in a few sentences',
            children: [
              FormFieldBlock(
                label: 'Short description',
                hint: 'One-line summary buyers see in search and quick views.',
                child: ShadTextInput(
                  controller: form.shortDesc,
                  hint: 'Soft cotton round-neck tee with reinforced stitching',
                  maxLines: 2,
                ),
              ),
              FormFieldBlock(
                label: 'Highlights',
                hint:
                    'Key bullet points (one per line). Shows in product header.',
                child: ShadTextInput(
                  controller: form.highlights,
                  hint:
                      '• Premium combed cotton\n• Fade-resistant dye\n• Pre-shrunk',
                  maxLines: 4,
                ),
              ),
              FormFieldBlock(
                label: 'Full description',
                child: ShadTextInput(
                  controller: form.fullDesc,
                  hint: 'Tell the full story of the product...',
                  maxLines: 6,
                ),
              ),
              FormFieldBlock(
                label: "What's in the box",
                hint:
                    "Comma separated. Helps avoid buyer disappointment after delivery.",
                child: ShadTextInput(
                  controller: form.whatsInBox,
                  hint: '1× T-Shirt, 1× Care card',
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration([String? hint]) => InputDecoration(
    hintText: hint,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  );
}
