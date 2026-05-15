import 'package:json_annotation/json_annotation.dart';

part 'price_update_request.g.dart';

@JsonSerializable()
class PriceUpdateRequest {
  final double mrpPrice;
  final double sellingPrice;

  PriceUpdateRequest({required this.mrpPrice, required this.sellingPrice});

  factory PriceUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$PriceUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PriceUpdateRequestToJson(this);
}
