import 'dart:convert';
import '../core/utils/parsers.dart';

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

    return ProductModel(
      id: parseInt(json['id']),
      categoryId: parseInt(json['categoryId']),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
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
      totalViews: parseInt(json['totalViews']),
      totalSales: parseInt(json['totalSales']),
      categoryName: json['categoryName']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  double get discount =>
      mrpPrice > 0 ? ((mrpPrice - sellingPrice) / mrpPrice * 100) : 0;
  bool get isLowStock => stockQuantity <= minStockAlert;
}
