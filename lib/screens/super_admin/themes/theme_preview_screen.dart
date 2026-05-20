import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/theme/dynamic_theme_builder.dart';
import '../../../provider/theme_catalog_provider.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/theme_preview/theme_preview_panel.dart';

/// Super Admin → Theme Preview Screen (full page, no sidebar).
///
/// Opens in a new browser tab. Top bar shows back button (closes tab),
/// theme name, and mode badge. Rest of the page is the full preview.
class ThemePreviewScreen extends StatefulWidget {
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
    return Scaffold(
      body: Consumer<ThemeCatalogProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingDetail) {
            return const Center(
              child: LoadingWidget(message: 'Loading theme preview...'),
            );
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
                    child: const Text('Close'),
                    onPressed: () => html.window.close(),
                  ),
                ],
              ),
            );
          }

          // Compile themeConfig
          final compiled = DynamicThemeBuilder.compile(theme.themeConfig);
          final candidateTheme = theme.mode == 'dark'
              ? compiled.dark
              : compiled.light;

          return Column(
            children: [
              // Top bar
              _PreviewTopBar(themeName: theme.name, mode: theme.mode),
              // Full page preview (no sidebar from ThemePreviewPanel)
              Expanded(
                child: ThemePreviewPanel(candidateTheme: candidateTheme),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Slim top bar with back button (closes tab), theme name, and mode badge.
class _PreviewTopBar extends StatelessWidget {
  final String themeName;
  final String mode;

  const _PreviewTopBar({required this.themeName, required this.mode});

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);
    final isDark = mode == 'dark';

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: shadTheme.colorScheme.card,
        border: Border(bottom: BorderSide(color: shadTheme.colorScheme.border)),
      ),
      child: Row(
        children: [
          // Back button — closes the tab
          ShadButton.ghost(
            size: ShadButtonSize.sm,
            leading: const Icon(LucideIcons.arrowLeft, size: 18),
            onPressed: () => html.window.close(),
            child: const Text('Close'),
          ),
          const SizedBox(width: 16),

          // Theme name
          Text(
            themeName,
            style: shadTheme.textTheme.p.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 12),

          // Mode badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.amber.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDark ? LucideIcons.moon : LucideIcons.sun,
                  size: 12,
                  color: isDark ? Colors.white70 : Colors.amber.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  isDark ? 'Dark' : 'Light',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.amber.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
