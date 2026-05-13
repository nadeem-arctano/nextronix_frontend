class ProductModel {
  final int id;
  final int categoryId;
  final String name;
  final String slug;
  final String? shortDescription;
  final String? fullDescription;
  final String? brand;
  final String? sku;
  final String? barcode;
  final String? tags;
  final String? thumbnailImage;
  final List<String>? galleryImages;
  final double mrpPrice;
  final double sellingPrice;
  final double gstPercent;
  final int stockQuantity;
  final int minStockAlert;
  final String? weight;
  final String? dimensions;
  final String? color;
  final String? material;
  final String? warranty;
  final String status;
  final bool isFeatured;
  final int totalViews;
  final int totalSales;
  final String? categoryName;
  final String? createdAt;
  final String? updatedAt;

  ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
    this.shortDescription,
    this.fullDescription,
    this.brand,
    this.sku,
    this.barcode,
    this.tags,
    this.thumbnailImage,
    this.galleryImages,
    required this.mrpPrice,
    required this.sellingPrice,
    this.gstPercent = 0,
    this.stockQuantity = 0,
    this.minStockAlert = 5,
    this.weight,
    this.dimensions,
    this.color,
    this.material,
    this.warranty,
    this.status = 'active',
    this.isFeatured = false,
    this.totalViews = 0,
    this.totalSales = 0,
    this.categoryName,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    List<String>? gallery;
    if (json['galleryImages'] != null) {
      if (json['galleryImages'] is String) {
        try {
          final List<dynamic> parsed = List<dynamic>.from(
            json['galleryImages'] is String ? [] : json['galleryImages'],
          );
          gallery = parsed.map((e) => e.toString()).toList();
        } catch (_) {
          gallery = null;
        }
      } else if (json['galleryImages'] is List) {
        gallery = (json['galleryImages'] as List)
            .map((e) => e.toString())
            .toList();
      }
    }

    return ProductModel(
      id: json['id'] ?? 0,
      categoryId: json['categoryId'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      shortDescription: json['shortDescription'],
      fullDescription: json['fullDescription'],
      brand: json['brand'],
      sku: json['sku'],
      barcode: json['barcode'],
      tags: json['tags'],
      thumbnailImage: json['thumbnailImage'],
      galleryImages: gallery,
      mrpPrice: (json['mrpPrice'] ?? 0).toDouble(),
      sellingPrice: (json['sellingPrice'] ?? 0).toDouble(),
      gstPercent: (json['gstPercent'] ?? 0).toDouble(),
      stockQuantity: json['stockQuantity'] ?? 0,
      minStockAlert: json['minStockAlert'] ?? 5,
      weight: json['weight'],
      dimensions: json['dimensions'],
      color: json['color'],
      material: json['material'],
      warranty: json['warranty'],
      status: json['status'] ?? 'active',
      isFeatured: json['isFeatured'] == 1 || json['isFeatured'] == true,
      totalViews: json['totalViews'] ?? 0,
      totalSales: json['totalSales'] ?? 0,
      categoryName: json['categoryName'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  double get discount =>
      mrpPrice > 0 ? ((mrpPrice - sellingPrice) / mrpPrice * 100) : 0;
  bool get isLowStock => stockQuantity <= minStockAlert;
}
