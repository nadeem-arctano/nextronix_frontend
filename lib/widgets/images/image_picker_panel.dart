import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/theme/app_theme.dart';
import 'image_crop_dialog.dart';
import 'image_thumbnail_tile.dart';

/// Side-by-side image picker.
///
/// Layout
/// ──────
/// **Left**  – Persistent "drop / choose images" panel. Stays in upload
///             mode even after images have been added so the user can
///             keep dropping more without hunting for a button. Tap a
///             thumbnail to switch the panel to a quick-preview of that
///             image; a small "Back to upload" chip returns to the
///             empty state.
/// **Right** – Vertical thumbnail rail with the X/N count, primary
///             marker (⭐), drag-to-reorder, and a per-tile delete on
///             hover.
///
/// Each picked file is run through `ImageCropDialog` before it lands in
/// the rail, so the user can square-up product photos right at upload
/// time. Skipping the crop dialog stores the original bytes unchanged.
class ImagePickerPanel extends StatefulWidget {
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

  @override
  State<ImagePickerPanel> createState() => _ImagePickerPanelState();
}

class _ImagePickerPanelState extends State<ImagePickerPanel> {
  /// When the user taps a thumbnail we briefly show that image in the
  /// main pane. Once they pick "Back to upload" (or add a new image) we
  /// return to the persistent uploader. Null = uploader visible.
  int? _previewIndex;

  Future<void> _pickAndCrop() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    if (!mounted) return;

    // Process each picked file in order. The user cropping the first one
    // gets dropped into the rail before we ask about the next.
    for (final f in result.files) {
      if (widget.controller.length >= widget.max) break;
      if (f.bytes == null) continue;

      final cropped = await ImageCropDialog.show(
        context,
        bytes: f.bytes!,
        filename: f.name,
      );
      if (!mounted) return;

      if (cropped == null) continue; // user cancelled, skip this file
      widget.controller.addCropped(filename: f.name, bytes: cropped);
    }

    // After every successful add, return to the upload state so the user
    // can keep dropping more images without manual reset.
    if (mounted) setState(() => _previewIndex = null);
  }

  void _previewThumbnail(int index) {
    setState(() => _previewIndex = index);
  }

  void _backToUpload() {
    setState(() => _previewIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        // Clamp preview index in case the underlying list shrank.
        if (_previewIndex != null &&
            _previewIndex! >= widget.controller.length) {
          _previewIndex = null;
        }
        return SizedBox(
          height: 460,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 3, child: _buildLeftPane()),
              const SizedBox(width: 16),
              SizedBox(width: 160, child: _buildRightRail()),
            ],
          ),
        );
      },
    );
  }

  // ─── Left pane: persistent uploader, optionally swapped for a preview ─
  Widget _buildLeftPane() {
    if (_previewIndex != null) return _buildPreviewPane(_previewIndex!);
    return _buildUploaderPane();
  }

  Widget _buildUploaderPane() {
    final theme = ShadTheme.of(context);
    final atCapacity = widget.controller.length >= widget.max;

    return InkWell(
      onTap: atCapacity ? null : _pickAndCrop,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: theme.colorScheme.muted.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.border, width: 1.4),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.brand.withValues(alpha: 0.1),
                ),
                child: Icon(
                  atCapacity ? LucideIcons.check : LucideIcons.imageUp,
                  size: 36,
                  color: AppTheme.brand,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                atCapacity
                    ? "You've reached the ${widget.max}-image limit"
                    : widget.controller.isEmpty
                    ? widget.emptyTitle
                    : 'Add another image',
                style: theme.textTheme.h4.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                atCapacity
                    ? 'Remove a thumbnail on the right to free up a slot.'
                    : widget.emptyHint,
                style: theme.textTheme.muted,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (!atCapacity)
                ShadButton(
                  leading: const Icon(LucideIcons.upload, size: 14),
                  onPressed: _pickAndCrop,
                  child: const Text('Choose images'),
                ),
              if (widget.controller.length > 0) ...[
                const SizedBox(height: 12),
                Text(
                  '${widget.controller.length} of ${widget.max} added',
                  style: theme.textTheme.muted.copyWith(fontSize: 11),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewPane(int index) {
    final theme = ShadTheme.of(context);
    final pick = widget.controller.images[index];
    final isPrimary = index == widget.controller.primaryIndex;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: pick.bytes != null
                ? Image.memory(pick.bytes!, fit: BoxFit.contain)
                : const Center(child: Icon(LucideIcons.image, size: 48)),
          ),
          if (isPrimary)
            Positioned(
              top: 12,
              left: 12,
              child: _badge(
                icon: LucideIcons.star,
                label: 'PRIMARY',
                bg: AppTheme.brand,
              ),
            )
          else
            Positioned(
              top: 12,
              left: 12,
              child: ShadButton.outline(
                size: ShadButtonSize.sm,
                leading: const Icon(LucideIcons.star, size: 14),
                onPressed: () => widget.controller.setPrimary(index),
                child: const Text('Make primary'),
              ),
            ),
          Positioned(
            top: 12,
            right: 12,
            child: ShadButton.outline(
              size: ShadButtonSize.sm,
              leading: const Icon(LucideIcons.imageUp, size: 14),
              onPressed: _backToUpload,
              child: const Text('Back to upload'),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: ShadButton.destructive(
              size: ShadButtonSize.sm,
              leading: const Icon(LucideIcons.trash2, size: 14),
              onPressed: () {
                widget.controller.removeAt(index);
                _backToUpload();
              },
              child: const Text('Remove'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge({
    required IconData icon,
    required String label,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Right rail: count banner + thumbnails + add-more button ────────
  Widget _buildRightRail() {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CountBanner(
          length: widget.controller.length,
          max: widget.max,
          primaryIndex: widget.controller.isEmpty
              ? null
              : widget.controller.primaryIndex,
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildThumbList(theme)),
        const SizedBox(height: 8),
        ShadButton.outline(
          leading: const Icon(LucideIcons.imagePlus, size: 14),
          onPressed: widget.controller.length >= widget.max
              ? null
              : _pickAndCrop,
          child: Text(widget.controller.isEmpty ? 'Add images' : 'Add more'),
        ),
      ],
    );
  }

  Widget _buildThumbList(ShadThemeData theme) {
    if (widget.controller.isEmpty) {
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
      itemCount: widget.controller.length,
      onReorder: widget.controller.reorder,
      itemBuilder: (context, index) {
        final pick = widget.controller.images[index];
        return Padding(
          key: ValueKey('thumb-${pick.name}-$index'),
          padding: const EdgeInsets.only(bottom: 8),
          child: ReorderableDragStartListener(
            index: index,
            child: ImageThumbnailTile(
              bytes: pick.bytes,
              name: pick.name,
              isPrimary: index == widget.controller.primaryIndex,
              onMakePrimary: () => _previewThumbnail(index),
              onRemove: () => widget.controller.removeAt(index),
            ),
          ),
        );
      },
    );
  }
}

class _CountBanner extends StatelessWidget {
  final int length;
  final int max;
  final int? primaryIndex;

  const _CountBanner({
    required this.length,
    required this.max,
    required this.primaryIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
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
            '$length / $max',
            style: theme.textTheme.small.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (primaryIndex != null)
            Text(
              'Primary: ${primaryIndex! + 1}',
              style: theme.textTheme.muted.copyWith(fontSize: 10),
            ),
        ],
      ),
    );
  }
}

/// Lightweight container holding a picked image.
///
/// `file` is the original Multer/FilePicker object — kept around so the
/// upload code at submit time can still send the original filename. The
/// actual bytes used for previews and uploads come from `bytes`, which
/// may be different from `file.bytes` if the user cropped.
class ImagePick {
  final PlatformFile file;
  final Uint8List? _croppedBytes;

  ImagePick(this.file) : _croppedBytes = null;

  /// Construct a pick from already-cropped bytes (no underlying
  /// FilePicker payload). We synthesise a `PlatformFile` so downstream
  /// code that expects `.file` keeps working.
  ImagePick.cropped({required String filename, required Uint8List bytes})
    : file = PlatformFile(name: filename, size: bytes.length, bytes: bytes),
      _croppedBytes = bytes;

  Uint8List? get bytes => _croppedBytes ?? file.bytes;
  String get name => file.name;
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

  /// Add an already-cropped image (typical path from `ImagePickerPanel`).
  void addCropped({required String filename, required Uint8List bytes}) {
    _images.add(ImagePick.cropped(filename: filename, bytes: bytes));
    if (_primaryIndex >= _images.length) _primaryIndex = 0;
    notifyListeners();
  }

  /// Add raw FilePicker results — bypasses crop. Kept for callers that
  /// don't need the cropping flow (e.g. legacy bulk imports).
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
