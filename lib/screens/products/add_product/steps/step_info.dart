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
                ],
              ),
              FormFieldGrid(
                children: [
                  FormFieldBlock(
                    label: 'Model name',
                    required: true,
                    child: ShadTextInput(
                      controller: form.modelName,
                      hint: 'Aurora Lite',
                      validator: Validators.required('Model name is required'),
                    ),
                  ),
                  FormFieldBlock(
                    label: 'Model number',
                    required: true,
                    child: ShadTextInput(
                      controller: form.modelNumber,
                      hint: 'TR-12-RED',
                      validator: Validators.required(
                        'Model number is required',
                      ),
                    ),
                  ),
                ],
              ),
              FormFieldGrid(
                children: [
                  FormFieldBlock(
                    label: 'SKU',
                    required: true,
                    child: ShadTextInput(
                      controller: form.sku,
                      hint: 'TR-CST-RED-M',
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'SKU is required';
                        }
                        return Validators.sku()(v);
                      },
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
                          validator: (v) =>
                              v == null ? 'Category is required' : null,
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
                    required: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          initialValue: form.hsnId,
                          decoration: _decoration(
                            'Select HSN',
                          ).copyWith(errorText: form.getFieldError('hsnId')),
                          validator: (v) =>
                              v == null ? 'HSN code is required' : null,
                          items: hsn
                              .map(
                                (h) => DropdownMenuItem<int>(
                                  value: h.id,
                                  child: Text(
                                    h.displayLabel,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
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
                    required: true,
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
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Required';
                              }
                              final n = int.tryParse(v);
                              if (n == null || n <= 0) {
                                return 'Must be > 0';
                              }
                              return null;
                            },
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
                label: 'Description',
                required: true,
                child: ShadTextInput(
                  controller: form.fullDesc,
                  hint: 'Tell the full story of the product...',
                  maxLines: 6,
                  validator: Validators.required('Description is required'),
                ),
              ),
              FormFieldBlock(
                label: 'Highlights',
                required: true,
                hint: 'Key bullet . Up to 6. Shows in product header.',
                child: _HighlightsField(form: form),
              ),
              FormFieldBlock(
                label: "What's in the box",
                required: true,
                hint:
                    "Comma separated. Helps avoid buyer disappointment after delivery.",
                child: ShadTextInput(
                  controller: form.whatsInBox,
                  hint: '1× T-Shirt, 1× Care card',
                  maxLines: 2,
                  validator: Validators.required(
                    "What's in the box is required",
                  ),
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

/// Dynamic highlights field — starts with 1 input, "+ Add more" button
/// adds another up to a maximum of 6. Each row (after the first) has a
/// remove (×) button. The 6th row hides the add button.
class _HighlightsField extends StatefulWidget {
  final AddProductForm form;
  const _HighlightsField({required this.form});

  @override
  State<_HighlightsField> createState() => _HighlightsFieldState();
}

class _HighlightsFieldState extends State<_HighlightsField> {
  static const int _maxHighlights = 6;

  void _addField() {
    if (widget.form.highlights.length >= _maxHighlights) return;
    setState(() {
      widget.form.highlights.add(TextEditingController());
    });
  }

  void _removeField(int index) {
    if (widget.form.highlights.length <= 1) return;
    setState(() {
      final removed = widget.form.highlights.removeAt(index);
      removed.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final highlights = widget.form.highlights;
    final canAddMore = highlights.length < _maxHighlights;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(highlights.length, (index) {
          final isFirst = index == 0;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == highlights.length - 1 ? 0 : 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: ShadTextInput(
                    controller: highlights[index],
                    hint: 'Highlight ${index + 1}',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Highlight ${index + 1} is required'
                        : null,
                  ),
                ),
                if (!isFirst) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    tooltip: 'Remove',
                    onPressed: () => _removeField(index),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
          );
        }),
        if (canAddMore) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _addField,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add more'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
