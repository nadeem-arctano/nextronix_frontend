import '../../core/utils/parsers.dart';

class AddressResult {
  final int? id;
  final int? userId;
  final String? fullName;
  final String? mobile;
  final String? pincode;
  final String? state;
  final String? city;
  final String? addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String? addressType;

  AddressResult({
    this.id,
    this.userId,
    this.fullName,
    this.mobile,
    this.pincode,
    this.state,
    this.city,
    this.addressLine1,
    this.addressLine2,
    this.landmark,
    this.addressType,
  });

  factory AddressResult.fromJson(Map<String, dynamic> json) => AddressResult(
    id: parseInt(json['id']),
    userId: parseInt(json['userId']),
    fullName: json['fullName']?.toString(),
    mobile: json['mobile']?.toString(),
    pincode: json['pincode']?.toString(),
    state: json['state']?.toString(),
    city: json['city']?.toString(),
    addressLine1: json['addressLine1']?.toString(),
    addressLine2: json['addressLine2']?.toString(),
    landmark: json['landmark']?.toString(),
    addressType: json['addressType']?.toString() ?? 'home',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "fullName": fullName,
    "mobile": mobile,
    "pincode": pincode,
    "state": state,
    "city": city,
    "addressLine1": addressLine1,
    "addressLine2": addressLine2,
    "landmark": landmark,
    "addressType": addressType,
  };

  String get fullAddress {
    final parts = <String>[];
    if (addressLine1 != null && addressLine1!.isNotEmpty) {
      parts.add(addressLine1!);
    }
    if (addressLine2 != null && addressLine2!.isNotEmpty) {
      parts.add(addressLine2!);
    }
    if (landmark != null && landmark!.isNotEmpty) parts.add(landmark!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (pincode != null && pincode!.isNotEmpty) parts.add(pincode!);
    return parts.join(', ');
  }
}
