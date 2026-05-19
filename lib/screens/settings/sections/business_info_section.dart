import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../provider/business_settings_provider.dart';
import '../widgets/responsive_field_grid.dart';
import '../widgets/section_scaffold.dart';
import '../widgets/settings_text_field.dart';

class BusinessInfoSectionScreen extends StatelessWidget {
  const BusinessInfoSectionScreen({super.key});

  static const String _section = SettingsSections.businessInfo;

  @override
  Widget build(BuildContext context) {
    return SectionScaffold(
      section: _section,
      title: 'Business Information',
      subtitle: 'Legal entity, GST and tax identifiers',
      icon: LucideIcons.building2,
      iconColor: const Color(0xFF4F46E5),
      builder: (context, p) => ResponsiveFieldGrid(
        children: [
          SettingsTextField(
            label: 'Business Name',
            isRequired: true,
            icon: LucideIcons.store,
            value: p.getValue(_section, 'businessName'),
            onChanged: (v) => p.setValue(_section, 'businessName', v),
          ),
          SettingsTextField(
            label: 'Legal Business Name',
            icon: LucideIcons.fileText,
            value: p.getValue(_section, 'legalBusinessName'),
            onChanged: (v) => p.setValue(_section, 'legalBusinessName', v),
          ),
          SettingsTextField(
            label: 'GST Number',
            hint: '22AAAAA0000A1Z5',
            icon: LucideIcons.receipt,
            maxLength: 15,
            value: p.getValue(_section, 'gstNumber'),
            onChanged: (v) =>
                p.setValue(_section, 'gstNumber', v.toUpperCase()),
          ),
          SettingsTextField(
            label: 'PAN Number',
            hint: 'AAAAA0000A',
            icon: LucideIcons.badge,
            maxLength: 10,
            value: p.getValue(_section, 'panNumber'),
            onChanged: (v) =>
                p.setValue(_section, 'panNumber', v.toUpperCase()),
          ),
        ],
      ),
    );
  }
}
