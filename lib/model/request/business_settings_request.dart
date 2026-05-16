/// Request body sent to PUT /api/business-settings.
/// Only non-null fields are included so the server preserves existing values.
class BusinessSettingsRequest {
  final Map<String, dynamic> _data = {};

  BusinessSettingsRequest set(String key, dynamic value) {
    if (value != null) _data[key] = value;
    return this;
  }

  Map<String, dynamic> toJson() => _data;
}
