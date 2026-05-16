import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../provider/business_settings_provider.dart';
import '../widgets/logo_uploader.dart';
import '../widgets/section_scaffold.dart';

class BrandingSectionScreen extends StatelessWidget {
  const BrandingSectionScreen({super.key});

  static const String _section = SettingsSections.branding;

  @override
  Widget build(BuildContext context) {
    return SectionScaffold(
      section: _section,
      title: 'Branding',
      subtitle: 'Logo and favicon used across the storefront',
      icon: LucideIcons.image,
      iconColor: const Color(0xFF7C3AED),
      showSaveBar: false,
      builder: (context, p) {
        return LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth > 600;
            final logoUploader = LogoUploader(
              label: 'Logo',
              currentImagePath: p.sectionData(_section)?.logo,
              isUploading: p.isUploadingLogo,
              onUpload: (bytes, name) => p.uploadLogo(bytes, name),
            );
            final faviconUploader = LogoUploader(
              label: 'Favicon',
              isFavicon: true,
              size: 60,
              currentImagePath: p.sectionData(_section)?.favicon,
              isUploading: p.isUploadingFavicon,
              onUpload: (bytes, name) => p.uploadFavicon(bytes, name),
            );

            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: logoUploader),
                  const SizedBox(width: 24),
                  Expanded(child: faviconUploader),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                logoUploader,
                const SizedBox(height: 24),
                faviconUploader,
              ],
            );
          },
        );
      },
    );
  }
}
