import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../provider/business_settings_provider.dart';
import '../widgets/responsive_field_grid.dart';
import '../widgets/secure_text_field.dart';
import '../widgets/section_scaffold.dart';
import '../widgets/settings_text_field.dart';

class BankSectionScreen extends StatelessWidget {
  const BankSectionScreen({super.key});

  static const String _section = SettingsSections.bank;

  @override
  Widget build(BuildContext context) {
    return SectionScaffold(
      section: _section,
      title: 'Bank Details',
      subtitle: 'Account information for settlements',
      icon: LucideIcons.landmark,
      iconColor: const Color(0xFF0891B2),
      builder: (context, p) {
        final data = p.sectionData(_section);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ResponsiveFieldGrid(
              children: [
                SettingsTextField(
                  label: 'Account Holder Name',
                  icon: LucideIcons.user,
                  value: p.getValue(_section, 'accountHolderName'),
                  onChanged: (v) =>
                      p.setValue(_section, 'accountHolderName', v),
                ),
                SettingsTextField(
                  label: 'Bank Name',
                  icon: LucideIcons.building,
                  value: p.getValue(_section, 'bankName'),
                  onChanged: (v) => p.setValue(_section, 'bankName', v),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ResponsiveFieldGrid(
              children: [
                SecureTextField(
                  label: 'Account Number',
                  icon: LucideIcons.creditCard,
                  isSet: data?.accountNumberSet ?? false,
                  maskedValue: data?.accountNumberMasked,
                  onChanged: (v) => p.setValue(_section, 'accountNumber', v),
                ),
                SettingsTextField(
                  label: 'IFSC Code',
                  hint: 'HDFC0000001',
                  icon: LucideIcons.hash,
                  maxLength: 11,
                  value: p.getValue(_section, 'ifscCode'),
                  onChanged: (v) =>
                      p.setValue(_section, 'ifscCode', v.toUpperCase()),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SettingsTextField(
              label: 'Branch Name',
              icon: LucideIcons.mapPin,
              value: p.getValue(_section, 'branchName'),
              onChanged: (v) => p.setValue(_section, 'branchName', v),
            ),
          ],
        );
      },
    );
  }
}
