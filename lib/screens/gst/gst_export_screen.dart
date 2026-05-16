import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../provider/gst_provider.dart';
import '../../widgets/page_header.dart';
import 'widgets/month_year_picker.dart';

class GstExportScreen extends StatelessWidget {
  const GstExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GstProvider>(
      builder: (context, p, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'Monthly GST Export',
                subtitle: 'CA-friendly monthly export for filing',
              ),
              const SizedBox(height: 20),
              ShadCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      context,
                      title: '1. Select Period',
                      child: MonthYearPicker(
                        selectedMonth: p.selectedMonth,
                        selectedYear: p.selectedYear,
                        onMonthChanged: p.setMonth,
                        onYearChanged: p.setYear,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSection(
                      context,
                      title: '2. Choose Format',
                      child: _buildFormatButtons(context, p),
                    ),
                    const SizedBox(height: 32),
                    _buildInfo(context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.h4.copyWith(fontSize: 13)),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildFormatButtons(BuildContext context, GstProvider p) {
    Future<void> doExport(String format) async {
      final ok = await p.exportMonthly(format);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Exported successfully' : 'Export failed'),
          backgroundColor: ok ? AppTheme.successColor : AppTheme.dangerColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _formatButton(
          icon: LucideIcons.fileSpreadsheet,
          label: 'Download Excel',
          color: const Color(0xFF059669),
          isLoading: p.isExporting,
          onTap: () => doExport('excel'),
        ),
        _formatButton(
          icon: LucideIcons.fileText,
          label: 'Download CSV',
          color: const Color(0xFF0891B2),
          isLoading: p.isExporting,
          onTap: () => doExport('csv'),
        ),
        _formatButton(
          icon: LucideIcons.fileDown,
          label: 'Download PDF',
          color: const Color(0xFFDC2626),
          isLoading: p.isExporting,
          onTap: () => doExport('pdf'),
        ),
      ],
    );
  }

  Widget _formatButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8),
            color: color.withValues(alpha: 0.05),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4F46E5).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.info, color: Color(0xFF4F46E5), size: 16),
              const SizedBox(width: 8),
              Text(
                'CA-Friendly Export',
                style: theme.textTheme.h4.copyWith(
                  fontSize: 13,
                  color: const Color(0xFF4F46E5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'The export includes all required GST filing fields:\n'
            '• Invoice Number, Date, Customer Name, Email\n'
            '• State, Product Name, HSN Code, Quantity\n'
            '• Taxable Amount, GST %, CGST, SGST, IGST\n'
            '• Total GST, Invoice Total\n\n'
            'Excel files include formatted headers, auto-width columns, and total rows.\n'
            'PDF files are optimized for printing.',
            style: theme.textTheme.muted.copyWith(fontSize: 12, height: 1.6),
          ),
        ],
      ),
    );
  }
}
