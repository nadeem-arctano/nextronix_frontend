import '../../core/utils/parsers.dart';

class CategoryListResponse {
  final int? statusCode;
  final String? message;
  final List<CategoryResult>? data;

  CategoryListResponse({this.statusCode, this.message, this.data});

  factory CategoryListResponse.fromJson(Map<String, dynamic> json) =>
      CategoryListResponse(
        statusCode: json["status_code"] ?? json["statusCode"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : List<CategoryResult>.from(
                (json["data"] as List).map((e) => CategoryResult.fromJson(e)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "message": message,
    "data": data?.map((e) => e.toJson()).toList(),
  };
}

class CategoryResult {
  final int? id;
  final String? name;
  final String? slug;
  final String? image;
  final String? description;
  final String? status;
  final int? productCount;
  final String? createdAt;
  final String? updatedAt;

  CategoryResult({
    this.id,
    this.name,
    this.slug,
    this.image,
    this.description,
    this.status,
    this.productCount,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryResult.fromJson(Map<String, dynamic> json) => CategoryResult(
    id: parseInt(json['id']),
    name: json['name']?.toString(),
    slug: json['slug']?.toString(),
    image: json['image']?.toString(),
    description: json['description']?.toString(),
    status: json['status']?.toString() ?? 'active',
    productCount: parseInt(json['productCount']),
    createdAt: json['createdAt']?.toString(),
    updatedAt: json['updatedAt']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "image": image,
    "description": description,
    "status": status,
    "productCount": productCount,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}
