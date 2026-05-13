import '../core/utils/parsers.dart';

class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String? image;
  final String? description;
  final String status;
  final int productCount;
  final String? createdAt;
  final String? updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    this.description,
    this.status = 'active',
    this.productCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      image: json['image']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString() ?? 'active',
      productCount: parseInt(json['productCount']),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }
}
