import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../provider/business_settings_provider.dart';
import '../widgets/responsive_field_grid.dart';
import '../widgets/section_scaffold.dart';
import '../widgets/settings_text_field.dart';

class ContactSectionScreen extends StatelessWidget {
  const ContactSectionScreen({super.key});

  static const String _section = SettingsSections.contact;

  @override
  Widget build(BuildContext context) {
    return SectionScaffold(
      section: _section,
      title: 'Contact Information',
      subtitle: 'Public contact channels for customers',
      icon: LucideIcons.phone,
      iconColor: const Color(0xFF059669),
      builder: (context, p) => ResponsiveFieldGrid(
        children: [
          SettingsTextField(
            label: 'Business Email',
            hint: 'business@company.com',
            icon: LucideIcons.mail,
            keyboardType: TextInputType.emailAddress,
            value: p.getValue(_section, 'businessEmail'),
            onChanged: (v) => p.setValue(_section, 'businessEmail', v),
          ),
          SettingsTextField(
            label: 'Support Email',
            hint: 'support@company.com',
            icon: LucideIcons.lifeBuoy,
            keyboardType: TextInputType.emailAddress,
            value: p.getValue(_section, 'supportEmail'),
            onChanged: (v) => p.setValue(_section, 'supportEmail', v),
          ),
          SettingsTextField(
            label: 'Business Phone',
            hint: '+91 9999999999',
            icon: LucideIcons.phone,
            keyboardType: TextInputType.phone,
            value: p.getValue(_section, 'businessPhone'),
            onChanged: (v) => p.setValue(_section, 'businessPhone', v),
          ),
          SettingsTextField(
            label: 'Support Phone',
            hint: '+91 1800-XXX-XXXX',
            icon: LucideIcons.headphones,
            keyboardType: TextInputType.phone,
            value: p.getValue(_section, 'supportPhone'),
            onChanged: (v) => p.setValue(_section, 'supportPhone', v),
          ),
        ],
      ),
    );
  }
}
