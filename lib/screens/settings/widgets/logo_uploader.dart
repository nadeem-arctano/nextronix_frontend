import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../api/base_url.dart';

class LogoUploader extends StatelessWidget {
  final String label;
  final String? currentImagePath;
  final bool isUploading;
  final Future<void> Function(Uint8List bytes, String filename) onUpload;
  final double size;
  final bool isFavicon;

  const LogoUploader({
    super.key,
    required this.label,
    required this.onUpload,
    this.currentImagePath,
    this.isUploading = false,
    this.size = 100,
    this.isFavicon = false,
  });

  String get _imageUrl {
    if (currentImagePath == null) return '';
    final base = BaseUrl.baseurl.replaceAll('/api/', '/');
    return '$base$currentImagePath';
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        await onUpload(file.bytes!, file.name);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.small.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.border, width: 2),
                borderRadius: BorderRadius.circular(isFavicon ? 8 : 12),
                color: theme.colorScheme.muted.withValues(alpha: 0.2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isFavicon ? 6 : 10),
                child: isUploading
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : currentImagePath != null && currentImagePath!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: _imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Icon(
                          isFavicon ? LucideIcons.image : LucideIcons.imageOff,
                          size: 32,
                          color: theme.colorScheme.mutedForeground,
                        ),
                      )
                    : Center(
                        child: Icon(
                          isFavicon ? LucideIcons.image : LucideIcons.image,
                          size: 32,
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isFavicon ? 'Favicon' : 'Brand Logo',
                    style: theme.textTheme.p.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isFavicon
                        ? 'Square format recommended (.ico, .png)'
                        : 'PNG, JPG, SVG up to 5MB',
                    style: theme.textTheme.muted.copyWith(fontSize: 11),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ShadButton.outline(
                        size: ShadButtonSize.sm,
                        leading: const Icon(LucideIcons.upload, size: 12),
                        onPressed: isUploading ? null : _pickFile,
                        child: Text(
                          currentImagePath != null ? 'Change' : 'Upload',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
