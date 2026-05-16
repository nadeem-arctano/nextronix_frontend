import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../provider/business_settings_provider.dart';
import '../widgets/responsive_field_grid.dart';
import '../widgets/section_scaffold.dart';
import '../widgets/settings_text_field.dart';

class InvoiceSectionScreen extends StatelessWidget {
  const InvoiceSectionScreen({super.key});

  static const String _section = SettingsSections.invoice;

  @override
  Widget build(BuildContext context) {
    return SectionScaffold(
      section: _section,
      title: 'Invoice Settings',
      subtitle: 'Customize invoice numbering and footer',
      icon: LucideIcons.fileText,
      iconColor: const Color(0xFF0F766E),
      builder: (context, p) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResponsiveFieldGrid(
            children: [
              SettingsTextField(
                label: 'Invoice Prefix',
                hint: 'INV-',
                icon: LucideIcons.hash,
                maxLength: 10,
                value: p.getValue(_section, 'invoicePrefix'),
                onChanged: (v) => p.setValue(_section, 'invoicePrefix', v),
              ),
              SettingsTextField(
                label: 'Start Number',
                hint: '1001',
                keyboardType: TextInputType.number,
                value: p.getValue(_section, 'invoiceStartNumber'),
                onChanged: (v) => p.setValue(_section, 'invoiceStartNumber', v),
              ),
              SettingsTextField(
                label: 'Default GST %',
                hint: '18',
                keyboardType: TextInputType.number,
                icon: LucideIcons.percent,
                value: p.getValue(_section, 'gstPercentage'),
                onChanged: (v) => p.setValue(_section, 'gstPercentage', v),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SettingsTextField(
            label: 'Invoice Footer',
            hint: 'Thank you for your business',
            maxLines: 2,
            value: p.getValue(_section, 'invoiceFooter'),
            onChanged: (v) => p.setValue(_section, 'invoiceFooter', v),
          ),
          const SizedBox(height: 14),
          SettingsTextField(
            label: 'Terms & Conditions',
            hint: 'Goods once sold cannot be returned...',
            maxLines: 4,
            value: p.getValue(_section, 'invoiceTerms'),
            onChanged: (v) => p.setValue(_section, 'invoiceTerms', v),
          ),
        ],
      ),
    );
  }
}
