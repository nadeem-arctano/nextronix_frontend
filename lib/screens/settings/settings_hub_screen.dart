import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../model/response/response.dart';
import '../../provider/business_settings_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/page_header.dart';

class SettingsHubScreen extends StatefulWidget {
  const SettingsHubScreen({super.key});

  @override
  State<SettingsHubScreen> createState() => _SettingsHubScreenState();
}

class _SettingsHubScreenState extends State<SettingsHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessSettingsProvider>().loadHub();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BusinessSettingsProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'Settings',
                subtitle: 'Manage your business configuration',
              ),
              const SizedBox(height: 24),
              Expanded(
                child: provider.isHubLoading && provider.hubSettings == null
                    ? const LoadingWidget(message: 'Loading settings...')
                    : SingleChildScrollView(
                        child: _buildSectionGrid(context, provider),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionGrid(
    BuildContext context,
    BusinessSettingsProvider provider,
  ) {
    final sections = _buildSections(provider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1100
            ? 4
            : constraints.maxWidth > 800
            ? 3
            : constraints.maxWidth > 500
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.6,
          ),
          itemCount: sections.length,
          itemBuilder: (_, index) => _SectionCard(item: sections[index]),
        );
      },
    );
  }

  List<_SectionItem> _buildSections(BusinessSettingsProvider provider) {
    final s = provider.hubSettings;
    return [
      _SectionItem(
        title: 'Business Information',
        description: 'Company name, GST, PAN',
        icon: LucideIcons.building2,
        color: const Color(0xFF4F46E5),
        route: '/admin/settings/business-info',
        preview: s?.businessName ?? 'Not configured',
        isSet:
            (s?.businessName?.isNotEmpty ?? false) ||
            (s?.gstNumber?.isNotEmpty ?? false),
      ),
      _SectionItem(
        title: 'Contact Information',
        description: 'Email, phone, support',
        icon: LucideIcons.phone,
        color: const Color(0xFF059669),
        route: '/admin/settings/contact',
        preview: s?.businessEmail ?? 'Not configured',
        isSet:
            (s?.businessEmail?.isNotEmpty ?? false) ||
            (s?.businessPhone?.isNotEmpty ?? false),
      ),
      _SectionItem(
        title: 'Business Address',
        description: 'Registered address',
        icon: LucideIcons.mapPin,
        color: const Color(0xFFD97706),
        route: '/admin/settings/address',
        preview: s?.city != null && s!.city!.isNotEmpty
            ? '${s.city}, ${s.state ?? ''}'.trim().replaceAll(RegExp(r',$'), '')
            : 'Not configured',
        isSet: (s?.addressLine1?.isNotEmpty ?? false),
      ),
      _SectionItem(
        title: 'Branding',
        description: 'Logo and favicon',
        icon: LucideIcons.image,
        color: const Color(0xFF7C3AED),
        route: '/admin/settings/branding',
        preview: (s?.logo?.isNotEmpty ?? false) ? 'Logo uploaded' : 'No logo',
        isSet: (s?.logo?.isNotEmpty ?? false),
      ),
      _SectionItem(
        title: 'Bank Details',
        description: 'Account, IFSC, branch',
        icon: LucideIcons.landmark,
        color: const Color(0xFF0891B2),
        route: '/admin/settings/bank',
        preview: s?.accountNumberMasked ?? 'Not configured',
        isSet: s?.accountNumberSet ?? false,
      ),
      _SectionItem(
        title: 'Payment Gateway',
        description: 'Razorpay, Stripe, UPI',
        icon: LucideIcons.creditCard,
        color: const Color(0xFFDC2626),
        route: '/admin/settings/payment',
        preview: (s?.razorpaySecretSet ?? false)
            ? 'Razorpay configured'
            : (s?.upiId?.isNotEmpty ?? false)
            ? 'UPI: ${s!.upiId}'
            : 'Not configured',
        isSet:
            (s?.razorpaySecretSet ?? false) ||
            (s?.stripeSecretKeySet ?? false) ||
            (s?.upiId?.isNotEmpty ?? false),
      ),
      _SectionItem(
        title: 'Invoice Settings',
        description: 'Prefix, GST %, terms',
        icon: LucideIcons.fileText,
        color: const Color(0xFF0F766E),
        route: '/admin/settings/invoice',
        preview: s?.invoicePrefix?.isNotEmpty ?? false
            ? 'Prefix: ${s!.invoicePrefix}'
            : 'Not configured',
        isSet: (s?.invoicePrefix?.isNotEmpty ?? false),
      ),
      _SectionItem(
        title: 'Social Links',
        description: 'Instagram, Facebook, etc',
        icon: LucideIcons.share2,
        color: const Color(0xFFE11D48),
        route: '/admin/settings/social',
        preview: _socialPreview(s),
        isSet:
            (s?.instagramUrl?.isNotEmpty ?? false) ||
            (s?.facebookUrl?.isNotEmpty ?? false) ||
            (s?.youtubeUrl?.isNotEmpty ?? false) ||
            (s?.twitterUrl?.isNotEmpty ?? false),
      ),
    ];
  }

  String _socialPreview(BusinessSettings? s) {
    if (s == null) return 'Not configured';
    final count = [
      s.instagramUrl,
      s.facebookUrl,
      s.youtubeUrl,
      s.twitterUrl,
    ].where((e) => e?.isNotEmpty ?? false).length;
    if (count == 0) return 'Not configured';
    return '$count platform${count > 1 ? 's' : ''} linked';
  }
}

class _SectionItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;
  final String preview;
  final bool isSet;

  _SectionItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
    required this.preview,
    required this.isSet,
  });
}

class _SectionCard extends StatefulWidget {
  final _SectionItem item;
  const _SectionCard({required this.item});

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.item.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..translate(0.0, _hovered ? -2.0 : 0.0),
          child: ShadCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: widget.item.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.item.icon,
                        color: widget.item.color,
                        size: 18,
                      ),
                    ),
                    const Spacer(),
                    if (widget.item.isSet)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'CONFIGURED',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF10B981),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  widget.item.title,
                  style: theme.textTheme.h4.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.item.description,
                  style: theme.textTheme.muted.copyWith(fontSize: 11),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.item.preview,
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.item.isSet
                              ? theme.colorScheme.foreground
                              : theme.colorScheme.mutedForeground,
                          fontWeight: widget.item.isSet
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.identity()
                        ..translate(_hovered ? 4.0 : 0.0, 0.0),
                      child: Icon(
                        LucideIcons.chevronRight,
                        size: 16,
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
