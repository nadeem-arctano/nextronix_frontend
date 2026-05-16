import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../provider/business_settings_provider.dart';
import '../widgets/responsive_field_grid.dart';
import '../widgets/secure_text_field.dart';
import '../widgets/section_scaffold.dart';
import '../widgets/settings_text_field.dart';

class PaymentSectionScreen extends StatelessWidget {
  const PaymentSectionScreen({super.key});

  static const String _section = SettingsSections.payment;

  @override
  Widget build(BuildContext context) {
    return SectionScaffold(
      section: _section,
      title: 'Payment Gateway',
      subtitle: 'API credentials for online payment providers',
      icon: LucideIcons.creditCard,
      iconColor: const Color(0xFFDC2626),
      builder: (context, p) {
        final data = p.sectionData(_section);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsTextField(
              label: 'UPI ID',
              hint: 'business@bank',
              icon: LucideIcons.smartphone,
              value: p.getValue(_section, 'upiId'),
              onChanged: (v) => p.setValue(_section, 'upiId', v),
            ),
            const SizedBox(height: 14),
            ResponsiveFieldGrid(
              children: [
                SettingsTextField(
                  label: 'Razorpay Key ID',
                  hint: 'rzp_live_xxxxxxxxxx',
                  icon: LucideIcons.key,
                  value: p.getValue(_section, 'razorpayKey'),
                  onChanged: (v) => p.setValue(_section, 'razorpayKey', v),
                ),
                SecureTextField(
                  label: 'Razorpay Secret',
                  icon: LucideIcons.lock,
                  isSet: data?.razorpaySecretSet ?? false,
                  maskedValue: data?.razorpaySecretMasked,
                  onChanged: (v) => p.setValue(_section, 'razorpaySecret', v),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ResponsiveFieldGrid(
              children: [
                SettingsTextField(
                  label: 'Stripe Public Key',
                  hint: 'pk_live_xxxxxxxxxx',
                  icon: LucideIcons.key,
                  value: p.getValue(_section, 'stripePublicKey'),
                  onChanged: (v) => p.setValue(_section, 'stripePublicKey', v),
                ),
                SecureTextField(
                  label: 'Stripe Secret Key',
                  icon: LucideIcons.lock,
                  isSet: data?.stripeSecretKeySet ?? false,
                  maskedValue: data?.stripeSecretKeyMasked,
                  onChanged: (v) => p.setValue(_section, 'stripeSecretKey', v),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
