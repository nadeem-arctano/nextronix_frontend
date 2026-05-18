import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

class ProductRequest {
  final String name;
  final int categoryId;
  final int? hsnId;
  final String? shortDescription;
  final String? fullDescription;
  final String? sku;
  final String? barcode;
  final String? tags;
  final double mrpPrice;
  final double sellingPrice;
  final double? gstPercent;
  final int? stockQuantity;
  final int? minStockAlert;
  final String? weight;
  final String? dimensions;
  final int? colorId;
  final int? materialTypeId;
  final String? warranty;
  final String status;
  final bool isFeatured;
  final PlatformFile? thumbnailFile;
  final List<PlatformFile> galleryFiles;

  ProductRequest({
    required this.name,
    required this.categoryId,
    this.hsnId,
    this.shortDescription,
    this.fullDescription,
    this.sku,
    this.barcode,
    this.tags,
    required this.mrpPrice,
    required this.sellingPrice,
    this.gstPercent,
    this.stockQuantity,
    this.minStockAlert,
    this.weight,
    this.dimensions,
    this.colorId,
    this.materialTypeId,
    this.warranty,
    this.status = 'active',
    this.isFeatured = false,
    this.thumbnailFile,
    this.galleryFiles = const [],
  });

  Future<FormData> toFormData() async {
    final map = <String, dynamic>{
      'name': name,
      'categoryId': categoryId,
      'mrpPrice': mrpPrice,
      'sellingPrice': sellingPrice,
      'status': status,
      'isFeatured': isFeatured,
    };

    if (hsnId != null) map['hsnId'] = hsnId;
    if (shortDescription != null && shortDescription!.isNotEmpty) {
      map['shortDescription'] = shortDescription;
    }
    if (fullDescription != null && fullDescription!.isNotEmpty) {
      map['fullDescription'] = fullDescription;
    }
    if (sku != null && sku!.isNotEmpty) map['sku'] = sku;
    if (barcode != null && barcode!.isNotEmpty) map['barcode'] = barcode;
    if (tags != null && tags!.isNotEmpty) map['tags'] = tags;
    if (gstPercent != null) map['gstPercent'] = gstPercent;
    if (stockQuantity != null) map['stockQuantity'] = stockQuantity;
    if (minStockAlert != null) map['minStockAlert'] = minStockAlert;
    if (weight != null && weight!.isNotEmpty) map['weight'] = weight;
    if (dimensions != null && dimensions!.isNotEmpty) {
      map['dimensions'] = dimensions;
    }
    if (colorId != null) map['colorId'] = colorId;
    if (materialTypeId != null) map['materialTypeId'] = materialTypeId;
    if (warranty != null && warranty!.isNotEmpty) map['warranty'] = warranty;

    final formData = FormData.fromMap(map);

    // Thumbnail
    if (thumbnailFile != null && thumbnailFile!.bytes != null) {
      formData.files.add(
        MapEntry(
          'thumbnailImage',
          MultipartFile.fromBytes(
            thumbnailFile!.bytes!,
            filename: thumbnailFile!.name,
          ),
        ),
      );
    }

    // Gallery
    for (final file in galleryFiles) {
      if (file.bytes != null) {
        formData.files.add(
          MapEntry(
            'galleryImages',
            MultipartFile.fromBytes(file.bytes!, filename: file.name),
          ),
        );
      }
    }

    return formData;
  }
}
