import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
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
                  ShadButton(
                    leading: const Icon(LucideIcons.plus, size: 16),
                    onPressed: () => context.go('/admin/products/add'),
                    child: const Text('Add Product'),
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
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: Search + Status chips + Sort + Clear
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Search
              SizedBox(
                width: 260,
                child: ShadInput(
                  controller: _searchController,
                  placeholder: const Text('Search products...'),
                  onSubmitted: (value) => provider.setSearch(value),
                  onChanged: (value) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),

              // Status chips
              _buildChip(
                'Active',
                'active',
                provider.statusFilter,
                (v) => provider.setStatus(v),
              ),
              const SizedBox(width: 6),
              _buildChip(
                'Inactive',
                'inactive',
                provider.statusFilter,
                (v) => provider.setStatus(v),
              ),
              const SizedBox(width: 6),
              _buildChip(
                'Draft',
                'draft',
                provider.statusFilter,
                (v) => provider.setStatus(v),
              ),
              const SizedBox(width: 12),

              // Sort
              SizedBox(
                width: 140,
                child: ShadSelect<String>(
                  placeholder: const Text('Sort'),
                  initialValue: provider.sortBy,
                  options: const [
                    ShadOption(value: 'latest', child: Text('Latest')),
                    ShadOption(value: 'oldest', child: Text('Oldest')),
                    ShadOption(value: 'price_low', child: Text('Price ↑')),
                    ShadOption(value: 'price_high', child: Text('Price ↓')),
                    ShadOption(
                      value: 'most_viewed',
                      child: Text('Most Viewed'),
                    ),
                    ShadOption(value: 'most_sold', child: Text('Top Sold')),
                    ShadOption(value: 'name_asc', child: Text('Name A-Z')),
                    ShadOption(value: 'name_desc', child: Text('Name Z-A')),
                  ],
                  selectedOptionBuilder: (context, value) => Text(value),
                  onChanged: (value) => provider.setSort(value),
                ),
              ),

              if (_hasActiveFilters(provider)) ...[
                const SizedBox(width: 12),
                ShadButton.ghost(
                  size: ShadButtonSize.sm,
                  onPressed: () {
                    _searchController.clear();
                    provider.clearFilters();
                  },
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Row 2: Category + Stock + Featured + Price
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Category dropdown
              SizedBox(
                width: 160,
                child: ShadSelect<String>(
                  placeholder: const Text('Category'),
                  initialValue: provider.categoryFilter ?? '',
                  options: [
                    const ShadOption(value: '', child: Text('All Categories')),
                    ...context.watch<CategoryProvider>().categories.map(
                      (c) => ShadOption(
                        value: c.id?.toString() ?? '',
                        child: Text(c.name ?? ''),
                      ),
                    ),
                  ],
                  selectedOptionBuilder: (context, value) =>
                      Text(value.isEmpty ? 'All Categories' : value),
                  onChanged: (value) => provider.setCategory(
                    value == null || value.isEmpty ? null : value,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Stock filter
              SizedBox(
                width: 130,
                child: ShadSelect<String>(
                  placeholder: const Text('Stock'),
                  initialValue: provider.stockFilter ?? '',
                  options: const [
                    ShadOption(value: '', child: Text('All Stock')),
                    ShadOption(value: 'in', child: Text('In Stock')),
                    ShadOption(value: 'low', child: Text('Low Stock')),
                    ShadOption(value: 'out', child: Text('Out of Stock')),
                  ],
                  selectedOptionBuilder: (context, value) =>
                      Text(value.isEmpty ? 'All Stock' : value),
                  onChanged: (value) => provider.setStock(
                    value == null || value.isEmpty ? null : value,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Featured toggle
              _buildChip(
                'Featured',
                true,
                provider.featuredFilter,
                (v) => provider.setFeatured(v),
              ),
              const SizedBox(width: 8),

              // Min Price
              SizedBox(
                width: 100,
                child: ShadInput(
                  placeholder: const Text('Min ₹'),
                  keyboardType: TextInputType.number,
                  onSubmitted: (value) {
                    final v = double.tryParse(value);
                    provider.setPriceRange(v, provider.maxPrice);
                  },
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 100,
                child: ShadInput(
                  placeholder: const Text('Max ₹'),
                  keyboardType: TextInputType.number,
                  onSubmitted: (value) {
                    final v = double.tryParse(value);
                    provider.setPriceRange(provider.minPrice, v);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _hasActiveFilters(ProductProvider provider) {
    return provider.searchQuery != null ||
        provider.statusFilter != null ||
        provider.sortBy != null ||
        provider.categoryFilter != null ||
        provider.stockFilter != null ||
        provider.featuredFilter != null ||
        provider.minPrice != null ||
        provider.maxPrice != null;
  }

  Widget _buildChip<T>(
    String label,
    T? value,
    T? currentValue,
    ValueChanged<T?> onTap,
  ) {
    final theme = ShadTheme.of(context);
    final isSelected = currentValue == value;
    return GestureDetector(
      onTap: () => onTap(isSelected ? null : value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.primaryForeground
                : theme.colorScheme.mutedForeground,
          ),
        ),
      ),
    );
  }

  Widget _buildProductRow(ProductResult product, ProductProvider provider) {
    final theme = ShadTheme.of(context);
    return InkWell(
      onTap: () => context.go('/admin/products/edit/${product.id}'),
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
                      color: theme.colorScheme.muted,
                      child: product.thumbnailImage != null
                          ? Image.network(
                              ApiConstants.getImageUrl(product.thumbnailImage),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(LucideIcons.image, size: 16),
                            )
                          : Icon(
                              LucideIcons.image,
                              size: 16,
                              color: theme.colorScheme.mutedForeground,
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
                          style: theme.textTheme.small,
                        ),
                        if (product.shortDescription != null)
                          Text(
                            product.shortDescription!,
                            style: theme.textTheme.muted.copyWith(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
              child: Text(product.sku ?? '-', style: theme.textTheme.muted),
            ),

            // Category
            Expanded(
              flex: 2,
              child: Text(
                product.categoryName ?? '-',
                style: theme.textTheme.muted,
              ),
            ),

            // Price
            // Price
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${(product.sellingPrice ?? 0).toStringAsFixed(0)}',
                    style: theme.textTheme.small,
                  ),
                  if ((product.mrpPrice ?? 0) > (product.sellingPrice ?? 0))
                    Text(
                      '₹${(product.mrpPrice ?? 0).toStringAsFixed(0)}',
                      style: theme.textTheme.muted.copyWith(
                        fontSize: 11,
                        decoration: TextDecoration.lineThrough,
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
                      : theme.colorScheme.foreground,
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
                icon: Icon(
                  LucideIcons.ellipsis,
                  size: 18,
                  color: theme.colorScheme.mutedForeground,
                ),
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      context.go('/admin/products/edit/${product.id}');
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
                        Icon(LucideIcons.pencil, size: 16),
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
                          LucideIcons.star,
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
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.trash2,
                          size: 16,
                          color: AppTheme.dangerColor,
                        ),
                        const SizedBox(width: 8),
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
    showShadDialog(
      context: context,
      builder: (ctx) => ShadDialog.alert(
        title: const Text('Delete Product'),
        description: const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text('Are you sure you want to delete this product?'),
        ),
        actions: [
          ShadButton.outline(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ShadButton.destructive(
            child: const Text('Delete'),
            onPressed: () {
              provider.deleteProduct(id: id);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
