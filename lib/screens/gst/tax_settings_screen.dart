import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../provider/gst_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/page_header.dart';
import '../settings/widgets/responsive_field_grid.dart';
import '../settings/widgets/settings_text_field.dart';

class TaxSettingsScreen extends StatefulWidget {
  const TaxSettingsScreen({super.key});

  @override
  State<TaxSettingsScreen> createState() => _TaxSettingsScreenState();
}

class _TaxSettingsScreenState extends State<TaxSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GstProvider>().loadTaxSettings();
    });
  }

  Future<void> _save(GstProvider p) async {
    final err = await p.saveTaxSettings();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(err == null ? 'Tax settings saved' : err.alertMessage),
        backgroundColor: err == null
            ? AppTheme.successColor
            : AppTheme.dangerColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GstProvider>(
      builder: (context, p, _) {
        final hasChanges = p.hasUnsavedTaxChanges;
        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, hasChanges ? 90 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageHeader(
                    title: 'Tax Settings',
                    subtitle: 'Default GST rate and invoice tax configuration',
                    onBack: () => context.go('/admin/gst'),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: p.isLoading && p.taxSettings == null
                        ? const LoadingWidget()
                        : SingleChildScrollView(
                            child: ShadCard(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ResponsiveFieldGrid(
                                    children: [
                                      SettingsTextField(
                                        label: 'Default GST %',
                                        hint: '18',
                                        icon: LucideIcons.percent,
                                        keyboardType: TextInputType.number,
                                        value: p.getTaxValue(
                                          'defaultGstPercent',
                                        ),
                                        onChanged: (v) => p.setTaxValue(
                                          'defaultGstPercent',
                                          v,
                                        ),
                                      ),
                                      SettingsTextField(
                                        label: 'Invoice Tax Note',
                                        hint: 'Tax included in product price',
                                        icon: LucideIcons.fileText,
                                        value: p.getTaxValue('invoiceTaxNote'),
                                        onChanged: (v) =>
                                            p.setTaxValue('invoiceTaxNote', v),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  SettingsTextField(
                                    label: 'GST Invoice Footer',
                                    hint: 'Footer text for tax invoices',
                                    value: p.getTaxValue('gstInvoiceFooter'),
                                    onChanged: (v) =>
                                        p.setTaxValue('gstInvoiceFooter', v),
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 14),
                                  SettingsTextField(
                                    label: 'GST Declaration',
                                    hint:
                                        'Standard tax declaration text printed on invoices',
                                    value: p.getTaxValue('gstDeclaration'),
                                    onChanged: (v) =>
                                        p.setTaxValue('gstDeclaration', v),
                                    maxLines: 5,
                                  ),
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
                child: _SaveBar(
                  isSaving: p.isSavingSettings,
                  onSave: () => _save(p),
                  onDiscard: p.resetTaxChanges,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SaveBar extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onDiscard;
  const _SaveBar({
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
