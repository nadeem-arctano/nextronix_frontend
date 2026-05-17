import 'dart:async';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/services/toast_service.dart';
import '../../core/theme/app_theme.dart';

/// A modal that lets the user crop a single image (bytes) and returns the
/// cropped bytes when they hit Confirm. Tapping Skip / closing the dialog
/// returns the original bytes unchanged.
///
/// Pass-through helper:
///   final cropped = await ImageCropDialog.show(context, original);
///   if (cropped != null) ...
///
/// Returns `null` only when the user cancels (e.g. presses Esc / clicks
/// outside). "Skip cropping" returns the original bytes so the parent can
/// continue without special-casing.
class ImageCropDialog extends StatefulWidget {
  final Uint8List bytes;
  final String filename;

  const ImageCropDialog({
    super.key,
    required this.bytes,
    required this.filename,
  });

  /// Shows the dialog and returns the cropped (or original) bytes, or null
  /// if the user explicitly cancels.
  static Future<Uint8List?> show(
    BuildContext context, {
    required Uint8List bytes,
    required String filename,
  }) {
    return showDialog<Uint8List?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ImageCropDialog(bytes: bytes, filename: filename),
    );
  }

  @override
  State<ImageCropDialog> createState() => _ImageCropDialogState();
}

class _ImageCropDialogState extends State<ImageCropDialog> {
  final _cropController = CropController();
  bool _isCropping = false;

  // Aspect ratio options. `null` = free crop.
  double? _aspectRatio = 1; // square by default — best for product covers
  static const _aspectChoices = <(String, double?)>[
    ('Free', null),
    ('1 : 1', 1.0),
    ('4 : 3', 4 / 3),
    ('3 : 4', 3 / 4),
    ('16 : 9', 16 / 9),
  ];

  void _confirm() {
    setState(() => _isCropping = true);
    _cropController.crop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Header ────────────────────────────────────────────────
              Row(
                children: [
                  Icon(LucideIcons.crop, size: 16, color: AppTheme.brand),
                  const SizedBox(width: 8),
                  Text('Crop image', style: theme.textTheme.h4),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.filename,
                      style: theme.textTheme.muted.copyWith(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 16),
                    tooltip: 'Cancel',
                    onPressed: () => Navigator.pop(context, null),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ─── Aspect ratio chips ────────────────────────────────────
              Row(
                children: _aspectChoices.map((c) {
                  final isSel = c.$2 == _aspectRatio;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c.$1),
                      selected: isSel,
                      onSelected: (_) => setState(() => _aspectRatio = c.$2),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // ─── Cropper canvas ───────────────────────────────────────
              Expanded(
                child: ColoredBox(
                  color: Colors.black,
                  child: Crop(
                    image: widget.bytes,
                    controller: _cropController,
                    aspectRatio: _aspectRatio,
                    baseColor: Colors.black,
                    maskColor: Colors.black.withValues(alpha: 0.55),
                    cornerDotBuilder: (size, edge) =>
                        DotControl(color: AppTheme.brand),
                    onCropped: (result) {
                      if (!mounted) return;
                      switch (result) {
                        case CropSuccess(:final croppedImage):
                          Navigator.pop(context, croppedImage);
                        case CropFailure(:final cause):
                          setState(() => _isCropping = false);
                          ToastService.error(context, 'Crop failed: $cause');
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ─── Actions ──────────────────────────────────────────────
              Row(
                children: [
                  Text(
                    'Drag the corners or sides to adjust the crop',
                    style: theme.textTheme.muted.copyWith(fontSize: 11),
                  ),
                  const Spacer(),
                  ShadButton.outline(
                    onPressed: _isCropping
                        ? null
                        : () => Navigator.pop(context, widget.bytes),
                    child: const Text('Skip cropping'),
                  ),
                  const SizedBox(width: 8),
                  ShadButton(
                    leading: _isCropping
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(LucideIcons.check, size: 14),
                    onPressed: _isCropping ? null : _confirm,
                    child: Text(_isCropping ? 'Cropping...' : 'Confirm crop'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
