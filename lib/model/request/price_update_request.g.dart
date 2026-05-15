// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PriceUpdateRequest _$PriceUpdateRequestFromJson(Map<String, dynamic> json) =>
    PriceUpdateRequest(
      mrpPrice: (json['mrpPrice'] as num).toDouble(),
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
    );

Map<String, dynamic> _$PriceUpdateRequestToJson(PriceUpdateRequest instance) =>
    <String, dynamic>{
      'mrpPrice': instance.mrpPrice,
      'sellingPrice': instance.sellingPrice,
    };
