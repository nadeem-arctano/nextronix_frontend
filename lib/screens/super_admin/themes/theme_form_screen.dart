import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/services/toast_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../model/response/alert_error_response.dart';
import '../../../model/response/theme_list_response.dart';
import '../../../provider/theme_catalog_provider.dart';
import '../../../widgets/page_header.dart';

/// Theme form screen for creating or editing a theme in the Super Admin panel.
/// Supports both create and edit modes via a shared form.
///
/// Fields: name, slug (auto-generated), description, mode selector,
/// themeConfig JSON editor, previewConfig JSON editor, pairedThemeId dropdown,
/// previewImage upload, and inline preview sections management.
///
/// Validates: Requirements 12.1, 15.4
class ThemeFormScreen extends StatefulWidget {
  /// When null, the screen is in "create" mode. When provided, it's "edit" mode.
  final int? themeId;

  const ThemeFormScreen({super.key, this.themeId});

  @override
  State<ThemeFormScreen> createState() => _ThemeFormScreenState();
}

class _ThemeFormScreenState extends State<ThemeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _themeConfigController = TextEditingController();
  final _previewConfigController = TextEditingController();

  String _mode = 'light';
  int? _pairedThemeId;
  PlatformFile? _previewImageFile;
  String? _existingPreviewImage;

  // Preview sections managed inline
  List<_PreviewSectionEntry> _previewSections = [];

  bool _isLoading = false;
  bool _isFetchingTheme = false;
  String? _generalError;
  String? _slugError;
  String? _themeConfigError;

  bool get _isEditMode => widget.themeId != null;

  // Available themes for pairedThemeId dropdown
  List<ThemeResult> _availableThemes = [];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadAvailableThemes();
      if (_isEditMode) {
        _fetchTheme();
      }
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    _themeConfigController.dispose();
    _previewConfigController.dispose();
    super.dispose();
  }

  /// Auto-generate slug from name: lowercase, replace spaces/special chars with hyphens
  void _onNameChanged() {
    if (!_isEditMode || _slugController.text.isEmpty) {
      final name = _nameController.text;
      final slug = name
          .toLowerCase()
          .trim()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
          .replaceAll(RegExp(r'^-+|-+$'), '');
      _slugController.text = slug;
    }
  }

  Future<void> _loadAvailableThemes() async {
    final provider = context.read<ThemeCatalogProvider>();
    await provider.loadThemes(limit: 100);
    if (mounted) {
      setState(() {
        _availableThemes = provider.themes;
      });
    }
  }

  Future<void> _fetchTheme() async {
    setState(() => _isFetchingTheme = true);
    final provider = context.read<ThemeCatalogProvider>();
    final error = await provider.getThemeDetail(id: widget.themeId!);
    if (error != null) {
      setState(() {
        _isFetchingTheme = false;
        _generalError = error.alertMessage;
      });
      return;
    }

    final theme = provider.selectedTheme;
    if (theme != null) {
      _nameController.text = theme.name;
      _slugController.text = theme.slug;
      _descriptionController.text = theme.description ?? '';
      _mode = theme.mode;
      _pairedThemeId = theme.pairedThemeId;
      _existingPreviewImage = theme.previewImage;

      // Populate themeConfig as formatted JSON
      _themeConfigController.text = const JsonEncoder.withIndent(
        '  ',
      ).convert(theme.themeConfig);

      // Populate previewConfig as formatted JSON
      if (theme.previewConfig != null) {
        _previewConfigController.text = const JsonEncoder.withIndent(
          '  ',
        ).convert(theme.previewConfig);
      }

      // Load preview sections
      _previewSections = (provider.previewSections).map((s) {
        return _PreviewSectionEntry(
          id: s.id,
          sectionKey: s.sectionKey,
          label: s.label,
          sortOrder: s.sortOrder,
          configOverride: s.configOverride,
        );
      }).toList();
    }

    setState(() => _isFetchingTheme = false);
  }

  bool _validateThemeConfigJson(String text) {
    if (text.trim().isEmpty) {
      setState(() => _themeConfigError = 'themeConfig is required');
      return false;
    }
    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        setState(() => _themeConfigError = 'themeConfig must be a JSON object');
        return false;
      }
      if (!decoded.containsKey('colors') ||
          !decoded.containsKey('typography') ||
          !decoded.containsKey('layout')) {
        setState(
          () => _themeConfigError =
              'themeConfig must contain colors, typography, and layout keys',
        );
        return false;
      }
      if (text.length > 65536) {
        setState(() => _themeConfigError = 'themeConfig exceeds 64KB limit');
        return false;
      }
      setState(() => _themeConfigError = null);
      return true;
    } catch (e) {
      setState(() => _themeConfigError = 'Invalid JSON: ${e.toString()}');
      return false;
    }
  }

  Future<void> _pickPreviewImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _previewImageFile = result.files.first);
    }
  }

  Future<void> _submit() async {
    setState(() {
      _generalError = null;
      _slugError = null;
      _themeConfigError = null;
    });

    // Validate form fields
    if (_nameController.text.trim().isEmpty) {
      setState(() => _generalError = 'Name is required');
      return;
    }
    if (_slugController.text.trim().isEmpty) {
      setState(() => _generalError = 'Slug is required');
      return;
    }
    if (!_validateThemeConfigJson(_themeConfigController.text)) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final themeConfig = jsonDecode(_themeConfigController.text);
      Map<String, dynamic>? previewConfig;
      if (_previewConfigController.text.trim().isNotEmpty) {
        previewConfig = jsonDecode(_previewConfigController.text);
      }

      final formData = FormData.fromMap({
        'name': _nameController.text.trim(),
        'slug': _slugController.text.trim(),
        'description': _descriptionController.text.trim(),
        'mode': _mode,
        'themeConfig': jsonEncode(themeConfig),
        if (previewConfig != null) 'previewConfig': jsonEncode(previewConfig),
        if (_pairedThemeId != null) 'pairedThemeId': _pairedThemeId.toString(),
        // Send preview sections as JSON array
        'previewSections': jsonEncode(
          _previewSections.map((s) => s.toJson()).toList(),
        ),
      });

      // Attach preview image if picked
      if (_previewImageFile != null && _previewImageFile!.bytes != null) {
        formData.files.add(
          MapEntry(
            'previewImage',
            MultipartFile.fromBytes(
              _previewImageFile!.bytes!,
              filename: _previewImageFile!.name,
            ),
          ),
        );
      }

      final provider = context.read<ThemeCatalogProvider>();
      AlertErrorResponse? error;

      if (_isEditMode) {
        error = await provider.updateTheme(
          id: widget.themeId!,
          formData: formData,
        );
      } else {
        error = await provider.createTheme(formData: formData);
      }

      if (!mounted) return;

      if (error != null) {
        final err = error;
        // Check for slug conflict
        if (err.alertMessage.contains('slug')) {
          setState(() => _slugError = err.alertMessage);
        } else {
          setState(() => _generalError = err.alertMessage);
        }
      } else {
        ToastService.success(
          context,
          _isEditMode
              ? 'Theme updated successfully'
              : 'Theme created successfully',
        );
        context.go('/super-admin/themes');
      }
    } on FormatException catch (e) {
      setState(() => _generalError = 'JSON format error: ${e.message}');
    } catch (e) {
      setState(() => _generalError = 'Something went wrong');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetchingTheme) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: _isEditMode ? 'Edit Theme' : 'Create Theme',
            onBack: () => context.go('/super-admin/themes'),
            actions: [
              ShadButton.outline(
                child: const Text('Cancel'),
                onPressed: () => context.go('/super-admin/themes'),
              ),
              const SizedBox(width: 8),
              ShadButton(
                enabled: !_isLoading,
                onPressed: _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditMode ? 'Update' : 'Create'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: _buildForm(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // General error banner
          if (_generalError != null) ...[
            _buildErrorBanner(_generalError!),
            const SizedBox(height: 20),
          ],

          // Name field
          _buildFieldLabel('Theme Name', required: true),
          const SizedBox(height: 6),
          ShadInput(
            controller: _nameController,
            placeholder: const Text('Enter theme name'),
          ),
          const SizedBox(height: 20),

          // Slug field
          _buildFieldLabel('Slug', required: true),
          const SizedBox(height: 6),
          ShadInput(
            controller: _slugController,
            placeholder: const Text('auto-generated-slug'),
          ),
          if (_slugError != null) ...[
            const SizedBox(height: 6),
            Text(
              _slugError!,
              style: TextStyle(color: AppTheme.dangerColor, fontSize: 12),
            ),
          ],
          const SizedBox(height: 20),

          // Description field
          _buildFieldLabel('Description'),
          const SizedBox(height: 6),
          ShadInput(
            controller: _descriptionController,
            placeholder: const Text('Optional description'),
            maxLines: 3,
          ),
          const SizedBox(height: 20),

          // Mode selector
          _buildFieldLabel('Mode', required: true),
          const SizedBox(height: 6),
          ShadSelect<String>(
            initialValue: _mode,
            options: const [
              ShadOption(value: 'light', child: Text('Light')),
              ShadOption(value: 'dark', child: Text('Dark')),
            ],
            selectedOptionBuilder: (context, value) =>
                Text(value == 'light' ? 'Light' : 'Dark'),
            onChanged: (v) {
              if (v != null) setState(() => _mode = v);
            },
          ),
          const SizedBox(height: 20),

          // Paired Theme dropdown
          _buildFieldLabel('Paired Theme (opposite mode)'),
          const SizedBox(height: 6),
          _buildPairedThemeDropdown(),
          const SizedBox(height: 20),

          // Preview Image upload
          _buildFieldLabel('Preview Image'),
          const SizedBox(height: 6),
          _buildPreviewImagePicker(),
          const SizedBox(height: 20),

          // themeConfig JSON editor
          _buildFieldLabel('Theme Config (JSON)', required: true),
          const SizedBox(height: 6),
          _buildJsonEditor(
            controller: _themeConfigController,
            placeholder:
                '{\n  "colors": {...},\n  "typography": {...},\n  "layout": {...}\n}',
            errorText: _themeConfigError,
          ),
          const SizedBox(height: 20),

          // previewConfig JSON editor
          _buildFieldLabel('Preview Config (JSON)'),
          const SizedBox(height: 6),
          _buildJsonEditor(
            controller: _previewConfigController,
            placeholder:
                '{\n  "sections": ["dashboard", "productsTable", ...]\n}',
          ),
          const SizedBox(height: 28),

          // Preview Sections management
          _buildPreviewSectionsManager(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPairedThemeDropdown() {
    // Filter to opposite mode themes only, exclude self in edit mode
    final oppositeMode = _mode == 'light' ? 'dark' : 'light';
    final candidates = _availableThemes
        .where(
          (t) =>
              t.mode == oppositeMode &&
              (_isEditMode ? t.id != widget.themeId : true),
        )
        .toList();

    final options = [
      const ShadOption(value: 'none', child: Text('None')),
      ...candidates.map(
        (t) => ShadOption(value: t.id.toString(), child: Text(t.name)),
      ),
    ];

    return ShadSelect<String>(
      initialValue: _pairedThemeId?.toString() ?? 'none',
      options: options,
      selectedOptionBuilder: (context, value) {
        if (value == 'none') return const Text('None');
        final theme = candidates.where((t) => t.id.toString() == value);
        return Text(theme.isNotEmpty ? theme.first.name : value);
      },
      onChanged: (v) {
        setState(() {
          _pairedThemeId = (v == null || v == 'none') ? null : int.tryParse(v);
        });
      },
    );
  }

  Widget _buildPreviewImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_previewImageFile != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.image, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _previewImageFile!.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                ShadIconButton.ghost(
                  icon: const Icon(LucideIcons.x, size: 14),
                  onPressed: () => setState(() => _previewImageFile = null),
                ),
              ],
            ),
          ),
        ] else if (_existingPreviewImage != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.image, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _existingPreviewImage!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        ShadButton.outline(
          size: ShadButtonSize.sm,
          leading: const Icon(LucideIcons.upload, size: 14),
          onPressed: _pickPreviewImage,
          child: const Text('Upload Image'),
        ),
      ],
    );
  }

  Widget _buildJsonEditor({
    required TextEditingController controller,
    String? placeholder,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: errorText != null
                  ? AppTheme.dangerColor
                  : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            maxLines: 12,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontFamily: 'monospace',
                fontSize: 13,
              ),
              contentPadding: const EdgeInsets.all(12),
              border: InputBorder.none,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText,
            style: TextStyle(color: AppTheme.dangerColor, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildPreviewSectionsManager() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Preview Sections',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            ShadButton.outline(
              size: ShadButtonSize.sm,
              leading: const Icon(LucideIcons.plus, size: 14),
              onPressed: _addPreviewSection,
              child: const Text('Add Section'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_previewSections.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'No preview sections added yet',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          )
        else
          ..._previewSections.asMap().entries.map((entry) {
            final idx = entry.key;
            final section = entry.value;
            return _buildPreviewSectionCard(section, idx);
          }),
      ],
    );
  }

  Widget _buildPreviewSectionCard(_PreviewSectionEntry section, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Key: ${section.sectionKey} • Order: ${section.sortOrder}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          ShadIconButton.ghost(
            icon: const Icon(LucideIcons.pencil, size: 14),
            onPressed: () => _editPreviewSection(index),
          ),
          ShadIconButton.ghost(
            icon: Icon(
              LucideIcons.trash2,
              size: 14,
              color: AppTheme.dangerColor,
            ),
            onPressed: () => _removePreviewSection(index),
          ),
        ],
      ),
    );
  }

  void _addPreviewSection() {
    _showPreviewSectionDialog(null, (section) {
      setState(() => _previewSections.add(section));
    });
  }

  void _editPreviewSection(int index) {
    _showPreviewSectionDialog(_previewSections[index], (section) {
      setState(() => _previewSections[index] = section);
    });
  }

  void _removePreviewSection(int index) {
    setState(() => _previewSections.removeAt(index));
  }

  void _showPreviewSectionDialog(
    _PreviewSectionEntry? existing,
    void Function(_PreviewSectionEntry) onSave,
  ) {
    final keyController = TextEditingController(
      text: existing?.sectionKey ?? '',
    );
    final labelController = TextEditingController(text: existing?.label ?? '');
    final orderController = TextEditingController(
      text: existing?.sortOrder.toString() ?? '0',
    );
    final overrideController = TextEditingController(
      text: existing?.configOverride != null
          ? const JsonEncoder.withIndent('  ').convert(existing!.configOverride)
          : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          existing != null ? 'Edit Preview Section' : 'Add Preview Section',
        ),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Section Key', required: true),
                const SizedBox(height: 6),
                ShadInput(
                  controller: keyController,
                  placeholder: const Text('e.g. dashboard'),
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Label', required: true),
                const SizedBox(height: 6),
                ShadInput(
                  controller: labelController,
                  placeholder: const Text('e.g. Dashboard Preview'),
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Sort Order'),
                const SizedBox(height: 6),
                ShadInput(
                  controller: orderController,
                  placeholder: const Text('0'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Config Override (JSON)'),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: overrideController,
                    maxLines: 5,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                    decoration: const InputDecoration(
                      hintText: '{"key": "value"}',
                      contentPadding: EdgeInsets.all(10),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (keyController.text.trim().isEmpty ||
                  labelController.text.trim().isEmpty) {
                return;
              }

              Map<String, dynamic>? configOverride;
              if (overrideController.text.trim().isNotEmpty) {
                try {
                  configOverride = jsonDecode(overrideController.text.trim());
                } catch (_) {
                  // Invalid JSON, ignore override
                }
              }

              onSave(
                _PreviewSectionEntry(
                  id: existing?.id,
                  sectionKey: keyController.text.trim(),
                  label: labelController.text.trim(),
                  sortOrder: int.tryParse(orderController.text.trim()) ?? 0,
                  configOverride: configOverride,
                ),
              );
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.dangerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: AppTheme.dangerColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: AppTheme.dangerColor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool required = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        if (required)
          Text(
            ' *',
            style: TextStyle(color: AppTheme.dangerColor, fontSize: 13),
          ),
      ],
    );
  }
}

/// Internal model for managing preview section entries in the form.
class _PreviewSectionEntry {
  final int? id;
  final String sectionKey;
  final String label;
  final int sortOrder;
  final Map<String, dynamic>? configOverride;

  _PreviewSectionEntry({
    this.id,
    required this.sectionKey,
    required this.label,
    required this.sortOrder,
    this.configOverride,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'sectionKey': sectionKey,
      'label': label,
      'sortOrder': sortOrder,
    };
    if (configOverride != null) map['configOverride'] = configOverride;
    return map;
  }
}
