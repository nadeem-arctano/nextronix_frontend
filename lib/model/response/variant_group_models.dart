import '../../core/utils/parsers.dart';

/// One product row in a variant group payload (parent or child).
class VariantGroupMember {
  final int id;
  final String? name;
  final String? sku;
  final String? slug;
  final String? thumbnailImage;
  final double mrpPrice;
  final double sellingPrice;
  final int stockQuantity;
  final String? status;
  final int? parentProductId;
  final String groupRole;
  final String? color;
  final String? variantOptionColor;
  final String? variantOptionSize;
  final String? createdAt;

  VariantGroupMember({
    required this.id,
    this.name,
    this.sku,
    this.slug,
    this.thumbnailImage,
    this.mrpPrice = 0,
    this.sellingPrice = 0,
    this.stockQuantity = 0,
    this.status,
    this.parentProductId,
    this.groupRole = 'standalone',
    this.color,
    this.variantOptionColor,
    this.variantOptionSize,
    this.createdAt,
  });

  factory VariantGroupMember.fromJson(Map<String, dynamic> json) =>
      VariantGroupMember(
        id: parseInt(json['id']),
        name: json['name']?.toString(),
        sku: json['sku']?.toString(),
        slug: json['slug']?.toString(),
        thumbnailImage: json['thumbnailImage']?.toString(),
        mrpPrice: parseDouble(json['mrpPrice']),
        sellingPrice: parseDouble(json['sellingPrice']),
        stockQuantity: parseInt(json['stockQuantity']),
        status: json['status']?.toString(),
        parentProductId: json['parentProductId'] != null
            ? parseInt(json['parentProductId'])
            : null,
        groupRole: json['groupRole']?.toString() ?? 'standalone',
        color: json['color']?.toString(),
        variantOptionColor: json['variantOptionColor']?.toString(),
        variantOptionSize: json['variantOptionSize']?.toString(),
        createdAt: json['createdAt']?.toString(),
      );
}

/// Wraps `{ parent, children }` returned by the group endpoints.
class VariantGroup {
  final VariantGroupMember? parent;
  final List<VariantGroupMember> children;

  VariantGroup({this.parent, this.children = const []});

  factory VariantGroup.fromJson(Map<String, dynamic> json) => VariantGroup(
    parent: json['parent'] != null
        ? VariantGroupMember.fromJson(json['parent'])
        : null,
    children: json['children'] != null
        ? (json['children'] as List)
              .map((c) => VariantGroupMember.fromJson(c))
              .toList()
        : const [],
  );
}

class VariantGroupResponse {
  final bool? success;
  final String? message;
  final VariantGroup? data;

  VariantGroupResponse({this.success, this.message, this.data});

  factory VariantGroupResponse.fromJson(Map<String, dynamic> json) =>
      VariantGroupResponse(
        success: json['success'],
        message: json['message']?.toString(),
        data: json['data'] != null ? VariantGroup.fromJson(json['data']) : null,
      );
}

/// `GET /api/products/groupable` — list of standalone products eligible
/// to be added to a group (filtered to a category).
class GroupableProduct {
  final int id;
  final String? name;
  final String? sku;
  final String? thumbnailImage;
  final String? color;
  final double mrpPrice;
  final double sellingPrice;
  final int stockQuantity;

  GroupableProduct({
    required this.id,
    this.name,
    this.sku,
    this.thumbnailImage,
    this.color,
    this.mrpPrice = 0,
    this.sellingPrice = 0,
    this.stockQuantity = 0,
  });

  factory GroupableProduct.fromJson(Map<String, dynamic> json) =>
      GroupableProduct(
        id: parseInt(json['id']),
        name: json['name']?.toString(),
        sku: json['sku']?.toString(),
        thumbnailImage: json['thumbnailImage']?.toString(),
        color: json['color']?.toString(),
        mrpPrice: parseDouble(json['mrpPrice']),
        sellingPrice: parseDouble(json['sellingPrice']),
        stockQuantity: parseInt(json['stockQuantity']),
      );
}

class GroupableListResponse {
  final bool? success;
  final String? message;
  final List<GroupableProduct>? data;

  GroupableListResponse({this.success, this.message, this.data});

  factory GroupableListResponse.fromJson(Map<String, dynamic> json) =>
      GroupableListResponse(
        success: json['success'],
        message: json['message']?.toString(),
        data: json['data'] != null
            ? (json['data'] as List)
                  .map((e) => GroupableProduct.fromJson(e))
                  .toList()
            : null,
      );
}
