import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/theme/app_theme.dart';

/// A single thumbnail tile in the gallery rail.
///
/// Shows the image bytes preview, an optional ⭐ "primary" badge, and a
/// hover-to-reveal red X to remove. Tapping the tile makes it the primary
/// image (if `onMakePrimary` is provided).
class ImageThumbnailTile extends StatefulWidget {
  final Uint8List? bytes;
  final String name;
  final bool isPrimary;
  final VoidCallback onMakePrimary;
  final VoidCallback onRemove;

  const ImageThumbnailTile({
    super.key,
    required this.bytes,
    required this.name,
    required this.isPrimary,
    required this.onMakePrimary,
    required this.onRemove,
  });

  @override
  State<ImageThumbnailTile> createState() => _ImageThumbnailTileState();
}

class _ImageThumbnailTileState extends State<ImageThumbnailTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onMakePrimary,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isPrimary
                  ? AppTheme.brand
                  : theme.colorScheme.border,
              width: widget.isPrimary ? 2 : 1,
            ),
            color: theme.colorScheme.muted.withValues(alpha: 0.3),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: widget.bytes != null
                    ? Image.memory(widget.bytes!, fit: BoxFit.cover)
                    : const Center(child: Icon(LucideIcons.image, size: 18)),
              ),
              if (widget.isPrimary)
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.brand,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.star,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              if (_hovered)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: widget.onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.dangerColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.x,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
