import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/navigation_utils.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/business_settings_provider.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/page_header.dart';

/// Common layout for every section detail screen.
///
/// Handles:
/// - Loading the section on init
/// - Page header with back button to /admin/settings
/// - Loading / error states
/// - Sticky save bar when there are unsaved changes
/// - Save & Discard actions
class SectionScaffold extends StatefulWidget {
  final String section;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget Function(BuildContext, BusinessSettingsProvider) builder;

  /// Set to false for the Branding screen which only uses uploads (no sticky save).
  final bool showSaveBar;

  const SectionScaffold({
    super.key,
    required this.section,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.builder,
    this.showSaveBar = true,
  });

  @override
  State<SectionScaffold> createState() => _SectionScaffoldState();
}

class _SectionScaffoldState extends State<SectionScaffold> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BusinessSettingsProvider>().loadSection(widget.section);
    });
  }

  Future<void> _save() async {
    final provider = context.read<BusinessSettingsProvider>();
    final err = await provider.saveSection(widget.section);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(err == null ? '${widget.title} saved' : err.alertMessage),
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
        final isLoading = provider.isSectionLoading(widget.section);
        final error = provider.sectionError(widget.section);
        final hasChanges =
            widget.showSaveBar && provider.hasUnsavedChanges(widget.section);

        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, hasChanges ? 90 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageHeader(
                    title: widget.title,
                    subtitle: widget.subtitle,
                    onBack: () => smartBack(context, '/admin/settings'),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child:
                        isLoading &&
                            provider.sectionData(widget.section) == null
                        ? const LoadingWidget(message: 'Loading...')
                        : error != null &&
                              provider.sectionData(widget.section) == null
                        ? ErrorWidget2(
                            message: error,
                            onRetry: () => provider.loadSection(widget.section),
                          )
                        : SingleChildScrollView(
                            child: ShadCard(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeader(context),
                                  const SizedBox(height: 24),
                                  widget.builder(context, provider),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),

            if (hasChanges)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _StickySaveBar(
                  isSaving: provider.isSectionSaving(widget.section),
                  onSave: _save,
                  onDiscard: () => provider.resetChanges(widget.section),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: widget.iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(widget.icon, color: widget.iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: theme.textTheme.h4),
              const SizedBox(height: 2),
              Text(
                widget.subtitle,
                style: theme.textTheme.muted.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
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
