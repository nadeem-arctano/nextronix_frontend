import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../provider/business_settings_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/page_header.dart';
import 'widgets/logo_uploader.dart';
import 'widgets/secure_text_field.dart';
import 'widgets/settings_card.dart';
import 'widgets/settings_text_field.dart';

class BusinessSettingsScreen extends StatefulWidget {
  const BusinessSettingsScreen({super.key});

  @override
  State<BusinessSettingsScreen> createState() => _BusinessSettingsScreenState();
}

class _BusinessSettingsScreenState extends State<BusinessSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessSettingsProvider>().loadSettings();
    });
  }

  Future<void> _save() async {
    final provider = context.read<BusinessSettingsProvider>();
    final err = await provider.saveSettings();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          err == null ? 'Settings saved successfully' : err.alertMessage,
        ),
        backgroundColor: err == null
            ? AppTheme.successColor
            : AppTheme.dangerColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BusinessSettingsProvider>(
      builder: (context, provider, _) {
        return Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 90),
              child: provider.isLoading && provider.settings == null
                  ? const LoadingWidget(message: 'Loading settings...')
                  : provider.error != null && provider.settings == null
                  ? ErrorWidget2(
                      message: provider.error!,
                      onRetry: () => provider.loadSettings(),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PageHeader(
                          title: 'Business Settings',
                          subtitle:
                              'Configure business info, payments, invoices, and branding',
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: SingleChildScrollView(
                            child: _buildSections(provider),
                          ),
                        ),
                      ],
                    ),
            ),

            // Sticky save bar
            if (provider.hasUnsavedChanges)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _StickySaveBar(
                  isSaving: provider.isSaving,
                  onSave: _save,
                  onDiscard: provider.resetChanges,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSections(BusinessSettingsProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBusinessInfo(provider, isWide),
            const SizedBox(height: 16),
            _buildContactInfo(provider, isWide),
            const SizedBox(height: 16),
            _buildAddress(provider, isWide),
            const SizedBox(height: 16),
            _buildBranding(provider),
            const SizedBox(height: 16),
            _buildBankDetails(provider, isWide),
            const SizedBox(height: 16),
            _buildPaymentGateway(provider, isWide),
            const SizedBox(height: 16),
            _buildInvoiceSettings(provider, isWide),
            const SizedBox(height: 16),
            _buildSocialLinks(provider, isWide),
          ],
        );
      },
    );
  }

  // ─── Section 1: Business Information ────────────────────────────────────────
  Widget _buildBusinessInfo(BusinessSettingsProvider p, bool wide) {
    return SettingsCard(
      title: 'Business Information',
      description: 'Legal entity, GST and tax identifiers',
      icon: LucideIcons.building2,
      color: const Color(0xFF4F46E5),
      child: _grid(wide, [
        SettingsTextField(
          label: 'Business Name',
          isRequired: true,
          icon: LucideIcons.store,
          value: p.getValue('businessName'),
          onChanged: (v) => p.setValue('businessName', v),
        ),
        SettingsTextField(
          label: 'Legal Business Name',
          icon: LucideIcons.fileText,
          value: p.getValue('legalBusinessName'),
          onChanged: (v) => p.setValue('legalBusinessName', v),
        ),
        SettingsTextField(
          label: 'GST Number',
          hint: '22AAAAA0000A1Z5',
          icon: LucideIcons.receipt,
          value: p.getValue('gstNumber'),
          onChanged: (v) => p.setValue('gstNumber', v.toUpperCase()),
          maxLength: 15,
        ),
        SettingsTextField(
          label: 'PAN Number',
          hint: 'AAAAA0000A',
          icon: LucideIcons.badge,
          value: p.getValue('panNumber'),
          onChanged: (v) => p.setValue('panNumber', v.toUpperCase()),
          maxLength: 10,
        ),
        SettingsTextField(
          label: 'Website URL',
          hint: 'https://example.com',
          icon: LucideIcons.globe,
          value: p.getValue('websiteUrl'),
          onChanged: (v) => p.setValue('websiteUrl', v),
        ),
      ]),
    );
  }

  // ─── Section 2: Contact ─────────────────────────────────────────────────────
  Widget _buildContactInfo(BusinessSettingsProvider p, bool wide) {
    return SettingsCard(
      title: 'Contact Information',
      description: 'Public contact channels for customers',
      icon: LucideIcons.phone,
      color: const Color(0xFF059669),
      child: _grid(wide, [
        SettingsTextField(
          label: 'Business Email',
          hint: 'business@company.com',
          icon: LucideIcons.mail,
          keyboardType: TextInputType.emailAddress,
          value: p.getValue('businessEmail'),
          onChanged: (v) => p.setValue('businessEmail', v),
        ),
        SettingsTextField(
          label: 'Support Email',
          hint: 'support@company.com',
          icon: LucideIcons.lifeBuoy,
          keyboardType: TextInputType.emailAddress,
          value: p.getValue('supportEmail'),
          onChanged: (v) => p.setValue('supportEmail', v),
        ),
        SettingsTextField(
          label: 'Business Phone',
          hint: '+91 9999999999',
          icon: LucideIcons.phone,
          keyboardType: TextInputType.phone,
          value: p.getValue('businessPhone'),
          onChanged: (v) => p.setValue('businessPhone', v),
        ),
        SettingsTextField(
          label: 'Support Phone',
          hint: '+91 1800-XXX-XXXX',
          icon: LucideIcons.headphones,
          keyboardType: TextInputType.phone,
          value: p.getValue('supportPhone'),
          onChanged: (v) => p.setValue('supportPhone', v),
        ),
      ]),
    );
  }

  // ─── Section 3: Address ─────────────────────────────────────────────────────
  Widget _buildAddress(BusinessSettingsProvider p, bool wide) {
    return SettingsCard(
      title: 'Business Address',
      description: 'Registered address for invoices and shipping',
      icon: LucideIcons.mapPin,
      color: const Color(0xFFD97706),
      child: Column(
        children: [
          SettingsTextField(
            label: 'Address Line 1',
            value: p.getValue('addressLine1'),
            onChanged: (v) => p.setValue('addressLine1', v),
          ),
          const SizedBox(height: 14),
          SettingsTextField(
            label: 'Address Line 2',
            value: p.getValue('addressLine2'),
            onChanged: (v) => p.setValue('addressLine2', v),
          ),
          const SizedBox(height: 14),
          _grid(wide, [
            SettingsTextField(
              label: 'City',
              value: p.getValue('city'),
              onChanged: (v) => p.setValue('city', v),
            ),
            SettingsTextField(
              label: 'State',
              value: p.getValue('state'),
              onChanged: (v) => p.setValue('state', v),
            ),
            SettingsTextField(
              label: 'Country',
              value: p.getValue('country'),
              onChanged: (v) => p.setValue('country', v),
            ),
            SettingsTextField(
              label: 'Pincode',
              keyboardType: TextInputType.number,
              maxLength: 10,
              value: p.getValue('pincode'),
              onChanged: (v) => p.setValue('pincode', v),
            ),
          ]),
        ],
      ),
    );
  }

  // ─── Section 4: Branding ────────────────────────────────────────────────────
  Widget _buildBranding(BusinessSettingsProvider p) {
    return SettingsCard(
      title: 'Branding',
      description: 'Logo and favicon used across the storefront',
      icon: LucideIcons.image,
      color: const Color(0xFF7C3AED),
      child: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth > 600;
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LogoUploader(
                    label: 'Logo',
                    currentImagePath: p.settings?.logo,
                    isUploading: p.isUploadingLogo,
                    onUpload: (bytes, name) => p.uploadLogo(bytes, name),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: LogoUploader(
                    label: 'Favicon',
                    isFavicon: true,
                    size: 60,
                    currentImagePath: p.settings?.favicon,
                    isUploading: p.isUploadingFavicon,
                    onUpload: (bytes, name) => p.uploadFavicon(bytes, name),
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              LogoUploader(
                label: 'Logo',
                currentImagePath: p.settings?.logo,
                isUploading: p.isUploadingLogo,
                onUpload: (bytes, name) => p.uploadLogo(bytes, name),
              ),
              const SizedBox(height: 20),
              LogoUploader(
                label: 'Favicon',
                isFavicon: true,
                size: 60,
                currentImagePath: p.settings?.favicon,
                isUploading: p.isUploadingFavicon,
                onUpload: (bytes, name) => p.uploadFavicon(bytes, name),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Section 5: Bank ────────────────────────────────────────────────────────
  Widget _buildBankDetails(BusinessSettingsProvider p, bool wide) {
    return SettingsCard(
      title: 'Bank Details',
      description: 'Account information for settlements',
      icon: LucideIcons.landmark,
      color: const Color(0xFF0891B2),
      child: Column(
        children: [
          _grid(wide, [
            SettingsTextField(
              label: 'Account Holder Name',
              icon: LucideIcons.user,
              value: p.getValue('accountHolderName'),
              onChanged: (v) => p.setValue('accountHolderName', v),
            ),
            SettingsTextField(
              label: 'Bank Name',
              icon: LucideIcons.building,
              value: p.getValue('bankName'),
              onChanged: (v) => p.setValue('bankName', v),
            ),
          ]),
          const SizedBox(height: 14),
          _grid(wide, [
            SecureTextField(
              label: 'Account Number',
              icon: LucideIcons.creditCard,
              isSet: p.settings?.accountNumberSet ?? false,
              maskedValue: p.settings?.accountNumberMasked,
              onChanged: (v) => p.setValue('accountNumber', v),
            ),
            SettingsTextField(
              label: 'IFSC Code',
              hint: 'HDFC0000001',
              icon: LucideIcons.hash,
              value: p.getValue('ifscCode'),
              onChanged: (v) => p.setValue('ifscCode', v.toUpperCase()),
              maxLength: 11,
            ),
          ]),
          const SizedBox(height: 14),
          SettingsTextField(
            label: 'Branch Name',
            icon: LucideIcons.mapPin,
            value: p.getValue('branchName'),
            onChanged: (v) => p.setValue('branchName', v),
          ),
        ],
      ),
    );
  }

  // ─── Section 6: Payment Gateway ─────────────────────────────────────────────
  Widget _buildPaymentGateway(BusinessSettingsProvider p, bool wide) {
    return SettingsCard(
      title: 'Payment Gateway',
      description: 'API credentials for online payment providers',
      icon: LucideIcons.creditCard,
      color: const Color(0xFFDC2626),
      child: Column(
        children: [
          SettingsTextField(
            label: 'UPI ID',
            hint: 'business@bank',
            icon: LucideIcons.smartphone,
            value: p.getValue('upiId'),
            onChanged: (v) => p.setValue('upiId', v),
          ),
          const SizedBox(height: 14),
          _grid(wide, [
            SettingsTextField(
              label: 'Razorpay Key ID',
              hint: 'rzp_live_xxxxxxxxxx',
              icon: LucideIcons.key,
              value: p.getValue('razorpayKey'),
              onChanged: (v) => p.setValue('razorpayKey', v),
            ),
            SecureTextField(
              label: 'Razorpay Secret',
              icon: LucideIcons.lock,
              isSet: p.settings?.razorpaySecretSet ?? false,
              maskedValue: p.settings?.razorpaySecretMasked,
              onChanged: (v) => p.setValue('razorpaySecret', v),
            ),
          ]),
          const SizedBox(height: 14),
          _grid(wide, [
            SettingsTextField(
              label: 'Stripe Public Key',
              hint: 'pk_live_xxxxxxxxxx',
              icon: LucideIcons.key,
              value: p.getValue('stripePublicKey'),
              onChanged: (v) => p.setValue('stripePublicKey', v),
            ),
            SecureTextField(
              label: 'Stripe Secret Key',
              icon: LucideIcons.lock,
              isSet: p.settings?.stripeSecretKeySet ?? false,
              maskedValue: p.settings?.stripeSecretKeyMasked,
              onChanged: (v) => p.setValue('stripeSecretKey', v),
            ),
          ]),
        ],
      ),
    );
  }

  // ─── Section 7: Invoice ─────────────────────────────────────────────────────
  Widget _buildInvoiceSettings(BusinessSettingsProvider p, bool wide) {
    return SettingsCard(
      title: 'Invoice Settings',
      description: 'Customize invoice numbering and footer',
      icon: LucideIcons.fileText,
      color: const Color(0xFF0F766E),
      child: Column(
        children: [
          _grid(wide, [
            SettingsTextField(
              label: 'Invoice Prefix',
              hint: 'INV-',
              icon: LucideIcons.hash,
              value: p.getValue('invoicePrefix'),
              onChanged: (v) => p.setValue('invoicePrefix', v),
              maxLength: 10,
            ),
            SettingsTextField(
              label: 'Start Number',
              hint: '1001',
              keyboardType: TextInputType.number,
              value: p.getValue('invoiceStartNumber'),
              onChanged: (v) => p.setValue('invoiceStartNumber', v),
            ),
            SettingsTextField(
              label: 'Default GST %',
              hint: '18',
              keyboardType: TextInputType.number,
              icon: LucideIcons.percent,
              value: p.getValue('gstPercentage'),
              onChanged: (v) => p.setValue('gstPercentage', v),
            ),
          ]),
          const SizedBox(height: 14),
          SettingsTextField(
            label: 'Invoice Footer',
            hint: 'Thank you for your business',
            value: p.getValue('invoiceFooter'),
            onChanged: (v) => p.setValue('invoiceFooter', v),
            maxLines: 2,
          ),
          const SizedBox(height: 14),
          SettingsTextField(
            label: 'Terms & Conditions',
            hint: 'Goods once sold cannot be returned...',
            value: p.getValue('invoiceTerms'),
            onChanged: (v) => p.setValue('invoiceTerms', v),
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  // ─── Section 8: Social ──────────────────────────────────────────────────────
  Widget _buildSocialLinks(BusinessSettingsProvider p, bool wide) {
    return SettingsCard(
      title: 'Social Links',
      description: 'Public social media profiles',
      icon: LucideIcons.share2,
      color: const Color(0xFFE11D48),
      child: _grid(wide, [
        SettingsTextField(
          label: 'Instagram',
          hint: 'https://instagram.com/...',
          icon: LucideIcons.image,
          value: p.getValue('instagramUrl'),
          onChanged: (v) => p.setValue('instagramUrl', v),
        ),
        SettingsTextField(
          label: 'Facebook',
          hint: 'https://facebook.com/...',
          icon: LucideIcons.thumbsUp,
          value: p.getValue('facebookUrl'),
          onChanged: (v) => p.setValue('facebookUrl', v),
        ),
        SettingsTextField(
          label: 'YouTube',
          hint: 'https://youtube.com/@...',
          icon: LucideIcons.play,
          value: p.getValue('youtubeUrl'),
          onChanged: (v) => p.setValue('youtubeUrl', v),
        ),
        SettingsTextField(
          label: 'Twitter / X',
          hint: 'https://x.com/...',
          icon: LucideIcons.atSign,
          value: p.getValue('twitterUrl'),
          onChanged: (v) => p.setValue('twitterUrl', v),
        ),
      ]),
    );
  }

  // ─── Helper: responsive grid ────────────────────────────────────────────────
  Widget _grid(bool wide, List<Widget> children) {
    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:
            children.expand((w) => [w, const SizedBox(height: 14)]).toList()
              ..removeLast(),
      );
    }
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      final left = children[i];
      final right = i + 1 < children.length ? children[i + 1] : null;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              const SizedBox(width: 16),
              Expanded(child: right ?? const SizedBox()),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}

class _StickySaveBar extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onDiscard;

  const _StickySaveBar({
    required this.isSaving,
    required this.onSave,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(top: BorderSide(color: theme.colorScheme.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(LucideIcons.circleAlert, size: 16, color: AppTheme.warningColor),
          const SizedBox(width: 8),
          Text(
            'You have unsaved changes',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.foreground,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          ShadButton.outline(
            size: ShadButtonSize.sm,
            onPressed: isSaving ? null : onDiscard,
            child: const Text('Discard'),
          ),
          const SizedBox(width: 8),
          ShadButton(
            size: ShadButtonSize.sm,
            leading: isSaving
                ? const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(LucideIcons.check, size: 14),
            onPressed: isSaving ? null : onSave,
            child: Text(isSaving ? 'Saving...' : 'Save Changes'),
          ),
        ],
      ),
    );
  }
}
