import 'package:flutter/material.dart';

import '../../../../widgets/forms/forms.dart';
import '../controller/add_product_form.dart';

/// Step 4: physical attributes + Indian e-commerce compliance fields.
class StepSpecs extends StatelessWidget {
  final AddProductForm form;
  const StepSpecs({super.key, required this.form});

  @override
  Widget build(BuildContext context) {
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
                  child: ShadTextInput(
                    controller: form.color,
                    hint: 'Crimson red',
                  ),
                ),
                FormFieldBlock(
                  label: 'Material',
                  child: ShadTextInput(
                    controller: form.material,
                    hint: '100% combed cotton',
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
