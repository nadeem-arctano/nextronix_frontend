import '../../core/utils/parsers.dart';

class ProductVariant {
  final int id;
  final int? adminId;
  final int productId;
  final String? variantName;
  final String? color;
  final String? size;
  final String? sku;
  final String? barcode;
  final double mrp;
  final double sellingPrice;
  final int stock;
  final int minStockAlert;
  final String? weight;
  final String? image;
  final String status;
  final bool isDefault;
  final String? createdAt;
  final String? updatedAt;

  ProductVariant({
    required this.id,
    this.adminId,
    required this.productId,
    this.variantName,
    this.color,
    this.size,
    this.sku,
    this.barcode,
    this.mrp = 0,
    this.sellingPrice = 0,
    this.stock = 0,
    this.minStockAlert = 5,
    this.weight,
    this.image,
    this.status = 'active',
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
    id: parseInt(json['id']),
    adminId: json['adminId'] != null ? parseInt(json['adminId']) : null,
    productId: parseInt(json['productId']),
    variantName: json['variantName']?.toString(),
    color: json['color']?.toString(),
    size: json['size']?.toString(),
    sku: json['sku']?.toString(),
    barcode: json['barcode']?.toString(),
    mrp: parseDouble(json['mrp']),
    sellingPrice: parseDouble(json['sellingPrice']),
    stock: parseInt(json['stock']),
    minStockAlert: parseInt(json['minStockAlert'], defaultValue: 5),
    weight: json['weight']?.toString(),
    image: json['image']?.toString(),
    status: json['status']?.toString() ?? 'active',
    isDefault: parseBool(json['isDefault']),
    createdAt: json['createdAt']?.toString(),
    updatedAt: json['updatedAt']?.toString(),
  );
}

class VariantListResponse {
  final bool? success;
  final String? message;
  final List<ProductVariant>? data;

  VariantListResponse({this.success, this.message, this.data});

  factory VariantListResponse.fromJson(Map<String, dynamic> json) =>
      VariantListResponse(
        success: json['success'],
        message: json['message']?.toString(),
        data: json['data'] != null
            ? (json['data'] as List)
                  .map((e) => ProductVariant.fromJson(e))
                  .toList()
            : null,
      );
}

class VariantDetailResponse {
  final bool? success;
  final String? message;
  final ProductVariant? data;

  VariantDetailResponse({this.success, this.message, this.data});

  factory VariantDetailResponse.fromJson(Map<String, dynamic> json) =>
      VariantDetailResponse(
        success: json['success'],
        message: json['message']?.toString(),
        data: json['data'] != null
            ? ProductVariant.fromJson(json['data'])
            : null,
      );
}
