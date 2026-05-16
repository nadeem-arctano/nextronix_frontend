/// Body of POST /inventory-logs/adjust
class StockAdjustRequest {
  final int productId;
  final int? variantId;
  final int quantityChanged;
  final String reason; // 'manual_add' | 'manual_reduce' | 'adjustment'
  final String? note;

  StockAdjustRequest({
    required this.productId,
    this.variantId,
    required this.quantityChanged,
    required this.reason,
    this.note,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'productId': productId,
      'quantityChanged': quantityChanged,
      'reason': reason,
    };
    if (variantId != null) map['variantId'] = variantId;
    if (note != null) map['note'] = note;
    return map;
  }
}
