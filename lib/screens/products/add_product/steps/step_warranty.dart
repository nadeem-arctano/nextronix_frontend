import 'package:flutter/material.dart';

import '../../../../widgets/forms/forms.dart';
import '../controller/add_product_form.dart';

/// Step 5: warranty details. Mirrors what buyers see on Amazon/Flipkart
/// product pages — period, service type, summary, and what is or isn't
/// covered.
class StepWarranty extends StatefulWidget {
  final AddProductForm form;
  const StepWarranty({super.key, required this.form});

  @override
  State<StepWarranty> createState() => _StepWarrantyState();
}

class _StepWarrantyState extends State<StepWarranty> {
  @override
  Widget build(BuildContext context) {
    final form = widget.form;
    return SectionCard(
      title: 'Warranty information',
      subtitle: 'Mirrors the warranty section buyers see on Amazon / Flipkart.',
      children: [
        FormFieldGrid(
          children: [
            FormFieldBlock(
              label: 'Warranty period',
              child: DropdownButtonFormField<String>(
                initialValue: form.warrantyPeriod,
                decoration: _decoration(),
                items: const [
                  DropdownMenuItem(
                    value: 'no_warranty',
                    child: Text('No warranty'),
                  ),
                  DropdownMenuItem(value: '6 months', child: Text('6 months')),
                  DropdownMenuItem(value: '1 year', child: Text('1 year')),
                  DropdownMenuItem(value: '2 years', child: Text('2 years')),
                  DropdownMenuItem(value: '3 years', child: Text('3 years')),
                  DropdownMenuItem(value: 'lifetime', child: Text('Lifetime')),
                ],
                onChanged: (v) =>
                    setState(() => form.warrantyPeriod = v ?? '1 year'),
              ),
            ),
            FormFieldBlock(
              label: 'Service type',
              child: DropdownButtonFormField<String>(
                initialValue: form.serviceType,
                decoration: _decoration(),
                items: const [
                  DropdownMenuItem(
                    value: 'manufacturer',
                    child: Text('Manufacturer warranty'),
                  ),
                  DropdownMenuItem(
                    value: 'seller',
                    child: Text('Should contact seller'),
                  ),
                  DropdownMenuItem(
                    value: 'service_centre',
                    child: Text('Authorised service centre'),
                  ),
                  DropdownMenuItem(value: 'none', child: Text('No service')),
                ],
                onChanged: (v) =>
                    setState(() => form.serviceType = v ?? 'manufacturer'),
              ),
            ),
          ],
        ),
        FormFieldBlock(
          label: 'Warranty summary',
          hint: 'Short paragraph buyers see at a glance.',
          child: ShadTextInput(
            controller: form.warrantySummary,
            hint: '1 year manufacturer warranty against defects',
            maxLines: 2,
          ),
        ),
        FormFieldBlock(
          label: 'Covered in warranty',
          child: ShadTextInput(
            controller: form.covered,
            hint: 'Manufacturing defects, technical issues',
            maxLines: 2,
          ),
        ),
        FormFieldBlock(
          label: 'Not covered in warranty',
          child: ShadTextInput(
            controller: form.notCovered,
            hint: 'Physical damage, water damage, unauthorised repair',
            maxLines: 2,
          ),
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
