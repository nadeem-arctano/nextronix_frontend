import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../provider/business_settings_provider.dart';
import '../widgets/responsive_field_grid.dart';
import '../widgets/section_scaffold.dart';
import '../widgets/settings_text_field.dart';

class AddressSectionScreen extends StatelessWidget {
  const AddressSectionScreen({super.key});

  static const String _section = SettingsSections.address;

  @override
  Widget build(BuildContext context) {
    return SectionScaffold(
      section: _section,
      title: 'Business Address',
      subtitle: 'Registered address for invoices and shipping',
      icon: LucideIcons.mapPin,
      iconColor: const Color(0xFFD97706),
      builder: (context, p) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsTextField(
            label: 'Address Line 1',
            value: p.getValue(_section, 'addressLine1'),
            onChanged: (v) => p.setValue(_section, 'addressLine1', v),
          ),
          const SizedBox(height: 14),
          SettingsTextField(
            label: 'Address Line 2',
            value: p.getValue(_section, 'addressLine2'),
            onChanged: (v) => p.setValue(_section, 'addressLine2', v),
          ),
          const SizedBox(height: 14),
          ResponsiveFieldGrid(
            children: [
              SettingsTextField(
                label: 'City',
                value: p.getValue(_section, 'city'),
                onChanged: (v) => p.setValue(_section, 'city', v),
              ),
              SettingsTextField(
                label: 'State',
                value: p.getValue(_section, 'state'),
                onChanged: (v) => p.setValue(_section, 'state', v),
              ),
              SettingsTextField(
                label: 'Country',
                value: p.getValue(_section, 'country'),
                onChanged: (v) => p.setValue(_section, 'country', v),
              ),
              SettingsTextField(
                label: 'Pincode',
                keyboardType: TextInputType.number,
                maxLength: 10,
                value: p.getValue(_section, 'pincode'),
                onChanged: (v) => p.setValue(_section, 'pincode', v),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
