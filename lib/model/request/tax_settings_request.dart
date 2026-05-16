class TaxSettingsRequest {
  final double? defaultGstPercent;
  final String? invoiceTaxNote;
  final String? gstInvoiceFooter;
  final String? gstDeclaration;

  TaxSettingsRequest({
    this.defaultGstPercent,
    this.invoiceTaxNote,
    this.gstInvoiceFooter,
    this.gstDeclaration,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (defaultGstPercent != null) map['defaultGstPercent'] = defaultGstPercent;
    if (invoiceTaxNote != null) map['invoiceTaxNote'] = invoiceTaxNote;
    if (gstInvoiceFooter != null) map['gstInvoiceFooter'] = gstInvoiceFooter;
    if (gstDeclaration != null) map['gstDeclaration'] = gstDeclaration;
    return map;
  }
}
