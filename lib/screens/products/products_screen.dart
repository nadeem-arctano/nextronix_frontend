import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/api_constants.dart';
import '../../model/response/response.dart';
import '../../provider/product_provider.dart';
import '../../provider/category_provider.dart';
import '../../widgets/app_list_table.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/page_header.dart';
import '../../widgets/status_badge.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Products',
                actions: [
                  ElevatedButton.icon(
                    onPressed: () => context.go('/products/add'),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Product'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildFilters(provider),
              const SizedBox(height: 20),
              Expanded(
                child: provider.isLoading
                    ? const LoadingWidget()
                    : provider.products.isEmpty
                    ? const EmptyWidget(message: 'No products found')
                    : AppListTable<ProductResult>(
                        columns: const [
                          AppTableColumn(label: 'Product', flex: 4),
                          AppTableColumn(label: 'SKU', flex: 2),
                          AppTableColumn(label: 'Category', flex: 2),
                          AppTableColumn(label: 'Price', flex: 2),
                          AppTableColumn(label: 'Stock', flex: 1),
                          AppTableColumn(label: 'Status', flex: 2),
                        ],
                        items: provider.products,
                        currentPage: provider.currentPage,
                        totalPages: provider.totalPages,
                        totalItems: provider.totalItems,
                        itemLabel: 'products',
                        onPageChanged: (page) =>
                            provider.loadProducts(page: page),
                        rowBuilder: (product, _) =>
                            _buildProductRow(product, provider),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilters(ProductProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Search
          SizedBox(
            width: 260,
            height: 36,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearch(null);
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              style: const TextStyle(fontSize: 13),
              onSubmitted: (value) => provider.setSearch(value),
              onChanged: (value) => setState(() {}),
            ),
          ),
          const SizedBox(width: 12),

          // Status chips
          _buildChip(
            'All',
            null,
            provider.statusFilter,
            (v) => provider.setFilters(status: v),
          ),
          const SizedBox(width: 6),
          _buildChip(
            'Active',
            'active',
            provider.statusFilter,
            (v) => provider.setFilters(status: v),
          ),
          const SizedBox(width: 6),
          _buildChip(
            'Inactive',
            'inactive',
            provider.statusFilter,
            (v) => provider.setFilters(status: v),
          ),
          const SizedBox(width: 6),
          _buildChip(
            'Draft',
            'draft',
            provider.statusFilter,
            (v) => provider.setFilters(status: v),
          ),
          const SizedBox(width: 12),

          // Sort
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: provider.sortBy,
                hint: const Text(
                  'Sort',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                isDense: true,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textPrimary,
                ),
                items: const [
                  DropdownMenuItem(value: 'latest', child: Text('Latest')),
                  DropdownMenuItem(value: 'price_low', child: Text('Price ↑')),
                  DropdownMenuItem(value: 'price_high', child: Text('Price ↓')),
                  DropdownMenuItem(value: 'most_sold', child: Text('Top Sold')),
                ],
                onChanged: (value) => provider.setFilters(sort: value),
              ),
            ),
          ),

          if (provider.searchQuery != null ||
              provider.statusFilter != null ||
              provider.sortBy != null) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                _searchController.clear();
                provider.clearFilters();
              },
              child: const Text(
                'Clear',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(
    String label,
    String? value,
    String? currentValue,
    ValueChanged<String?> onTap,
  ) {
    final isSelected = currentValue == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.sidebarColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.sidebarColor : AppTheme.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildProductRow(ProductResult product, ProductProvider provider) {
    return InkWell(
      onTap: () => context.go('/products/edit/${product.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Product (image + name + brand)
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: 36,
                      height: 36,
                      color: AppTheme.dividerColor,
                      child: product.thumbnailImage != null
                          ? Image.network(
                              ApiConstants.getImageUrl(product.thumbnailImage),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.image, size: 16),
                            )
                          : const Icon(
                              Icons.image,
                              size: 16,
                              color: AppTheme.textMuted,
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (product.brand != null)
                          Text(
                            product.brand!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // SKU
            Expanded(
              flex: 2,
              child: Text(
                product.sku ?? '-',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),

            // Category
            Expanded(
              flex: 2,
              child: Text(
                product.categoryName ?? '-',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),

            // Price
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${(product.sellingPrice ?? 0).toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if ((product.mrpPrice ?? 0) > (product.sellingPrice ?? 0))
                    Text(
                      '₹${(product.mrpPrice ?? 0).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 11,
                        decoration: TextDecoration.lineThrough,
                        color: AppTheme.textMuted,
                      ),
                    ),
                ],
              ),
            ),

            // Stock
            Expanded(
              flex: 1,
              child: Text(
                '${product.stockQuantity ?? 0}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: product.isLowStock
                      ? AppTheme.dangerColor
                      : AppTheme.textPrimary,
                ),
              ),
            ),

            // Status
            Expanded(
              flex: 2,
              child: StatusBadge(status: product.status ?? 'active'),
            ),

            // Actions
            SizedBox(
              width: 40,
              child: PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_horiz,
                  size: 18,
                  color: AppTheme.textSecondary,
                ),
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      context.go('/products/edit/${product.id}');
                    case 'featured':
                      provider.toggleFeatured(id: product.id!);
                    case 'delete':
                      _confirmDelete(context, provider, product.id!);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'featured',
                    child: Row(
                      children: [
                        Icon(
                          (product.isFeatured ?? false)
                              ? Icons.star
                              : Icons.star_border,
                          size: 16,
                          color: AppTheme.warningColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          (product.isFeatured ?? false)
                              ? 'Unfeature'
                              : 'Feature',
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: AppTheme.dangerColor,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: TextStyle(color: AppTheme.dangerColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProductProvider provider, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerColor,
            ),
            onPressed: () {
              provider.deleteProduct(id: id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
