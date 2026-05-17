import 'package:flutter/material.dart';

import '../../../../widgets/images/image_picker_panel.dart';

/// Single source of truth for the Add Product wizard.
///
/// Owns every controller, every dropdown selection, and the image picker
/// state so step widgets stay dumb and presentational. Disposed by the
/// parent screen on tear-down.
class AddProductForm {
  // ─── Step keys (per-step validation) ──────────────────────────────────────
  final infoKey = GlobalKey<FormState>();
  final pricingKey = GlobalKey<FormState>();

  // ─── Step 1: Identity / classification / description ──────────────────────
  final name = TextEditingController();
  final brand = TextEditingController();
  final modelName = TextEditingController();
  final modelNumber = TextEditingController();
  final sku = TextEditingController();
  final barcode = TextEditingController();
  final shortDesc = TextEditingController();
  final fullDesc = TextEditingController();
  final whatsInBox = TextEditingController();
  final highlights = TextEditingController();
  final tags = TextEditingController();
  int? categoryId;
  int? hsnId;
  int unitCount = 1;
  String unitType = 'piece';

  // ─── Step 2: Images (delegated to a controller) ───────────────────────────
  final images = ImagePickerController();

  // ─── Step 3: Pricing & inventory ──────────────────────────────────────────
  final mrp = TextEditingController();
  final selling = TextEditingController();
  final gst = TextEditingController(text: '18');
  final stock = TextEditingController(text: '0');
  final minStock = TextEditingController(text: '5');

  // ─── Step 4: Specs / compliance ───────────────────────────────────────────
  final color = TextEditingController();
  final material = TextEditingController();
  final weight = TextEditingController();
  final dimensions = TextEditingController();
  final country = TextEditingController(text: 'India');
  final manufacturer = TextEditingController();
  final importer = TextEditingController();
  final packer = TextEditingController();

  // ─── Step 5: Warranty ─────────────────────────────────────────────────────
  final warrantySummary = TextEditingController();
  final covered = TextEditingController();
  final notCovered = TextEditingController();
  String serviceType = 'manufacturer';
  String warrantyPeriod = '1 year';

  // ─── Step 6: Listing settings ─────────────────────────────────────────────
  String status = 'active';
  bool isFeatured = false;

  /// Returns the value buyers'd see as a discount percentage. Used by the
  /// review block + the live banner under the price fields.
  double? get discountPercent {
    final m = double.tryParse(mrp.text);
    final s = double.tryParse(selling.text);
    if (m == null || s == null || m <= 0 || s <= 0 || s > m) return null;
    return (m - s) / m * 100;
  }

  /// Cleans up every controller. Call from the parent screen's `dispose`.
  void dispose() {
    for (final c in [
      name,
      brand,
      modelName,
      modelNumber,
      sku,
      barcode,
      shortDesc,
      fullDesc,
      whatsInBox,
      highlights,
      tags,
      mrp,
      selling,
      gst,
      stock,
      minStock,
      color,
      material,
      weight,
      dimensions,
      country,
      manufacturer,
      importer,
      packer,
      warrantySummary,
      covered,
      notCovered,
    ]) {
      c.dispose();
    }
    images.dispose();
  }

  /// Stitches the Amazon-style metadata that doesn't yet have its own
  /// backend column into the legacy `warranty` field. Backend stores it
  /// as-is and the storefront can split it back out for rendering.
  String buildWarrantyBlob() {
    final parts = <String>[
      if (warrantyPeriod.isNotEmpty) 'Period: $warrantyPeriod',
      if (warrantySummary.text.trim().isNotEmpty)
        'Summary: ${warrantySummary.text.trim()}',
      if (covered.text.trim().isNotEmpty) 'Covered: ${covered.text.trim()}',
      if (notCovered.text.trim().isNotEmpty)
        'Not covered: ${notCovered.text.trim()}',
      'Service: $serviceType',
    ];
    return parts.join(' | ');
  }

  /// Appends extras that don't yet have backend columns to the user's
  /// full description so nothing they typed gets lost.
  String buildFullDescription() {
    final extras = <String>[
      if (modelName.text.trim().isNotEmpty)
        'Model name: ${modelName.text.trim()}',
      if (modelNumber.text.trim().isNotEmpty)
        'Model number: ${modelNumber.text.trim()}',
      if (unitCount > 0) 'Pack: $unitCount $unitType',
      if (whatsInBox.text.trim().isNotEmpty)
        'In the box: ${whatsInBox.text.trim()}',
      if (highlights.text.trim().isNotEmpty)
        'Highlights: ${highlights.text.trim()}',
      if (country.text.trim().isNotEmpty)
        'Country of origin: ${country.text.trim()}',
      if (manufacturer.text.trim().isNotEmpty)
        'Manufacturer: ${manufacturer.text.trim()}',
      if (importer.text.trim().isNotEmpty) 'Importer: ${importer.text.trim()}',
      if (packer.text.trim().isNotEmpty) 'Packer: ${packer.text.trim()}',
    ];
    final tail = extras.join('\n');
    return [
      fullDesc.text.trim(),
      if (tail.isNotEmpty) tail,
    ].where((s) => s.isNotEmpty).join('\n\n');
  }
}

/// Each step in the wizard. Order here matches the visual order at the top
/// of the page.
enum AddProductStep { info, images, pricing, specs, warranty, review }

extension AddProductStepX on AddProductStep {
  String get title {
    switch (this) {
      case AddProductStep.info:
        return 'Product info';
      case AddProductStep.images:
        return 'Images';
      case AddProductStep.pricing:
        return 'Pricing & stock';
      case AddProductStep.specs:
        return 'Specifications';
      case AddProductStep.warranty:
        return 'Warranty';
      case AddProductStep.review:
        return 'Review & publish';
    }
  }

  String get subtitle {
    switch (this) {
      case AddProductStep.info:
        return 'Name, category, descriptions';
      case AddProductStep.images:
        return 'Cover photo + gallery';
      case AddProductStep.pricing:
        return 'Price, GST, inventory';
      case AddProductStep.specs:
        return 'Material, weight, origin';
      case AddProductStep.warranty:
        return 'Coverage and service';
      case AddProductStep.review:
        return 'Final check';
    }
  }
}
