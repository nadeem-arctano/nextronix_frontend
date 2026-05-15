import 'package:json_annotation/json_annotation.dart';

part 'stock_update_request.g.dart';

@JsonSerializable()
class StockUpdateRequest {
  final int stockQuantity;

  StockUpdateRequest({required this.stockQuantity});

  factory StockUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$StockUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$StockUpdateRequestToJson(this);
}
