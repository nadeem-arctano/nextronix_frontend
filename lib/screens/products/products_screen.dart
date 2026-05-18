import 'package:flutter/material.dart';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/api_constants.dart';
import '../../model/response/response.dart';
import '../../provider/product_provider.dart';
import '../../provider/category_provider.dart';
import '../../repository/nextronix_repository.dart';
import '../../widgets/app_list_table.dart';
import '../../widgets/debounced_search_input.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/page_header.dart';
import '../../widgets/skeletons.dart';
import '../../widgets/status_badge.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  bool _showPriceApply = false;

  /// Locally-managed hidden-columns set so the column-toggle button can
  /// live inside the filter row alongside search and filters.
  Set<String> _hiddenColumns = <String>{};

  // Variant-group expansion state. Tracked per parent product id so the user
  // can drill into a parent's variations inline without navigating away.
  final Set<int> _expandedParents = <int>{};
  final Set<int> _loadingParents = <int>{};
  final Map<int, List<VariantGroupMember>> _childrenCache =
      <int, List<VariantGroupMember>>{};
  final Map<int, String> _childrenError = <int, String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProductProvider>().loadProducts();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  /// Toggles the expanded state for a parent row and lazily fetches its
  /// children the first time. Cached per parent id so subsequent toggles
  /// don't re-hit the network.
  Future<void> _toggleParentExpansion(int parentId) async {
    if (_expandedParents.contains(parentId)) {
      setState(() => _expandedParents.remove(parentId));
      return;
    }

    setState(() => _expandedParents.add(parentId));

    if (_childrenCache.containsKey(parentId)) return;

    setState(() {
      _loadingParents.add(parentId);
      _childrenError.remove(parentId);
    });

    try {
      final repo = NextronixRepository();
      final res = await repo.getProductGroup(id: parentId);
      if (!mounted) return;
      setState(() {
        _childrenCache[parentId] = res.data?.children ?? const [];
        _loadingParents.remove(parentId);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _childrenError[parentId] = 'Failed to load variations';
        _loadingParents.remove(parentId);
      });
    }
  }

  /// Re-fetches the cached children for a parent after a child edit so the
  /// expanded rows show fresh price/stock immediately.
  Future<void> _refreshChildren(int parentId) async {
    try {
      final repo = NextronixRepository();
      final res = await repo.getProductGroup(id: parentId);
      if (!mounted) return;
      setState(() {
        _childrenCache[parentId] = res.data?.children ?? const [];
      });
    } catch (_) {
      // Silent — the cell will keep showing the old value until the user
      // re-toggles. We don't want to flash an error overlay for a refresh.
    }
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
                  ShadButton.outline(
                    leading: const Icon(LucideIcons.layers, size: 14),
                    size: ShadButtonSize.sm,
                    onPressed: () => _openAddVariantPicker(context, provider),
                    child: const Text('Add Variant'),
                  ),
                  const SizedBox(width: 8),
                  ShadButton(
                    leading: const Icon(LucideIcons.plus, size: 14),
                    size: ShadButtonSize.sm,
                    onPressed: () {
                      final url = Uri.base
                          .resolve('/admin/products/add')
                          .toString();
                      web.window.open(url, '_blank');
                    },
                    child: const Text('Add Product'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildFilters(provider),
              const SizedBox(height: 20),
              Expanded(
                child: provider.isLoading
                    ? const TableSkeleton(rows: 8, columns: 6)
                    : provider.products.isEmpty
                    ? const EmptyWidget(message: 'No products found')
                    : AppListTable<ProductResult>(
                        columns: const [
                          AppTableColumn(
                            key: 'product',
                            label: 'Product',
                            flex: 6,
                          ),
                          AppTableColumn(key: 'sku', label: 'SKU', flex: 2),
                          AppTableColumn(
                            key: 'category',
                            label: 'Category',
                            flex: 2,
                          ),
                          AppTableColumn(key: 'hsn', label: 'HSN', flex: 2),
                          AppTableColumn(key: 'color', label: 'Color', flex: 2),
                          AppTableColumn(key: 'price', label: 'Price', flex: 2),
                          AppTableColumn(key: 'stock', label: 'Stock', flex: 2),
                          AppTableColumn(
                            key: 'status',
                            label: 'Status',
                            flex: 1,
                          ),
                        ],
                        trailingWidth: 70,
                        items: provider.products,
                        currentPage: provider.currentPage,
                        totalPages: provider.totalPages,
                        totalItems: provider.totalItems,
                        itemLabel: 'products',
                        onPageChanged: (page) =>
                            provider.loadProducts(page: page),
                        rowBuilder: (product, _) =>
                            _buildProductRowWithChildren(product, provider),
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
              // Search (auto-debounced via shared widget).
              DebouncedSearchInput(
                controller: _searchController,
                placeholder: 'Search products...',
                initialValue: provider.searchQuery,
                onSearch: provider.setSearch,
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
                  selectedOptionBuilder: (context, value) {
                    const sortLabels = {
                      'latest': 'Latest',
                      'oldest': 'Oldest',
                      'price_low': 'Price ↑',
                      'price_high': 'Price ↓',
                      'most_viewed': 'Most Viewed',
                      'most_sold': 'Top Sold',
                      'name_asc': 'Name A-Z',
                      'name_desc': 'Name Z-A',
                    };
                    return Text(sortLabels[value] ?? value);
                  },
                  onChanged: (value) => provider.setSort(value),
                ),
              ),

              if (_hasActiveFilters(provider)) ...[
                const SizedBox(width: 12),
                ShadButton.ghost(
                  size: ShadButtonSize.sm,
                  onPressed: () {
                    _searchController.clear();
                    _minPriceController.clear();
                    _maxPriceController.clear();
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
                  selectedOptionBuilder: (context, value) {
                    if (value.isEmpty) return const Text('All Categories');
                    final cats = context.read<CategoryProvider>().categories;
                    final cat = cats
                        .where((c) => c.id?.toString() == value)
                        .firstOrNull;
                    return Text(cat?.name ?? 'All Categories');
                  },
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
                  selectedOptionBuilder: (context, value) {
                    const stockLabels = {
                      '': 'All Stock',
                      'in': 'In Stock',
                      'low': 'Low Stock',
                      'out': 'Out of Stock',
                    };
                    return Text(stockLabels[value] ?? 'All Stock');
                  },
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
                  controller: _minPriceController,
                  placeholder: const Text('Min Price'),
                  style: const TextStyle(fontSize: 12),
                  keyboardType: TextInputType.number,
                  onChanged: (_) {
                    if (!_showPriceApply)
                      setState(() => _showPriceApply = true);
                  },
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 100,
                child: ShadInput(
                  controller: _maxPriceController,
                  placeholder: const Text('Max Price'),
                  style: const TextStyle(fontSize: 12),
                  keyboardType: TextInputType.number,
                  onChanged: (_) {
                    if (!_showPriceApply)
                      setState(() => _showPriceApply = true);
                  },
                ),
              ),
              if (_showPriceApply) ...[
                const SizedBox(width: 8),
                SizedBox(
                  height: 32,
                  child: ShadButton(
                    size: ShadButtonSize.sm,
                    onPressed: () {
                      final min = double.tryParse(_minPriceController.text);
                      final max = double.tryParse(_maxPriceController.text);
                      provider.setPriceRange(min, max);
                      setState(() => _showPriceApply = false);
                    },
                    child: const Text('Apply', style: TextStyle(fontSize: 12)),
                  ),
                ),
                if (_minPriceController.text.isNotEmpty ||
                    _maxPriceController.text.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  SizedBox(
                    height: 32,
                    child: ShadButton.outline(
                      size: ShadButtonSize.sm,
                      onPressed: () {
                        _minPriceController.clear();
                        _maxPriceController.clear();
                        if (provider.minPrice != null ||
                            provider.maxPrice != null) {
                          provider.setPriceRange(null, null);
                        }
                        setState(() => _showPriceApply = false);
                      },
                      child: const Text(
                        'Clear',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ],
              const SizedBox(width: 12),
              // Column-visibility toggle, same icon as the table's built-in
              // toolbar but rendered here so it sits alongside the filters.
              AppListTableColumnMenu(
                columns: const [
                  AppTableColumn(key: 'product', label: 'Product'),
                  AppTableColumn(key: 'sku', label: 'SKU'),
                  AppTableColumn(key: 'category', label: 'Category'),
                  AppTableColumn(key: 'hsn', label: 'HSN'),
                  AppTableColumn(key: 'color', label: 'Color'),
                  AppTableColumn(key: 'price', label: 'Price'),
                  AppTableColumn(key: 'stock', label: 'Stock'),
                  AppTableColumn(key: 'status', label: 'Status'),
                ],
                hiddenColumns: _hiddenColumns,
                onChanged: (next) => setState(() => _hiddenColumns = next),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _hasActiveFilters(ProductProvider provider) {
    return provider.searchQuery != null ||
        (provider.statusFilter != null && provider.statusFilter != 'active') ||
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
    final isParent = product.groupRole == 'parent';
    final isExpanded = isParent && _expandedParents.contains(product.id);
    return Container(
      color: isExpanded
          ? theme.colorScheme.muted.withValues(alpha: 0.18)
          : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Product (image + name + brand)
          if (!AppListTable.isColumnHidden(context, 'product'))
            Expanded(
              flex: 6,
              child: Row(
                children: [
                  // Chevron occupies a fixed slot on every row so the image and
                  // names line up regardless of whether the row is a parent.
                  SizedBox(
                    width: 22,
                    child: isParent
                        ? GestureDetector(
                            onTap: () => _toggleParentExpansion(product.id!),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: AnimatedRotation(
                                turns: isExpanded ? 0.25 : 0,
                                duration: const Duration(milliseconds: 150),
                                child: Icon(
                                  LucideIcons.chevronRight,
                                  size: 16,
                                  color: theme.colorScheme.mutedForeground,
                                ),
                              ),
                            ),
                          )
                        : null,
                  ),
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
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                product.name ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.small,
                              ),
                            ),
                            if (product.groupRole == 'parent') ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.brand.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'VARIATION',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.brand,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ] else if (product.groupRole == 'child') ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.textSecondary.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'VARIATION',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textSecondary,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (product.shortDescription != null &&
                            product.shortDescription!.trim().isNotEmpty)
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
          if (!AppListTable.isColumnHidden(context, 'sku'))
            Expanded(
              flex: 2,
              child: Text(
                product.sku ?? '-',
                style: theme.textTheme.muted.copyWith(fontSize: 12),
              ),
            ),

          // Category
          if (!AppListTable.isColumnHidden(context, 'category'))
            Expanded(
              flex: 2,
              child: Text(
                product.categoryName ?? '-',
                style: theme.textTheme.muted.copyWith(fontSize: 12),
              ),
            ),

          // HSN
          if (!AppListTable.isColumnHidden(context, 'hsn'))
            Expanded(
              flex: 2,
              child: Text(
                product.hsnCode ?? '-',
                style: theme.textTheme.muted.copyWith(fontSize: 12),
              ),
            ),

          // Color (variant-specific label preferred over the base color field)
          if (!AppListTable.isColumnHidden(context, 'color'))
            Expanded(
              flex: 2,
              child: Builder(
                builder: (_) {
                  final label =
                      (product.variantOptionColor?.trim().isNotEmpty ?? false)
                      ? product.variantOptionColor!
                      : (product.color?.trim().isNotEmpty ?? false)
                      ? product.color!
                      : null;
                  if (label == null) {
                    return Text(
                      '-',
                      style: theme.textTheme.muted.copyWith(fontSize: 12),
                    );
                  }
                  return Row(
                    children: [
                      _ColorSwatch(label: label),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.muted.copyWith(fontSize: 12),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

          // Price
          if (!AppListTable.isColumnHidden(context, 'price'))
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${(product.sellingPrice ?? 0).toStringAsFixed(0)}',
                        style: theme.textTheme.small.copyWith(fontSize: 12),
                      ),
                      if ((product.mrpPrice ?? 0) > (product.sellingPrice ?? 0))
                        Text(
                          '₹${(product.mrpPrice ?? 0).toStringAsFixed(0)}',
                          style: theme.textTheme.muted.copyWith(
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () =>
                        _showPriceEditDialog(context, product, provider),
                    child: Icon(
                      LucideIcons.pencil,
                      size: 12,
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),

          // Stock
          if (!AppListTable.isColumnHidden(context, 'stock'))
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Text(
                    '${product.stockQuantity ?? 0}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: product.isLowStock
                          ? AppTheme.dangerColor
                          : theme.colorScheme.foreground,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () =>
                        _showStockEditDialog(context, product, provider),
                    child: Icon(
                      LucideIcons.pencil,
                      size: 12,
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),

          // Status
          if (!AppListTable.isColumnHidden(context, 'status'))
            Expanded(
              flex: 1,
              child: StatusBadge(status: product.status ?? 'active'),
            ),

          // Featured indicator + View button
          SizedBox(
            width: 18,
            child: product.isFeatured == true
                ? Icon(LucideIcons.star, size: 14, color: AppTheme.warningColor)
                : null,
          ),

          GestureDetector(
            onTap: () => context.go('/admin/products/edit/${product.id}'),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  LucideIcons.mousePointerClick,
                  size: 16,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ),
          ),

          // Actions
          SizedBox(
            width: 32,
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
                  case 'variants':
                    context.push('/admin/products/${product.id}/variations');
                  case 'featured':
                    provider.toggleFeatured(id: product.id!);
                  case 'activate':
                    provider.updateProductStatus(
                      id: product.id!,
                      status: 'active',
                    );
                  case 'deactivate':
                    provider.updateProductStatus(
                      id: product.id!,
                      status: 'inactive',
                    );
                }
              },
              itemBuilder: (_) {
                final isActive = (product.status ?? 'active') == 'active';
                final canManageVariations = isParent;
                return [
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
                  if (canManageVariations)
                    const PopupMenuItem(
                      value: 'variants',
                      child: Row(
                        children: [
                          Icon(LucideIcons.layers, size: 16),
                          SizedBox(width: 8),
                          Text('Manage Variations'),
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
                  if (isActive)
                    const PopupMenuItem(
                      value: 'deactivate',
                      child: Row(
                        children: [
                          Icon(LucideIcons.circleOff, size: 16),
                          SizedBox(width: 8),
                          Text('Set Inactive'),
                        ],
                      ),
                    )
                  else
                    const PopupMenuItem(
                      value: 'activate',
                      child: Row(
                        children: [
                          Icon(LucideIcons.circleCheck, size: 16),
                          SizedBox(width: 8),
                          Text('Set Active'),
                        ],
                      ),
                    ),
                ];
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Wraps a parent product row with its inline children when expanded.
  /// Standalone and child products fall through and render the bare row.
  Widget _buildProductRowWithChildren(
    ProductResult product,
    ProductProvider provider,
  ) {
    final theme = ShadTheme.of(context);
    final isParent = product.groupRole == 'parent';
    final isExpanded = isParent && _expandedParents.contains(product.id);

    if (!isParent || !isExpanded) {
      return _buildProductRow(product, provider);
    }

    final isLoading = _loadingParents.contains(product.id);
    final children = _childrenCache[product.id];
    final error = _childrenError[product.id];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildProductRow(product, provider),
        Container(
          color: theme.colorScheme.muted.withValues(alpha: 0.18),
          child: Column(
            children: [
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.circleAlert,
                        size: 14,
                        color: AppTheme.dangerColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.dangerColor,
                          ),
                        ),
                      ),
                      ShadButton.ghost(
                        size: ShadButtonSize.sm,
                        onPressed: () {
                          _childrenCache.remove(product.id);
                          _toggleParentExpansion(product.id!);
                          // Re-toggle to retry: first call collapsed, second
                          // call re-expands and re-fetches.
                          _toggleParentExpansion(product.id!);
                        },
                        child: const Text(
                          'Retry',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                )
              else if ((children ?? const []).isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Text(
                    'No variations yet.',
                    style: theme.textTheme.muted.copyWith(fontSize: 12),
                  ),
                )
              else
                ...children!.map(
                  (child) => _buildVariantChildRow(
                    child,
                    parentId: product.id!,
                    theme: theme,
                    provider: provider,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Slim, indented row for a variant child shown beneath its expanded parent.
  /// We keep the columns roughly aligned with the main table but skip a few
  /// (Category/HSN are inherited from the parent and would just repeat).
  Widget _buildVariantChildRow(
    VariantGroupMember child, {
    required int parentId,
    required ShadThemeData theme,
    required ProductProvider provider,
  }) {
    final colorLabel = (child.variantOptionColor?.trim().isNotEmpty ?? false)
        ? child.variantOptionColor!
        : (child.color?.trim().isNotEmpty ?? false)
        ? child.color!
        : null;
    final sizeLabel = child.variantOptionSize?.trim().isNotEmpty ?? false
        ? child.variantOptionSize
        : null;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.border.withValues(alpha: 0.6),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Indent + thumbnail + name (matches parent's flex: 6 column)
          Expanded(
            flex: 6,
            child: Row(
              children: [
                const SizedBox(width: 22), // align with parent's chevron slot
                Container(
                  width: 16,
                  height: 1,
                  color: theme.colorScheme.border,
                ),
                const SizedBox(width: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: 28,
                    height: 28,
                    color: theme.colorScheme.muted,
                    child: child.thumbnailImage != null
                        ? Image.network(
                            ApiConstants.getImageUrl(child.thumbnailImage),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(LucideIcons.image, size: 12),
                          )
                        : Icon(
                            LucideIcons.image,
                            size: 12,
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
                        child.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.small.copyWith(fontSize: 12),
                      ),
                      if ([
                        colorLabel,
                        sizeLabel,
                      ].whereType<String>().isNotEmpty)
                        Text(
                          [
                            colorLabel,
                            sizeLabel,
                          ].whereType<String>().join(' • '),
                          style: theme.textTheme.muted.copyWith(fontSize: 11),
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
              child.sku ?? '-',
              style: theme.textTheme.muted.copyWith(fontSize: 11),
            ),
          ),

          // Category / HSN — empty for children (inherited from parent)
          Expanded(flex: 2, child: const SizedBox.shrink()),
          Expanded(flex: 2, child: const SizedBox.shrink()),

          // Color
          Expanded(
            flex: 2,
            child: colorLabel == null
                ? Text('-', style: theme.textTheme.muted.copyWith(fontSize: 11))
                : Row(
                    children: [
                      _ColorSwatch(label: colorLabel),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          colorLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.muted.copyWith(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
          ),

          // Price
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${child.sellingPrice.toStringAsFixed(0)}',
                      style: theme.textTheme.small.copyWith(fontSize: 12),
                    ),
                    if (child.mrpPrice > child.sellingPrice)
                      Text(
                        '₹${child.mrpPrice.toStringAsFixed(0)}',
                        style: theme.textTheme.muted.copyWith(
                          fontSize: 10,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _showPriceEditDialogFor(
                    id: child.id,
                    name: child.name ?? '',
                    currentMrp: child.mrpPrice,
                    currentSelling: child.sellingPrice,
                    provider: provider,
                    onSaved: () => _refreshChildren(parentId),
                  ),
                  child: Icon(
                    LucideIcons.pencil,
                    size: 12,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),

          // Stock
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(
                  '${child.stockQuantity}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: child.stockQuantity <= 5
                        ? AppTheme.dangerColor
                        : theme.colorScheme.foreground,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _showStockEditDialogFor(
                    id: child.id,
                    name: child.name ?? '',
                    currentStock: child.stockQuantity,
                    provider: provider,
                    onSaved: () => _refreshChildren(parentId),
                  ),
                  child: Icon(
                    LucideIcons.pencil,
                    size: 12,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),

          // Status
          Expanded(
            flex: 1,
            child: StatusBadge(status: child.status ?? 'active'),
          ),

          // Trailing controls — keep widths consistent with the parent row
          // (featured slot + click-to-edit + actions popup).
          const SizedBox(width: 18),
          GestureDetector(
            onTap: () => context.go('/admin/products/edit/${child.id}'),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  LucideIcons.mousePointerClick,
                  size: 16,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: PopupMenuButton<String>(
              icon: Icon(
                LucideIcons.ellipsis,
                size: 16,
                color: theme.colorScheme.mutedForeground,
              ),
              padding: EdgeInsets.zero,
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    context.go('/admin/products/edit/${child.id}');
                  case 'activate':
                    provider.updateProductStatus(
                      id: child.id,
                      status: 'active',
                    );
                  case 'deactivate':
                    provider.updateProductStatus(
                      id: child.id,
                      status: 'inactive',
                    );
                }
              },
              itemBuilder: (_) {
                final isActive = (child.status ?? 'active') == 'active';
                return [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(LucideIcons.pencil, size: 14),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  if (isActive)
                    const PopupMenuItem(
                      value: 'deactivate',
                      child: Row(
                        children: [
                          Icon(LucideIcons.circleOff, size: 14),
                          SizedBox(width: 8),
                          Text('Set Inactive'),
                        ],
                      ),
                    )
                  else
                    const PopupMenuItem(
                      value: 'activate',
                      child: Row(
                        children: [
                          Icon(LucideIcons.circleCheck, size: 14),
                          SizedBox(width: 8),
                          Text('Set Active'),
                        ],
                      ),
                    ),
                ];
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showStockEditDialog(
    BuildContext context,
    ProductResult product,
    ProductProvider provider,
  ) {
    _showStockEditDialogFor(
      id: product.id!,
      name: product.name ?? '',
      currentStock: product.stockQuantity ?? 0,
      provider: provider,
    );
  }

  void _showStockEditDialogFor({
    required int id,
    required String name,
    required int currentStock,
    required ProductProvider provider,
    VoidCallback? onSaved,
  }) {
    final stockController = TextEditingController(
      text: currentStock.toString(),
    );

    showShadDialog(
      context: context,
      builder: (ctx) => ShadDialog(
        title: const Text('Edit Stock'),
        description: Text(name),
        actions: [
          ShadButton.outline(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ShadButton(
            child: const Text('Save'),
            onPressed: () async {
              final qty = int.tryParse(stockController.text);
              if (qty == null) return;
              Navigator.of(ctx).pop();
              await provider.updateStock(id: id, stockQuantity: qty);
              onSaved?.call();
            },
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text('Stock Quantity'),
            const SizedBox(height: 6),
            ShadInput(
              controller: stockController,
              placeholder: const Text('Enter stock quantity'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showPriceEditDialog(
    BuildContext context,
    ProductResult product,
    ProductProvider provider,
  ) {
    _showPriceEditDialogFor(
      id: product.id!,
      name: product.name ?? '',
      currentMrp: product.mrpPrice ?? 0,
      currentSelling: product.sellingPrice ?? 0,
      provider: provider,
    );
  }

  void _showPriceEditDialogFor({
    required int id,
    required String name,
    required double currentMrp,
    required double currentSelling,
    required ProductProvider provider,
    VoidCallback? onSaved,
  }) {
    final mrpController = TextEditingController(
      text: currentMrp.toStringAsFixed(0),
    );
    final sellingController = TextEditingController(
      text: currentSelling.toStringAsFixed(0),
    );

    showShadDialog(
      context: context,
      builder: (ctx) => ShadDialog(
        title: const Text('Edit Price'),
        description: Text(name),
        actions: [
          ShadButton.outline(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ShadButton(
            child: const Text('Save'),
            onPressed: () async {
              final mrp = double.tryParse(mrpController.text);
              final selling = double.tryParse(sellingController.text);
              if (mrp == null || selling == null) return;
              Navigator.of(ctx).pop();
              await provider.updatePrice(
                id: id,
                mrpPrice: mrp,
                sellingPrice: selling,
              );
              onSaved?.call();
            },
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text('MRP (₹)'),
            const SizedBox(height: 6),
            ShadInput(
              controller: mrpController,
              placeholder: const Text('Enter MRP'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            const Text('Selling Price (₹)'),
            const SizedBox(height: 6),
            ShadInput(
              controller: sellingController,
              placeholder: const Text('Enter selling price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─── Add Variant entry-point ───────────────────────────────────────────────
  //
  // Opens a picker that lists ALL standalone products (across categories)
  // plus existing parents. When the user picks one, we navigate to its
  // variations screen — that page handles the same-category eligibility
  // and SKU picker for adding children.
  Future<void> _openAddVariantPicker(
    BuildContext context,
    ProductProvider provider,
  ) async {
    final picked = await showDialog<ProductResult>(
      context: context,
      builder: (_) => _AddVariantPickerDialog(products: provider.products),
    );
    if (picked == null || picked.id == null) return;
    if (!context.mounted) return;
    context.push('/admin/products/${picked.id}/variations');
  }
}

// ─── Color swatch helper ─────────────────────────────────────────────────────
//
// Tries to map a free-text colour label (e.g. "Midnight Black", "Pearl White")
// to a Flutter Color so we can render a tiny circle next to the label. Falls
// back to a neutral grey when the label doesn't match anything obvious.
class _ColorSwatch extends StatelessWidget {
  final String label;
  const _ColorSwatch({required this.label});

  static const Map<String, Color> _palette = {
    'black': Color(0xFF111827),
    'midnight': Color(0xFF111827),
    'white': Color(0xFFF3F4F6),
    'pearl': Color(0xFFF3F4F6),
    'red': Color(0xFFEF4444),
    'crimson': Color(0xFFB91C1C),
    'sunset': Color(0xFFF97316),
    'orange': Color(0xFFF97316),
    'yellow': Color(0xFFFACC15),
    'gold': Color(0xFFD97706),
    'green': Color(0xFF10B981),
    'emerald': Color(0xFF10B981),
    'olive': Color(0xFF65A30D),
    'blue': Color(0xFF3B82F6),
    'ocean': Color(0xFF0EA5E9),
    'navy': Color(0xFF1E3A8A),
    'sky': Color(0xFF38BDF8),
    'purple': Color(0xFFA855F7),
    'violet': Color(0xFF8B5CF6),
    'pink': Color(0xFFEC4899),
    'rose': Color(0xFFF43F5E),
    'brown': Color(0xFF92400E),
    'beige': Color(0xFFE7DAC9),
    'grey': Color(0xFF9CA3AF),
    'gray': Color(0xFF9CA3AF),
    'silver': Color(0xFFD1D5DB),
  };

  Color _resolve() {
    final lower = label.toLowerCase();
    for (final entry in _palette.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return const Color(0xFF9CA3AF);
  }

  @override
  Widget build(BuildContext context) {
    final color = _resolve();
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.borderColor),
      ),
    );
  }
}

// ─── Add Variant picker dialog ───────────────────────────────────────────────
//
// Simple chooser: pick the product you want to attach a variant to. We only
// surface standalone or parent products — children are owned by an existing
// group and the variations screen would just redirect to the parent anyway.
class _AddVariantPickerDialog extends StatefulWidget {
  final List<ProductResult> products;
  const _AddVariantPickerDialog({required this.products});

  @override
  State<_AddVariantPickerDialog> createState() =>
      _AddVariantPickerDialogState();
}

class _AddVariantPickerDialogState extends State<_AddVariantPickerDialog> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final visible = widget.products.where((p) {
      // Only standalone or parents — children can't open the variations page.
      final role = p.groupRole ?? 'standalone';
      if (role == 'child') return false;
      if (_q.isEmpty) return true;
      final n = (p.name ?? '').toLowerCase();
      final s = (p.sku ?? '').toLowerCase();
      return n.contains(_q) || s.contains(_q);
    }).toList();

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    'Add variant',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Pick the product you want to attach a variation to. You\'ll be taken to its variations screen next.',
                style: theme.textTheme.muted.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 16),
              ShadInput(
                controller: _searchCtrl,
                placeholder: const Text('Search by name or SKU…'),
                onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: visible.isEmpty
                    ? Center(
                        child: Text(
                          'No matching products.',
                          style: theme.textTheme.muted,
                        ),
                      )
                    : ListView.separated(
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 6),
                        itemBuilder: (_, i) {
                          final p = visible[i];
                          final isParent = p.groupRole == 'parent';
                          return InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => Navigator.of(context).pop(p),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.borderColor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      color: theme.colorScheme.muted,
                                      child: p.thumbnailImage != null
                                          ? Image.network(
                                              ApiConstants.getImageUrl(
                                                p.thumbnailImage,
                                              ),
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) =>
                                                  const Icon(
                                                    LucideIcons.image,
                                                    size: 16,
                                                  ),
                                            )
                                          : const Icon(
                                              LucideIcons.image,
                                              size: 16,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                p.name ?? '(unnamed)',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            if (isParent) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.brand
                                                      .withValues(alpha: 0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  'PARENT',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppTheme.brand,
                                                    letterSpacing: 0.6,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        if (p.sku != null)
                                          Text(
                                            p.sku!,
                                            style: theme.textTheme.muted
                                                .copyWith(fontSize: 11),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    LucideIcons.chevronRight,
                                    size: 16,
                                    color: AppTheme.textMuted,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
