import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/api_constants.dart';
import '../../provider/product_provider.dart';
import '../../provider/category_provider.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/loading_widget.dart';

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
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Products',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/products/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search & Filters
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: 300,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      provider.setSearch(null);
                                    },
                                  )
                                : null,
                          ),
                          onSubmitted: (value) => provider.setSearch(value),
                        ),
                      ),
                      _buildFilterDropdown(provider),
                      _buildSortDropdown(provider),
                      if (provider.searchQuery != null ||
                          provider.statusFilter != null ||
                          provider.sortBy != null)
                        TextButton.icon(
                          onPressed: () {
                            _searchController.clear();
                            provider.clearFilters();
                          },
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Clear Filters'),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Products Table
              Card(
                child: provider.isLoading
                    ? const SizedBox(height: 300, child: LoadingWidget())
                    : provider.products.isEmpty
                    ? const SizedBox(
                        height: 300,
                        child: EmptyWidget(message: 'No products found'),
                      )
                    : Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 20,
                              columns: const [
                                DataColumn(label: Text('PRODUCT')),
                                DataColumn(label: Text('SKU')),
                                DataColumn(label: Text('CATEGORY')),
                                DataColumn(label: Text('PRICE')),
                                DataColumn(label: Text('STOCK')),
                                DataColumn(label: Text('STATUS')),
                                DataColumn(label: Text('ACTIONS')),
                              ],
                              rows: provider.products.map((product) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              color: AppTheme.bgColor,
                                              child:
                                                  product.thumbnailImage != null
                                                  ? Image.network(
                                                      ApiConstants.getImageUrl(
                                                        product.thumbnailImage,
                                                      ),
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (_, __, ___) =>
                                                              const Icon(
                                                                Icons.image,
                                                                size: 20,
                                                              ),
                                                    )
                                                  : const Icon(
                                                      Icons.image,
                                                      size: 20,
                                                      color: AppTheme
                                                          .textSecondary,
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          SizedBox(
                                            width: 200,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  product.name ?? '',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                if (product.brand != null)
                                                  Text(
                                                    product.brand!,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppTheme
                                                          .textSecondary,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DataCell(Text(product.sku ?? '-')),
                                    DataCell(Text(product.categoryName ?? '-')),
                                    DataCell(
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '₹${(product.sellingPrice ?? 0).toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if ((product.mrpPrice ?? 0) >
                                              (product.sellingPrice ?? 0))
                                            Text(
                                              '₹${(product.mrpPrice ?? 0).toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '${product.stockQuantity ?? 0}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: product.isLowStock
                                              ? AppTheme.dangerColor
                                              : AppTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      StatusBadge(
                                        status: product.status ?? 'active',
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              size: 18,
                                            ),
                                            onPressed: () => context.go(
                                              '/products/edit/${product.id}',
                                            ),
                                            tooltip: 'Edit',
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              (product.isFeatured ?? false)
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              size: 18,
                                              color:
                                                  (product.isFeatured ?? false)
                                                  ? AppTheme.warningColor
                                                  : null,
                                            ),
                                            onPressed: () =>
                                                provider.toggleFeatured(
                                                  id: product.id!,
                                                ),
                                            tooltip: 'Toggle Featured',
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              size: 18,
                                              color: AppTheme.dangerColor,
                                            ),
                                            onPressed: () => _confirmDelete(
                                              context,
                                              provider,
                                              product.id!,
                                            ),
                                            tooltip: 'Delete',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                          // Pagination
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Showing ${provider.products.length} of ${provider.totalItems} products',
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.chevron_left),
                                      onPressed: provider.currentPage > 1
                                          ? () => provider.loadProducts(
                                              page: provider.currentPage - 1,
                                            )
                                          : null,
                                    ),
                                    Text(
                                      'Page ${provider.currentPage} of ${provider.totalPages}',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.chevron_right),
                                      onPressed:
                                          provider.currentPage <
                                              provider.totalPages
                                          ? () => provider.loadProducts(
                                              page: provider.currentPage + 1,
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ],
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

  Widget _buildFilterDropdown(ProductProvider provider) {
    return DropdownButton<String>(
      value: provider.statusFilter,
      hint: const Text('Status'),
      underline: const SizedBox(),
      items: const [
        DropdownMenuItem(value: 'active', child: Text('Active')),
        DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
        DropdownMenuItem(value: 'draft', child: Text('Draft')),
      ],
      onChanged: (value) => provider.setFilters(status: value),
    );
  }

  Widget _buildSortDropdown(ProductProvider provider) {
    return DropdownButton<String>(
      value: provider.sortBy,
      hint: const Text('Sort By'),
      underline: const SizedBox(),
      items: const [
        DropdownMenuItem(value: 'latest', child: Text('Latest')),
        DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
        DropdownMenuItem(value: 'price_low', child: Text('Price: Low to High')),
        DropdownMenuItem(
          value: 'price_high',
          child: Text('Price: High to Low'),
        ),
        DropdownMenuItem(value: 'most_viewed', child: Text('Most Viewed')),
        DropdownMenuItem(value: 'most_sold', child: Text('Most Sold')),
      ],
      onChanged: (value) => provider.setFilters(sort: value),
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
