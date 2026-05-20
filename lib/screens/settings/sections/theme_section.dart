import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/services/toast_service.dart';
import '../../../core/theme/dynamic_theme_builder.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../model/response/theme_list_response.dart';
import '../../../repository/nextronix_repository.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/page_header.dart';
import '../../../widgets/theme_preview/theme_preview_panel.dart';

/// Admin theme selection screen shown in the settings hub.
///
/// Displays a grid of active themes fetched from GET /api/masters/themes.
/// Highlights the currently selected theme and allows the Admin to preview
/// or select a different theme.
class ThemeSectionScreen extends StatefulWidget {
  const ThemeSectionScreen({super.key});

  @override
  State<ThemeSectionScreen> createState() => _ThemeSectionScreenState();
}

class _ThemeSectionScreenState extends State<ThemeSectionScreen> {
  List<ThemeResult>? _themes;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadThemes();
  }

  Future<void> _loadThemes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await NextronixRepository().listActiveThemes();
      if (!mounted) return;
      setState(() {
        _themes = response.data ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load themes';
        _isLoading = false;
      });
    }
  }

  Future<void> _selectTheme(ThemeResult theme) async {
    final themeProvider = context.read<ThemeProvider>();
    await themeProvider.selectTheme(theme.id);
    if (!mounted) return;
    ToastService.success(context, 'Theme "${theme.name}" applied');
  }

  void _previewTheme(ThemeResult theme) {
    final compiled = DynamicThemeBuilder.compile(theme.themeConfig);
    final candidateTheme = theme.mode == 'dark'
        ? compiled.dark
        : compiled.light;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: 1000,
          height: 700,
          child: Column(
            children: [
              _PreviewDialogHeader(themeName: theme.name),
              Expanded(
                child: ThemePreviewPanel(candidateTheme: candidateTheme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Theme',
            subtitle: 'Choose a theme to personalize your admin panel',
          ),
          const SizedBox(height: 24),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ShadButton.outline(
              onPressed: _loadThemes,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_themes == null || _themes!.isEmpty) {
      return const Center(child: Text('No themes available'));
    }

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final selectedId = themeProvider.selectedThemeId;

        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 900
                ? 3
                : constraints.maxWidth > 550
                ? 2
                : 1;

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.4,
              ),
              itemCount: _themes!.length,
              itemBuilder: (context, index) {
                final theme = _themes![index];
                final isSelected = theme.id == selectedId;
                return _ThemeCard(
                  theme: theme,
                  isSelected: isSelected,
                  onSelect: () => _selectTheme(theme),
                  onPreview: () => _previewTheme(theme),
                );
              },
            );
          },
        );
      },
    );
  }
}

// ─── Theme Card ─────────────────────────────────────────────────────────────

class _ThemeCard extends StatelessWidget {
  final ThemeResult theme;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onPreview;

  const _ThemeCard({
    required this.theme,
    required this.isSelected,
    required this.onSelect,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected
              ? shadTheme.colorScheme.primary
              : shadTheme.colorScheme.border,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: shadTheme.colorScheme.card,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: name + badges
          Row(
            children: [
              Expanded(
                child: Text(
                  theme.name,
                  style: shadTheme.textTheme.p.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _ModeBadge(mode: theme.mode),
              if (theme.isDefault) ...[
                const SizedBox(width: 6),
                _DefaultBadge(),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Description
          if (theme.description != null && theme.description!.isNotEmpty)
            Text(
              theme.description!,
              style: shadTheme.textTheme.muted.copyWith(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          else
            Text(
              '${theme.mode[0].toUpperCase()}${theme.mode.substring(1)} theme',
              style: shadTheme.textTheme.muted.copyWith(fontSize: 12),
            ),

          const Spacer(),

          // Selected indicator or action buttons
          if (isSelected)
            _SelectedIndicator()
          else
            Row(
              children: [
                Expanded(
                  child: ShadButton.outline(
                    size: ShadButtonSize.sm,
                    leading: const Icon(LucideIcons.eye, size: 14),
                    onPressed: onPreview,
                    child: const Text('Preview'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ShadButton(
                    size: ShadButtonSize.sm,
                    leading: const Icon(LucideIcons.check, size: 14),
                    onPressed: onSelect,
                    child: const Text('Select'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── Badges ─────────────────────────────────────────────────────────────────

class _ModeBadge extends StatelessWidget {
  final String mode;
  const _ModeBadge({required this.mode});

  @override
  Widget build(BuildContext context) {
    final isDark = mode == 'dark';
    return Container(
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
            size: 11,
            color: isDark ? Colors.white70 : Colors.amber.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            isDark ? 'Dark' : 'Light',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.amber.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DefaultBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Default',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }
}

class _SelectedIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: shadTheme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.circleCheck,
            size: 16,
            color: shadTheme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Selected',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: shadTheme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Preview Dialog Header ──────────────────────────────────────────────────

class _PreviewDialogHeader extends StatelessWidget {
  final String themeName;
  const _PreviewDialogHeader({required this.themeName});

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: shadTheme.colorScheme.border)),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.palette,
            size: 18,
            color: shadTheme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Preview: $themeName',
              style: shadTheme.textTheme.p.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          ShadButton.outline(
            size: ShadButtonSize.sm,
            onPressed: () => Navigator.of(context).pop(),
            child: const Icon(LucideIcons.x, size: 18),
          ),
        ],
      ),
    );
  }
}
