// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockUpdateRequest _$StockUpdateRequestFromJson(Map<String, dynamic> json) =>
    StockUpdateRequest(
      stockQuantity: (json['stockQuantity'] as num).toInt(),
    );

Map<String, dynamic> _$StockUpdateRequestToJson(StockUpdateRequest instance) =>
    <String, dynamic>{
      'stockQuantity': instance.stockQuantity,
    };
