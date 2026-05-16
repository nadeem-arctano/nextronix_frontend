import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../provider/business_settings_provider.dart';
import '../widgets/responsive_field_grid.dart';
import '../widgets/section_scaffold.dart';
import '../widgets/settings_text_field.dart';

class SocialSectionScreen extends StatelessWidget {
  const SocialSectionScreen({super.key});

  static const String _section = SettingsSections.social;

  @override
  Widget build(BuildContext context) {
    return SectionScaffold(
      section: _section,
      title: 'Social Links',
      subtitle: 'Public social media profiles',
      icon: LucideIcons.share2,
      iconColor: const Color(0xFFE11D48),
      builder: (context, p) => ResponsiveFieldGrid(
        children: [
          SettingsTextField(
            label: 'Instagram',
            hint: 'https://instagram.com/...',
            icon: LucideIcons.image,
            value: p.getValue(_section, 'instagramUrl'),
            onChanged: (v) => p.setValue(_section, 'instagramUrl', v),
          ),
          SettingsTextField(
            label: 'Facebook',
            hint: 'https://facebook.com/...',
            icon: LucideIcons.thumbsUp,
            value: p.getValue(_section, 'facebookUrl'),
            onChanged: (v) => p.setValue(_section, 'facebookUrl', v),
          ),
          SettingsTextField(
            label: 'YouTube',
            hint: 'https://youtube.com/@...',
            icon: LucideIcons.play,
            value: p.getValue(_section, 'youtubeUrl'),
            onChanged: (v) => p.setValue(_section, 'youtubeUrl', v),
          ),
          SettingsTextField(
            label: 'Twitter / X',
            hint: 'https://x.com/...',
            icon: LucideIcons.atSign,
            value: p.getValue(_section, 'twitterUrl'),
            onChanged: (v) => p.setValue(_section, 'twitterUrl', v),
          ),
        ],
      ),
    );
  }
}
