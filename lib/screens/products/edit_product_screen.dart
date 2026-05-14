import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../provider/product_provider.dart';
import '../../provider/category_provider.dart';
import '../../widgets/loading_widget.dart';

class EditProductScreen extends StatefulWidget {
  final int productId;
  const EditProductScreen({super.key, required this.productId});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _shortDescController = TextEditingController();
  final _fullDescController = TextEditingController();
  final _brandController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _tagsController = TextEditingController();
  final _mrpController = TextEditingController();
  final _sellingController = TextEditingController();
  final _gstController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController();
  final _weightController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _colorController = TextEditingController();
  final _materialController = TextEditingController();
  final _warrantyController = TextEditingController();

  int? _selectedCategory;
  String _status = 'active';
  bool _isFeatured = false;
  bool _isSubmitting = false;
  bool _isLoaded = false;
  PlatformFile? _thumbnailFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProductById(id: widget.productId);
      context.read<CategoryProvider>().loadCategories();
    });
  }

  void _populateFields() {
    final product = context.read<ProductProvider>().selectedProduct;
    if (product == null || _isLoaded) return;

    _nameController.text = product.name ?? '';
    _shortDescController.text = product.shortDescription ?? '';
    _fullDescController.text = product.fullDescription ?? '';
    _brandController.text = product.brand ?? '';
    _skuController.text = product.sku ?? '';
    _barcodeController.text = product.barcode ?? '';
    _tagsController.text = product.tags ?? '';
    _mrpController.text = (product.mrpPrice ?? 0).toStringAsFixed(0);
    _sellingController.text = (product.sellingPrice ?? 0).toStringAsFixed(0);
    _gstController.text = (product.gstPercent ?? 0).toStringAsFixed(0);
    _stockController.text = (product.stockQuantity ?? 0).toString();
    _minStockController.text = (product.minStockAlert ?? 5).toString();
    _weightController.text = product.weight ?? '';
    _dimensionsController.text = product.dimensions ?? '';
    _colorController.text = product.color ?? '';
    _materialController.text = product.material ?? '';
    _warrantyController.text = product.warranty ?? '';
    _selectedCategory = product.categoryId;
    _status = product.status ?? 'active';
    _isFeatured = product.isFeatured ?? false;
    _isLoaded = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final formData = FormData.fromMap({
      'name': _nameController.text,
      'categoryId': _selectedCategory,
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

    final result = await context.read<ProductProvider>().updateProduct(
      id: widget.productId,
      formData: formData,
    );

    setState(() => _isSubmitting = false);

    if (result == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product updated successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      context.go('/products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.selectedProduct == null) {
          return const LoadingWidget(message: 'Loading product...');
        }

        if (provider.selectedProduct != null && !_isLoaded) {
          _populateFields();
        }

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
                      'Edit Product',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
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
                          : const Text('Update Product'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thumbnail Image',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.image,
                    );
                    if (result != null)
                      setState(() => _thumbnailFile = result.files.first);
                  },
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.borderColor),
                      borderRadius: BorderRadius.circular(8),
                      color: AppTheme.bgColor,
                    ),
                    child: _thumbnailFile != null
                        ? Center(child: Text(_thumbnailFile!.name))
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 32,
                                color: AppTheme.textSecondary,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Click to change thumbnail',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
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
                  decoration: const InputDecoration(labelText: 'Tags'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
