import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/theme/dynamic_theme_builder.dart';
import '../../../provider/theme_catalog_provider.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/page_header.dart';
import '../../../widgets/theme_preview/theme_preview_panel.dart';

/// Super Admin → Theme Preview Screen.
///
/// Fetches the theme detail by [themeId], compiles its themeConfig
/// via [DynamicThemeBuilder], and renders a [ThemePreviewPanel]
/// with the compiled [ShadThemeData].
///
/// Validates: Requirements 12.1, 14.6
class ThemePreviewScreen extends StatefulWidget {
  /// The theme ID passed from the route parameter.
  final int themeId;

  const ThemePreviewScreen({super.key, required this.themeId});

  @override
  State<ThemePreviewScreen> createState() => _ThemePreviewScreenState();
}

class _ThemePreviewScreenState extends State<ThemePreviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ThemeCatalogProvider>().getThemeDetail(id: widget.themeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeCatalogProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: provider.selectedTheme?.name ?? 'Theme Preview',
                subtitle: 'Preview how this theme looks in the admin panel',
                onBack: () => context.go('/super-admin/themes'),
              ),
              const SizedBox(height: 20),
              Expanded(child: _buildBody(provider)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(ThemeCatalogProvider provider) {
    if (provider.isLoadingDetail) {
      return const LoadingWidget(message: 'Loading theme preview...');
    }

    final theme = provider.selectedTheme;
    if (theme == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.circleAlert,
              size: 48,
              color: ShadTheme.of(context).colorScheme.mutedForeground,
            ),
            const SizedBox(height: 12),
            Text(
              'Theme not found',
              style: ShadTheme.of(context).textTheme.muted,
            ),
            const SizedBox(height: 16),
            ShadButton.outline(
              child: const Text('Back to Themes'),
              onPressed: () => context.go('/super-admin/themes'),
            ),
          ],
        ),
      );
    }

    // Compile themeConfig via DynamicThemeBuilder
    final compiled = DynamicThemeBuilder.compile(theme.themeConfig);

    // Choose the appropriate compiled theme based on theme mode
    final candidateTheme = theme.mode == 'dark'
        ? compiled.dark
        : compiled.light;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ThemePreviewPanel(candidateTheme: candidateTheme),
    );
  }
}
