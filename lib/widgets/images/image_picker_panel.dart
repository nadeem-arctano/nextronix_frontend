import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/theme/app_theme.dart';
import 'image_thumbnail_tile.dart';

/// Side-by-side image picker:
///   - **Left:** big preview of the currently-primary image (or a friendly
///     drop-zone empty state if none picked yet).
///   - **Right:** vertical thumbnail rail with the X / N count, primary
///     marker, drag-to-reorder, and an "Add more" button under it.
///
/// The widget is **purely presentational** — the parent owns the list of
/// images (via `ImagePickerController` below) and is notified of every
/// change. This keeps the same widget reusable across screens (Add Product,
/// Edit Product, Variants, etc.).
class ImagePickerPanel extends StatelessWidget {
  final ImagePickerController controller;
  final int max;
  final String emptyTitle;
  final String emptyHint;

  const ImagePickerPanel({
    super.key,
    required this.controller,
    this.max = 8,
    this.emptyTitle = 'Drop your cover image here',
    this.emptyHint = 'PNG or JPG, up to 5 MB. Recommended 1200×1200.',
  });

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result == null) return;
    controller.addAll(result.files);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return SizedBox(
          height: 460,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 3, child: _buildPrimaryPreview(theme)),
              const SizedBox(width: 16),
              SizedBox(
                width: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCountBanner(theme),
                    const SizedBox(height: 8),
                    Expanded(child: _buildThumbList(theme)),
                    const SizedBox(height: 8),
                    ShadButton.outline(
                      leading: const Icon(LucideIcons.imagePlus, size: 14),
                      onPressed: controller.length >= max ? null : _pick,
                      child: Text(
                        controller.isEmpty ? 'Add images' : 'Add more',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountBanner(ShadThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${controller.length} / $max',
            style: theme.textTheme.small.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!controller.isEmpty)
            Text(
              'Primary: ${controller.primaryIndex + 1}',
              style: theme.textTheme.muted.copyWith(fontSize: 10),
            ),
        ],
      ),
    );
  }

  Widget _buildPrimaryPreview(ShadThemeData theme) {
    final hasImages = !controller.isEmpty;
    return InkWell(
      onTap: hasImages ? null : _pick,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: theme.colorScheme.muted.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.border,
            width: hasImages ? 1 : 1.4,
          ),
        ),
        child: hasImages
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: controller.primary?.bytes != null
                        ? Image.memory(
                            controller.primary!.bytes!,
                            fit: BoxFit.contain,
                          )
                        : const Center(
                            child: Icon(LucideIcons.image, size: 48),
                          ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.brand,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(LucideIcons.star, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'PRIMARY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: ShadButton.destructive(
                      size: ShadButtonSize.sm,
                      leading: const Icon(LucideIcons.trash2, size: 14),
                      onPressed: () =>
                          controller.removeAt(controller.primaryIndex),
                      child: const Text('Remove'),
                    ),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.brand.withValues(alpha: 0.1),
                      ),
                      child: const Icon(
                        LucideIcons.imageUp,
                        size: 36,
                        color: AppTheme.brand,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      emptyTitle,
                      style: theme.textTheme.h4.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(emptyHint, style: theme.textTheme.muted),
                    const SizedBox(height: 16),
                    ShadButton(
                      leading: const Icon(LucideIcons.upload, size: 14),
                      onPressed: _pick,
                      child: const Text('Choose images'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildThumbList(ShadThemeData theme) {
    if (controller.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.muted.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.border),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Thumbnails will appear here',
              textAlign: TextAlign.center,
              style: theme.textTheme.muted.copyWith(fontSize: 11),
            ),
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      itemCount: controller.length,
      onReorder: controller.reorder,
      itemBuilder: (context, index) {
        final pick = controller.images[index];
        return Padding(
          key: ValueKey('thumb-${pick.name}-$index'),
          padding: const EdgeInsets.only(bottom: 8),
          child: ReorderableDragStartListener(
            index: index,
            child: ImageThumbnailTile(
              bytes: pick.bytes,
              name: pick.name,
              isPrimary: index == controller.primaryIndex,
              onMakePrimary: () => controller.setPrimary(index),
              onRemove: () => controller.removeAt(index),
            ),
          ),
        );
      },
    );
  }
}

/// Lightweight container holding a picked image's bytes plus its name.
class ImagePick {
  final PlatformFile file;
  Uint8List? get bytes => file.bytes;
  String get name => file.name;
  ImagePick(this.file);
}

/// State container for `ImagePickerPanel`.
///
/// Owns the list of images plus which index is the primary (cover) one.
/// Notifies listeners on every mutation so widgets that depend on it
/// rebuild — including the panel itself, the discount banner, and any
/// review-step summaries the parent screen shows.
class ImagePickerController extends ChangeNotifier {
  final List<ImagePick> _images = [];
  int _primaryIndex = 0;

  List<ImagePick> get images => List.unmodifiable(_images);
  int get length => _images.length;
  bool get isEmpty => _images.isEmpty;

  int get primaryIndex => _primaryIndex;
  ImagePick? get primary => _images.isEmpty
      ? null
      : _images[_primaryIndex.clamp(0, _images.length - 1)];

  void addAll(Iterable<PlatformFile> files) {
    _images.addAll(files.map(ImagePick.new));
    if (_primaryIndex >= _images.length) _primaryIndex = 0;
    notifyListeners();
  }

  void removeAt(int index) {
    if (index < 0 || index >= _images.length) return;
    _images.removeAt(index);
    if (_images.isEmpty) {
      _primaryIndex = 0;
    } else if (_primaryIndex >= _images.length) {
      _primaryIndex = _images.length - 1;
    } else if (index < _primaryIndex) {
      _primaryIndex--;
    }
    notifyListeners();
  }

  void setPrimary(int index) {
    if (index < 0 || index >= _images.length) return;
    _primaryIndex = index;
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _images.removeAt(oldIndex);
    _images.insert(newIndex, item);

    if (_primaryIndex == oldIndex) {
      _primaryIndex = newIndex;
    } else if (oldIndex < _primaryIndex && newIndex >= _primaryIndex) {
      _primaryIndex--;
    } else if (oldIndex > _primaryIndex && newIndex <= _primaryIndex) {
      _primaryIndex++;
    }
    notifyListeners();
  }

  /// Returns `_images` in publish order: the primary image first, then
  /// the rest in their current order. Useful at submit time so the
  /// backend treats slot 0 as the thumbnail.
  List<ImagePick> orderedForSubmit() {
    if (_images.isEmpty) return const [];
    final list = [..._images];
    final primary = list.removeAt(_primaryIndex);
    list.insert(0, primary);
    return list;
  }
}
