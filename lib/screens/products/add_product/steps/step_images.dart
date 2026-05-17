import 'package:flutter/material.dart';

import '../../../../widgets/forms/forms.dart';
import '../../../../widgets/images/image_picker_panel.dart';
import '../controller/add_product_form.dart';

/// Step 2 of the Add Product wizard: cover image + gallery.
///
/// All the heavy lifting (picking, reorder, primary marker) lives in the
/// reusable `ImagePickerPanel` so other screens (Edit Product, Variant
/// dialog) can adopt the same UX with one line.
class StepImages extends StatelessWidget {
  final AddProductForm form;
  const StepImages({super.key, required this.form});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Product images',
      subtitle:
          'Add up to 8 images. The first image becomes the cover photo. Drag '
          'a thumbnail to reorder, click ⭐ to make it primary.',
      children: [ImagePickerPanel(controller: form.images)],
    );
  }
}
