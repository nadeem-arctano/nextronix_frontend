import '../../core/utils/parsers.dart';

class BusinessSettingsResponse {
  final bool? success;
  final String? message;
  final BusinessSettings? data;

  BusinessSettingsResponse({this.success, this.message, this.data});

  factory BusinessSettingsResponse.fromJson(Map<String, dynamic> json) =>
      BusinessSettingsResponse(
        success: json['success'],
        message: json['message']?.toString(),
        data: json['data'] != null
            ? BusinessSettings.fromJson(json['data'])
            : null,
      );
}

class BusinessSettings {
  // Business info
  final String? businessName;
  final String? legalBusinessName;
  final String? gstNumber;
  final String? panNumber;
  final String? websiteUrl;

  // Contact
  final String? businessEmail;
  final String? businessPhone;
  final String? supportEmail;
  final String? supportPhone;

  // Address
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;

  // Branding
  final String? logo;
  final String? favicon;

  // Bank
  final String? accountHolderName;
  final String? bankName;
  final String? accountNumberMasked;
  final bool accountNumberSet;
  final String? ifscCode;
  final String? branchName;

  // Payment gateway
  final String? upiId;
  final String? razorpayKey;
  final String? razorpaySecretMasked;
  final bool razorpaySecretSet;
  final String? stripePublicKey;
  final String? stripeSecretKeyMasked;
  final bool stripeSecretKeySet;

  // Invoice
  final String? invoicePrefix;
  final int? invoiceStartNumber;
  final double? gstPercentage;
  final String? invoiceFooter;
  final String? invoiceTerms;

  // Social
  final String? instagramUrl;
  final String? facebookUrl;
  final String? youtubeUrl;
  final String? twitterUrl;

  BusinessSettings({
    this.businessName,
    this.legalBusinessName,
    this.gstNumber,
    this.panNumber,
    this.websiteUrl,
    this.businessEmail,
    this.businessPhone,
    this.supportEmail,
    this.supportPhone,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.logo,
    this.favicon,
    this.accountHolderName,
    this.bankName,
    this.accountNumberMasked,
    this.accountNumberSet = false,
    this.ifscCode,
    this.branchName,
    this.upiId,
    this.razorpayKey,
    this.razorpaySecretMasked,
    this.razorpaySecretSet = false,
    this.stripePublicKey,
    this.stripeSecretKeyMasked,
    this.stripeSecretKeySet = false,
    this.invoicePrefix,
    this.invoiceStartNumber,
    this.gstPercentage,
    this.invoiceFooter,
    this.invoiceTerms,
    this.instagramUrl,
    this.facebookUrl,
    this.youtubeUrl,
    this.twitterUrl,
  });

  factory BusinessSettings.fromJson(Map<String, dynamic> json) =>
      BusinessSettings(
        businessName: json['businessName']?.toString(),
        legalBusinessName: json['legalBusinessName']?.toString(),
        gstNumber: json['gstNumber']?.toString(),
        panNumber: json['panNumber']?.toString(),
        websiteUrl: json['websiteUrl']?.toString(),
        businessEmail: json['businessEmail']?.toString(),
        businessPhone: json['businessPhone']?.toString(),
        supportEmail: json['supportEmail']?.toString(),
        supportPhone: json['supportPhone']?.toString(),
        addressLine1: json['addressLine1']?.toString(),
        addressLine2: json['addressLine2']?.toString(),
        city: json['city']?.toString(),
        state: json['state']?.toString(),
        country: json['country']?.toString(),
        pincode: json['pincode']?.toString(),
        logo: json['logo']?.toString(),
        favicon: json['favicon']?.toString(),
        accountHolderName: json['accountHolderName']?.toString(),
        bankName: json['bankName']?.toString(),
        accountNumberMasked: json['accountNumberMasked']?.toString(),
        accountNumberSet: parseBool(json['accountNumberSet']),
        ifscCode: json['ifscCode']?.toString(),
        branchName: json['branchName']?.toString(),
        upiId: json['upiId']?.toString(),
        razorpayKey: json['razorpayKey']?.toString(),
        razorpaySecretMasked: json['razorpaySecretMasked']?.toString(),
        razorpaySecretSet: parseBool(json['razorpaySecretSet']),
        stripePublicKey: json['stripePublicKey']?.toString(),
        stripeSecretKeyMasked: json['stripeSecretKeyMasked']?.toString(),
        stripeSecretKeySet: parseBool(json['stripeSecretKeySet']),
        invoicePrefix: json['invoicePrefix']?.toString(),
        invoiceStartNumber: json['invoiceStartNumber'] != null
            ? parseInt(json['invoiceStartNumber'])
            : null,
        gstPercentage: json['gstPercentage'] != null
            ? parseDouble(json['gstPercentage'])
            : null,
        invoiceFooter: json['invoiceFooter']?.toString(),
        invoiceTerms: json['invoiceTerms']?.toString(),
        instagramUrl: json['instagramUrl']?.toString(),
        facebookUrl: json['facebookUrl']?.toString(),
        youtubeUrl: json['youtubeUrl']?.toString(),
        twitterUrl: json['twitterUrl']?.toString(),
      );
}
