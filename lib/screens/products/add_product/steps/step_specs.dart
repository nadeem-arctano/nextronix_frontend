import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../provider/color_master_provider.dart';
import '../../../../provider/material_master_provider.dart';
import '../../../../widgets/forms/forms.dart';
import '../controller/add_product_form.dart';

/// Step 4: physical attributes + Indian e-commerce compliance fields.
class StepSpecs extends StatefulWidget {
  final AddProductForm form;
  const StepSpecs({super.key, required this.form});

  @override
  State<StepSpecs> createState() => _StepSpecsState();
}

class _StepSpecsState extends State<StepSpecs> {
  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = widget.form;
    final colors = context.watch<ColorMasterProvider>().colors;
    final materials = context.watch<MaterialMasterProvider>().materials;

    return Column(
      children: [
        SectionCard(
          title: 'Physical attributes',
          subtitle: 'Help buyers picture the item before purchase.',
          children: [
            FormFieldGrid(
              children: [
                FormFieldBlock(
                  label: 'Color',
                  child: DropdownButtonFormField<int>(
                    initialValue: form.colorId,
                    decoration: _decoration(
                      'Select color',
                    ).copyWith(errorText: form.getFieldError('colorId')),
                    items: colors
                        .map(
                          (c) => DropdownMenuItem<int>(
                            value: c.id,
                            child: Text(c.name ?? '-'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      form.clearFieldError('colorId');
                      setState(() => form.colorId = v);
                    },
                  ),
                ),
                FormFieldBlock(
                  label: 'Material',
                  child: DropdownButtonFormField<int>(
                    initialValue: form.materialTypeId,
                    decoration: _decoration(
                      'Select material',
                    ).copyWith(errorText: form.getFieldError('materialTypeId')),
                    items: materials
                        .map(
                          (m) => DropdownMenuItem<int>(
                            value: m.id,
                            child: Text(m.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      form.clearFieldError('materialTypeId');
                      setState(() => form.materialTypeId = v);
                    },
                  ),
                ),
              ],
            ),
            FormFieldGrid(
              children: [
                FormFieldBlock(
                  label: 'Weight',
                  hint: 'Used for shipping rate calculation.',
                  child: ShadTextInput(controller: form.weight, hint: '250g'),
                ),
                FormFieldBlock(
                  label: 'Dimensions',
                  child: ShadTextInput(
                    controller: form.dimensions,
                    hint: 'L 30 × W 20 × H 5 cm',
                  ),
                ),
              ],
            ),
          ],
        ),
        SectionCard(
          title: 'Compliance',
          subtitle: 'Required by Indian e-commerce regulations.',
          children: [
            FormFieldGrid(
              children: [
                FormFieldBlock(
                  label: 'Country of origin',
                  required: true,
                  child: ShadTextInput(controller: form.country, hint: 'India'),
                ),
                FormFieldBlock(
                  label: 'Manufacturer',
                  child: ShadTextInput(
                    controller: form.manufacturer,
                    hint: 'Tronix Manufacturing Pvt Ltd',
                  ),
                ),
              ],
            ),
            FormFieldGrid(
              children: [
                FormFieldBlock(
                  label: 'Importer',
                  hint: 'For imported goods only.',
                  child: ShadTextInput(
                    controller: form.importer,
                    hint: 'Optional',
                  ),
                ),
                FormFieldBlock(
                  label: 'Packer',
                  child: ShadTextInput(
                    controller: form.packer,
                    hint: 'Optional',
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
