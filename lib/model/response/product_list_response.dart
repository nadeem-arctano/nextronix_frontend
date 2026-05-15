import 'dart:convert';
import '../../core/utils/parsers.dart';

class ProductListResponse {
  final int? statusCode;
  final String? message;
  final List<ProductResult>? data;
  final PaginationResult? pagination;

  ProductListResponse({
    this.statusCode,
    this.message,
    this.data,
    this.pagination,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) =>
      ProductListResponse(
        statusCode: json["status_code"] ?? json["statusCode"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : List<ProductResult>.from(
                (json["data"] as List).map((e) => ProductResult.fromJson(e)),
              ),
        pagination: json["pagination"] == null
            ? null
            : PaginationResult.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "message": message,
    "data": data?.map((e) => e.toJson()).toList(),
    "pagination": pagination?.toJson(),
  };
}

class ProductResult {
  final int? id;
  final int? categoryId;
  final int? hsnId;
  final String? name;
  final String? slug;
  final String? shortDescription;
  final String? fullDescription;
  final String? brand;
  final String? sku;
  final String? barcode;
  final String? tags;
  final String? thumbnailImage;
  final List<String>? galleryImages;
  final double? mrpPrice;
  final double? sellingPrice;
  final double? gstPercent;
  final int? stockQuantity;
  final int? minStockAlert;
  final String? weight;
  final String? dimensions;
  final String? color;
  final String? material;
  final String? warranty;
  final String? status;
  final bool? isFeatured;
  final bool? hasVariants;
  final int? totalViews;
  final int? totalSales;
  final String? categoryName;
  final String? hsnCode;
  final double? hsnGstPercent;
  final String? createdAt;
  final String? updatedAt;

  ProductResult({
    this.id,
    this.categoryId,
    this.hsnId,
    this.name,
    this.slug,
    this.shortDescription,
    this.fullDescription,
    this.brand,
    this.sku,
    this.barcode,
    this.tags,
    this.thumbnailImage,
    this.galleryImages,
    this.mrpPrice,
    this.sellingPrice,
    this.gstPercent,
    this.stockQuantity,
    this.minStockAlert,
    this.weight,
    this.dimensions,
    this.color,
    this.material,
    this.warranty,
    this.status,
    this.isFeatured,
    this.hasVariants,
    this.totalViews,
    this.totalSales,
    this.categoryName,
    this.hsnCode,
    this.hsnGstPercent,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductResult.fromJson(Map<String, dynamic> json) {
    List<String>? gallery;
    final rawGallery = json['galleryImages'];
    if (rawGallery != null) {
      try {
        if (rawGallery is String && rawGallery.isNotEmpty) {
          final decoded = jsonDecode(rawGallery);
          if (decoded is List) {
            gallery = decoded.map((e) => e.toString()).toList();
          }
        } else if (rawGallery is List) {
          gallery = rawGallery.map((e) => e.toString()).toList();
        }
      } catch (_) {
        gallery = null;
      }
    }

    return ProductResult(
      id: parseInt(json['id']),
      categoryId: parseInt(json['categoryId']),
      hsnId: json['hsnId'] != null ? parseInt(json['hsnId']) : null,
      name: json['name']?.toString(),
      slug: json['slug']?.toString(),
      shortDescription: json['shortDescription']?.toString(),
      fullDescription: json['fullDescription']?.toString(),
      brand: json['brand']?.toString(),
      sku: json['sku']?.toString(),
      barcode: json['barcode']?.toString(),
      tags: json['tags']?.toString(),
      thumbnailImage: json['thumbnailImage']?.toString(),
      galleryImages: gallery,
      mrpPrice: parseDouble(json['mrpPrice']),
      sellingPrice: parseDouble(json['sellingPrice']),
      gstPercent: parseDouble(json['gstPercent']),
      stockQuantity: parseInt(json['stockQuantity']),
      minStockAlert: parseInt(json['minStockAlert'], defaultValue: 5),
      weight: json['weight']?.toString(),
      dimensions: json['dimensions']?.toString(),
      color: json['color']?.toString(),
      material: json['material']?.toString(),
      warranty: json['warranty']?.toString(),
      status: json['status']?.toString() ?? 'active',
      isFeatured: parseBool(json['isFeatured']),
      hasVariants: parseBool(json['hasVariants']),
      totalViews: parseInt(json['totalViews']),
      totalSales: parseInt(json['totalSales']),
      categoryName: json['categoryName']?.toString(),
      hsnCode: json['hsnCode']?.toString(),
      hsnGstPercent: json['hsnGstPercent'] != null
          ? parseDouble(json['hsnGstPercent'])
          : null,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "categoryId": categoryId,
    "name": name,
    "slug": slug,
    "shortDescription": shortDescription,
    "fullDescription": fullDescription,
    "brand": brand,
    "sku": sku,
    "barcode": barcode,
    "tags": tags,
    "thumbnailImage": thumbnailImage,
    "galleryImages": galleryImages,
    "mrpPrice": mrpPrice,
    "sellingPrice": sellingPrice,
    "gstPercent": gstPercent,
    "stockQuantity": stockQuantity,
    "minStockAlert": minStockAlert,
    "weight": weight,
    "dimensions": dimensions,
    "color": color,
    "material": material,
    "warranty": warranty,
    "status": status,
    "isFeatured": isFeatured,
    "totalViews": totalViews,
    "totalSales": totalSales,
    "categoryName": categoryName,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };

  double get discount => (mrpPrice ?? 0) > 0
      ? (((mrpPrice ?? 0) - (sellingPrice ?? 0)) / (mrpPrice ?? 1) * 100)
      : 0;

  bool get isLowStock => (stockQuantity ?? 0) <= (minStockAlert ?? 5);

  ProductResult copyWith({
    double? mrpPrice,
    double? sellingPrice,
    int? stockQuantity,
    String? status,
    bool? isFeatured,
  }) {
    return ProductResult(
      id: id,
      categoryId: categoryId,
      hsnId: hsnId,
      name: name,
      slug: slug,
      shortDescription: shortDescription,
      fullDescription: fullDescription,
      brand: brand,
      sku: sku,
      barcode: barcode,
      tags: tags,
      thumbnailImage: thumbnailImage,
      galleryImages: galleryImages,
      mrpPrice: mrpPrice ?? this.mrpPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      gstPercent: gstPercent,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockAlert: minStockAlert,
      weight: weight,
      dimensions: dimensions,
      color: color,
      material: material,
      warranty: warranty,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      hasVariants: hasVariants,
      totalViews: totalViews,
      totalSales: totalSales,
      categoryName: categoryName,
      hsnCode: hsnCode,
      hsnGstPercent: hsnGstPercent,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class PaginationResult {
  final int? currentPage;
  final int? totalPages;
  final int? totalItems;

  PaginationResult({this.currentPage, this.totalPages, this.totalItems});

  factory PaginationResult.fromJson(Map<String, dynamic> json) =>
      PaginationResult(
        currentPage: parseInt(json['currentPage'], defaultValue: 1),
        totalPages: parseInt(json['totalPages'], defaultValue: 1),
        totalItems: parseInt(json['totalItems']),
      );

  Map<String, dynamic> toJson() => {
    "currentPage": currentPage,
    "totalPages": totalPages,
    "totalItems": totalItems,
  };
}
