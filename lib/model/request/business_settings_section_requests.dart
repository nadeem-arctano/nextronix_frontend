/// Per-section request models for /api/business-settings/<section>.
/// Each section accepts only its own fields. Null fields are omitted from
/// the JSON body so the server preserves existing values.

class BusinessInfoSectionRequest {
  final String? businessName;
  final String? legalBusinessName;
  final String? gstNumber;
  final String? panNumber;
  final String? websiteUrl;

  BusinessInfoSectionRequest({
    this.businessName,
    this.legalBusinessName,
    this.gstNumber,
    this.panNumber,
    this.websiteUrl,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (businessName != null) map['businessName'] = businessName;
    if (legalBusinessName != null) map['legalBusinessName'] = legalBusinessName;
    if (gstNumber != null) map['gstNumber'] = gstNumber;
    if (panNumber != null) map['panNumber'] = panNumber;
    if (websiteUrl != null) map['websiteUrl'] = websiteUrl;
    return map;
  }
}

class ContactSectionRequest {
  final String? businessEmail;
  final String? businessPhone;
  final String? supportEmail;
  final String? supportPhone;

  ContactSectionRequest({
    this.businessEmail,
    this.businessPhone,
    this.supportEmail,
    this.supportPhone,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (businessEmail != null) map['businessEmail'] = businessEmail;
    if (businessPhone != null) map['businessPhone'] = businessPhone;
    if (supportEmail != null) map['supportEmail'] = supportEmail;
    if (supportPhone != null) map['supportPhone'] = supportPhone;
    return map;
  }
}

class AddressSectionRequest {
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;

  AddressSectionRequest({
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.country,
    this.pincode,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (addressLine1 != null) map['addressLine1'] = addressLine1;
    if (addressLine2 != null) map['addressLine2'] = addressLine2;
    if (city != null) map['city'] = city;
    if (state != null) map['state'] = state;
    if (country != null) map['country'] = country;
    if (pincode != null) map['pincode'] = pincode;
    return map;
  }
}

class BankSectionRequest {
  final String? accountHolderName;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? branchName;

  BankSectionRequest({
    this.accountHolderName,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.branchName,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (accountHolderName != null) map['accountHolderName'] = accountHolderName;
    if (bankName != null) map['bankName'] = bankName;
    if (accountNumber != null) map['accountNumber'] = accountNumber;
    if (ifscCode != null) map['ifscCode'] = ifscCode;
    if (branchName != null) map['branchName'] = branchName;
    return map;
  }
}

class PaymentSectionRequest {
  final String? upiId;
  final String? razorpayKey;
  final String? razorpaySecret;
  final String? stripePublicKey;
  final String? stripeSecretKey;

  PaymentSectionRequest({
    this.upiId,
    this.razorpayKey,
    this.razorpaySecret,
    this.stripePublicKey,
    this.stripeSecretKey,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (upiId != null) map['upiId'] = upiId;
    if (razorpayKey != null) map['razorpayKey'] = razorpayKey;
    if (razorpaySecret != null) map['razorpaySecret'] = razorpaySecret;
    if (stripePublicKey != null) map['stripePublicKey'] = stripePublicKey;
    if (stripeSecretKey != null) map['stripeSecretKey'] = stripeSecretKey;
    return map;
  }
}

class InvoiceSectionRequest {
  final String? invoicePrefix;
  final int? invoiceStartNumber;
  final double? gstPercentage;
  final String? invoiceFooter;
  final String? invoiceTerms;

  InvoiceSectionRequest({
    this.invoicePrefix,
    this.invoiceStartNumber,
    this.gstPercentage,
    this.invoiceFooter,
    this.invoiceTerms,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (invoicePrefix != null) map['invoicePrefix'] = invoicePrefix;
    if (invoiceStartNumber != null)
      map['invoiceStartNumber'] = invoiceStartNumber;
    if (gstPercentage != null) map['gstPercentage'] = gstPercentage;
    if (invoiceFooter != null) map['invoiceFooter'] = invoiceFooter;
    if (invoiceTerms != null) map['invoiceTerms'] = invoiceTerms;
    return map;
  }
}

class SocialSectionRequest {
  final String? instagramUrl;
  final String? facebookUrl;
  final String? youtubeUrl;
  final String? twitterUrl;

  SocialSectionRequest({
    this.instagramUrl,
    this.facebookUrl,
    this.youtubeUrl,
    this.twitterUrl,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (instagramUrl != null) map['instagramUrl'] = instagramUrl;
    if (facebookUrl != null) map['facebookUrl'] = facebookUrl;
    if (youtubeUrl != null) map['youtubeUrl'] = youtubeUrl;
    if (twitterUrl != null) map['twitterUrl'] = twitterUrl;
    return map;
  }
}
