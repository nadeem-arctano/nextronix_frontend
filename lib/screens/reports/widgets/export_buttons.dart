import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../provider/report_provider.dart';

class ExportButtons extends StatelessWidget {
  final String reportType;

  const ExportButtons({super.key, required this.reportType});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, provider, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ExportButton(
              label: 'Excel',
              icon: LucideIcons.fileSpreadsheet,
              color: const Color(0xFF059669),
              isLoading: provider.isExporting,
              onTap: () => _export(context, provider, 'excel'),
            ),
            const SizedBox(width: 8),
            _ExportButton(
              label: 'CSV',
              icon: LucideIcons.fileText,
              color: const Color(0xFF0891B2),
              isLoading: provider.isExporting,
              onTap: () => _export(context, provider, 'csv'),
            ),
            const SizedBox(width: 8),
            _ExportButton(
              label: 'PDF',
              icon: LucideIcons.fileDown,
              color: const Color(0xFFDC2626),
              isLoading: provider.isExporting,
              onTap: () => _export(context, provider, 'pdf'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _export(
    BuildContext context,
    ReportProvider provider,
    String format,
  ) async {
    final data = await provider.exportReport(
      reportType: reportType,
      format: format,
    );

    if (data != null) {
      _downloadFile(data, format);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export failed. Please try again.')),
        );
      }
    }
  }

  void _downloadFile(Uint8List data, String format) {
    String mimeType;
    String extension;

    switch (format) {
      case 'excel':
        mimeType =
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
        extension = 'xlsx';
        break;
      case 'csv':
        mimeType = 'text/csv';
        extension = 'csv';
        break;
      case 'pdf':
        mimeType = 'application/pdf';
        extension = 'pdf';
        break;
      default:
        return;
    }

    final blob = html.Blob([data], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', '${reportType}_report.$extension')
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}

class _ExportButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _ExportButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(6),
            color: color.withValues(alpha: 0.05),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
