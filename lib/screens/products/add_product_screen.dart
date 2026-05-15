import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../provider/product_provider.dart';
import '../../provider/category_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadHsnCodes();
    });
  }

  final _nameController = TextEditingController();
  final _shortDescController = TextEditingController();
  final _fullDescController = TextEditingController();
  final _brandController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _tagsController = TextEditingController();
  final _mrpController = TextEditingController();
  final _sellingController = TextEditingController();
  final _gstController = TextEditingController(text: '18');
  final _stockController = TextEditingController(text: '0');
  final _minStockController = TextEditingController(text: '5');
  final _weightController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _colorController = TextEditingController();
  final _materialController = TextEditingController();
  final _warrantyController = TextEditingController();

  int? _selectedCategory;
  int? _selectedHsn;
  String _status = 'active';
  bool _isFeatured = false;
  bool _isSubmitting = false;
  PlatformFile? _thumbnailFile;
  List<PlatformFile> _galleryFiles = [];

  @override
  void dispose() {
    _nameController.dispose();
    _shortDescController.dispose();
    _fullDescController.dispose();
    _brandController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _tagsController.dispose();
    _mrpController.dispose();
    _sellingController.dispose();
    _gstController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _weightController.dispose();
    _dimensionsController.dispose();
    _colorController.dispose();
    _materialController.dispose();
    _warrantyController.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() => _thumbnailFile = result.files.first);
    }
  }

  Future<void> _pickGallery() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result != null) {
      setState(() => _galleryFiles.addAll(result.files));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    setState(() => _isSubmitting = true);

    final formData = FormData.fromMap({
      'name': _nameController.text,
      'categoryId': _selectedCategory,
      if (_selectedHsn != null) 'hsnId': _selectedHsn,
      'shortDescription': _shortDescController.text,
      'fullDescription': _fullDescController.text,
      'brand': _brandController.text,
      'sku': _skuController.text,
      'barcode': _barcodeController.text,
      'tags': _tagsController.text,
      'mrpPrice': _mrpController.text,
      'sellingPrice': _sellingController.text,
      'gstPercent': _gstController.text,
      'stockQuantity': _stockController.text,
      'minStockAlert': _minStockController.text,
      'weight': _weightController.text,
      'dimensions': _dimensionsController.text,
      'color': _colorController.text,
      'material': _materialController.text,
      'warranty': _warrantyController.text,
      'status': _status,
      'isFeatured': _isFeatured,
    });

    if (_thumbnailFile != null && _thumbnailFile!.bytes != null) {
      formData.files.add(
        MapEntry(
          'thumbnailImage',
          MultipartFile.fromBytes(
            _thumbnailFile!.bytes!,
            filename: _thumbnailFile!.name,
          ),
        ),
      );
    }

    for (final file in _galleryFiles) {
      if (file.bytes != null) {
        formData.files.add(
          MapEntry(
            'galleryImages',
            MultipartFile.fromBytes(file.bytes!, filename: file.name),
          ),
        );
      }
    }

    final result = await context.read<ProductProvider>().createProduct(
      formData: formData,
    );

    setState(() => _isSubmitting = false);

    if (result == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product created successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      context.go('/products');
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/products'),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Add New Product',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildMainForm(categories)),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: _buildSideForm()),
                    ],
                  );
                }
                return Column(
                  children: [
                    _buildMainForm(categories),
                    const SizedBox(height: 24),
                    _buildSideForm(),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => context.go('/products'),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Create Product'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainForm(List categories) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Product Name *'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category *'),
                    items: categories.map<DropdownMenuItem<int>>((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name ?? ''),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedHsn,
                    decoration: const InputDecoration(labelText: 'HSN Code'),
                    items: context
                        .read<ProductProvider>()
                        .hsnCodes
                        .map<DropdownMenuItem<int>>((h) {
                          return DropdownMenuItem(
                            value: h.id,
                            child: Text(h.displayLabel),
                          );
                        })
                        .toList(),
                    onChanged: (v) {
                      setState(() => _selectedHsn = v);
                      // Auto-fill GST from HSN
                      final hsn = context
                          .read<ProductProvider>()
                          .hsnCodes
                          .where((h) => h.id == v)
                          .firstOrNull;
                      if (hsn != null) {
                        _gstController.text =
                            hsn.gstPercent?.toStringAsFixed(0) ?? '18';
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _brandController,
                    decoration: const InputDecoration(labelText: 'Brand'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _shortDescController,
              decoration: const InputDecoration(labelText: 'Short Description'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fullDescController,
              decoration: const InputDecoration(labelText: 'Full Description'),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            const Text(
              'Pricing',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _mrpController,
                    decoration: const InputDecoration(
                      labelText: 'MRP Price *',
                      prefixText: '₹ ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _sellingController,
                    decoration: const InputDecoration(
                      labelText: 'Selling Price *',
                      prefixText: '₹ ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _gstController,
                    decoration: const InputDecoration(
                      labelText: 'GST %',
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Inventory',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _skuController,
                    decoration: const InputDecoration(labelText: 'SKU'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _barcodeController,
                    decoration: const InputDecoration(labelText: 'Barcode'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stock Quantity',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _minStockController,
                    decoration: const InputDecoration(
                      labelText: 'Min Stock Alert',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideForm() {
    return Column(
      children: [
        // Images
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Images',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickThumbnail,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.borderColor,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: AppTheme.bgColor,
                    ),
                    child: _thumbnailFile != null
                        ? Stack(
                            children: [
                              Center(
                                child: Text(
                                  _thumbnailFile!.name,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () =>
                                      setState(() => _thumbnailFile = null),
                                ),
                              ),
                            ],
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 40,
                                color: AppTheme.textSecondary,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Click to upload thumbnail',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _pickGallery,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Add Gallery Images'),
                ),
                if (_galleryFiles.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _galleryFiles
                        .map(
                          (f) => Chip(
                            label: Text(
                              f.name,
                              style: const TextStyle(fontSize: 11),
                            ),
                            onDeleted: () =>
                                setState(() => _galleryFiles.remove(f)),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Status & Options
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status & Options',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(
                      value: 'inactive',
                      child: Text('Inactive'),
                    ),
                    DropdownMenuItem(value: 'draft', child: Text('Draft')),
                  ],
                  onChanged: (v) => setState(() => _status = v!),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Featured Product'),
                  value: _isFeatured,
                  onChanged: (v) => setState(() => _isFeatured = v),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Additional Info
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Additional Info',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _colorController,
                  decoration: const InputDecoration(labelText: 'Color'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _materialController,
                  decoration: const InputDecoration(labelText: 'Material'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(labelText: 'Weight'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _dimensionsController,
                  decoration: const InputDecoration(labelText: 'Dimensions'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _warrantyController,
                  decoration: const InputDecoration(labelText: 'Warranty'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma separated)',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
