import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';
import '../../../../widgets/forms/forms.dart';
import '../controller/add_product_form.dart';

/// Step 3: pricing & inventory. The discount preview rebuilds live as the
/// user types thanks to `setState` on every change.
class StepPricing extends StatefulWidget {
  final AddProductForm form;
  const StepPricing({super.key, required this.form});

  @override
  State<StepPricing> createState() => _StepPricingState();
}

class _StepPricingState extends State<StepPricing> {
  void _onPriceChanged(String _) => setState(() {});

  @override
  Widget build(BuildContext context) {
    final form = widget.form;
    return Form(
      key: form.pricingKey,
      child: Column(
        children: [
          SectionCard(
            title: 'Pricing',
            subtitle:
                'MRP is the printed price; selling price is what buyers '
                'actually pay.',
            children: [
              FormFieldGrid(
                children: [
                  FormFieldBlock(
                    label: 'MRP',
                    required: true,
                    child: ShadTextInput(
                      controller: form.mrp,
                      hint: '0.00',
                      prefix: '₹',
                      keyboardType: TextInputType.number,
                      onChanged: _onPriceChanged,
                      validator: Validators.combine([
                        Validators.required('MRP is required'),
                        Validators.number(min: 0),
                      ]),
                    ),
                  ),
                  FormFieldBlock(
                    label: 'Selling price',
                    required: true,
                    child: ShadTextInput(
                      controller: form.selling,
                      hint: '0.00',
                      prefix: '₹',
                      keyboardType: TextInputType.number,
                      onChanged: _onPriceChanged,
                      validator: Validators.combine([
                        Validators.required('Selling price is required'),
                        Validators.number(min: 0),
                      ]),
                    ),
                  ),
                  FormFieldBlock(
                    label: 'GST %',
                    child: ShadTextInput(
                      controller: form.gst,
                      hint: '18',
                      suffix: '%',
                      keyboardType: TextInputType.number,
                      validator: Validators.number(min: 0, max: 100),
                    ),
                  ),
                ],
              ),
              DiscountPreviewBanner(
                mrp: double.tryParse(form.mrp.text),
                selling: double.tryParse(form.selling.text),
              ),
            ],
          ),
          SectionCard(
            title: 'Inventory',
            subtitle: 'Set the starting stock and the alert threshold.',
            children: [
              FormFieldGrid(
                children: [
                  FormFieldBlock(
                    label: 'Stock quantity',
                    child: ShadTextInput(
                      controller: form.stock,
                      hint: '0',
                      keyboardType: TextInputType.number,
                      validator: Validators.integer(min: 0),
                    ),
                  ),
                  FormFieldBlock(
                    label: 'Low-stock alert',
                    hint: 'Notify when stock drops to or below this value.',
                    child: ShadTextInput(
                      controller: form.minStock,
                      hint: '5',
                      keyboardType: TextInputType.number,
                      validator: Validators.integer(min: 0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
