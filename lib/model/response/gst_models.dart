import '../../core/utils/parsers.dart';
import 'support_models.dart' show PaginationInfo;

// ─── GST Dashboard ────────────────────────────────────────────────────────────
class GstDashboardResponse {
  final GstDashboard? data;
  GstDashboardResponse({this.data});
  factory GstDashboardResponse.fromJson(Map<String, dynamic> json) =>
      GstDashboardResponse(
        data: json['data'] != null ? GstDashboard.fromJson(json['data']) : null,
      );
}

class GstDashboard {
  final GstTotals totals;
  final List<GstMonthly> monthly;

  GstDashboard({GstTotals? totals, this.monthly = const []})
    : totals = totals ?? GstTotals();

  factory GstDashboard.fromJson(Map<String, dynamic> json) => GstDashboard(
    totals: json['totals'] != null
        ? GstTotals.fromJson(json['totals'])
        : GstTotals(),
    monthly: json['monthly'] != null
        ? (json['monthly'] as List).map((e) => GstMonthly.fromJson(e)).toList()
        : [],
  );
}

class GstTotals {
  final int totalInvoices;
  final double taxableAmount;
  final double totalGst;
  final double cgst;
  final double sgst;
  final double igst;
  final double totalRevenue;

  GstTotals({
    this.totalInvoices = 0,
    this.taxableAmount = 0,
    this.totalGst = 0,
    this.cgst = 0,
    this.sgst = 0,
    this.igst = 0,
    this.totalRevenue = 0,
  });

  factory GstTotals.fromJson(Map<String, dynamic> json) => GstTotals(
    totalInvoices: parseInt(json['totalInvoices']),
    taxableAmount: parseDouble(json['taxableAmount']),
    totalGst: parseDouble(json['totalGst']),
    cgst: parseDouble(json['cgst']),
    sgst: parseDouble(json['sgst']),
    igst: parseDouble(json['igst']),
    totalRevenue: parseDouble(json['totalRevenue']),
  );
}

class GstMonthly {
  final int year;
  final int month;
  final int invoices;
  final double taxableAmount;
  final double totalGst;

  GstMonthly({
    this.year = 0,
    this.month = 0,
    this.invoices = 0,
    this.taxableAmount = 0,
    this.totalGst = 0,
  });

  factory GstMonthly.fromJson(Map<String, dynamic> json) => GstMonthly(
    year: parseInt(json['year']),
    month: parseInt(json['month']),
    invoices: parseInt(json['invoices']),
    taxableAmount: parseDouble(json['taxableAmount']),
    totalGst: parseDouble(json['totalGst']),
  );
}

// ─── State-wise GST ───────────────────────────────────────────────────────────
class StateGstItem {
  final String state;
  final int orderCount;
  final double taxableAmount;
  final double cgst;
  final double sgst;
  final double igst;
  final double totalGst;
  final double totalAmount;

  StateGstItem({
    this.state = 'Unknown',
    this.orderCount = 0,
    this.taxableAmount = 0,
    this.cgst = 0,
    this.sgst = 0,
    this.igst = 0,
    this.totalGst = 0,
    this.totalAmount = 0,
  });

  factory StateGstItem.fromJson(Map<String, dynamic> json) => StateGstItem(
    state: json['state']?.toString() ?? 'Unknown',
    orderCount: parseInt(json['orderCount']),
    taxableAmount: parseDouble(json['taxableAmount']),
    cgst: parseDouble(json['cgst']),
    sgst: parseDouble(json['sgst']),
    igst: parseDouble(json['igst']),
    totalGst: parseDouble(json['totalGst']),
    totalAmount: parseDouble(json['totalAmount']),
  );
}

class StateGstResponse {
  final List<StateGstItem>? data;
  StateGstResponse({this.data});
  factory StateGstResponse.fromJson(Map<String, dynamic> json) =>
      StateGstResponse(
        data: json['data'] != null
            ? (json['data'] as List)
                  .map((e) => StateGstItem.fromJson(e))
                  .toList()
            : null,
      );
}

// ─── Invoice Breakup ──────────────────────────────────────────────────────────
class InvoiceBreakupItem {
  final int id;
  final String invoiceNumber;
  final String? invoiceDate;
  final String? customerName;
  final String? customerEmail;
  final String? state;
  final double taxableAmount;
  final double cgst;
  final double sgst;
  final double igst;
  final double totalGst;
  final double invoiceTotal;

  InvoiceBreakupItem({
    this.id = 0,
    this.invoiceNumber = '',
    this.invoiceDate,
    this.customerName,
    this.customerEmail,
    this.state,
    this.taxableAmount = 0,
    this.cgst = 0,
    this.sgst = 0,
    this.igst = 0,
    this.totalGst = 0,
    this.invoiceTotal = 0,
  });

  factory InvoiceBreakupItem.fromJson(Map<String, dynamic> json) =>
      InvoiceBreakupItem(
        id: parseInt(json['id']),
        invoiceNumber: json['invoiceNumber']?.toString() ?? '',
        invoiceDate: json['invoiceDate']?.toString(),
        customerName: json['customerName']?.toString(),
        customerEmail: json['customerEmail']?.toString(),
        state: json['state']?.toString(),
        taxableAmount: parseDouble(json['taxableAmount']),
        cgst: parseDouble(json['cgst']),
        sgst: parseDouble(json['sgst']),
        igst: parseDouble(json['igst']),
        totalGst: parseDouble(json['totalGst']),
        invoiceTotal: parseDouble(json['invoiceTotal']),
      );
}

class InvoiceBreakupResponse {
  final List<InvoiceBreakupItem>? data;
  final PaginationInfo? pagination;
  InvoiceBreakupResponse({this.data, this.pagination});
  factory InvoiceBreakupResponse.fromJson(Map<String, dynamic> json) =>
      InvoiceBreakupResponse(
        data: json['data'] != null
            ? (json['data'] as List)
                  .map((e) => InvoiceBreakupItem.fromJson(e))
                  .toList()
            : null,
        pagination: json['pagination'] != null
            ? PaginationInfo.fromJson(json['pagination'])
            : null,
      );
}

// ─── HSN Summary ──────────────────────────────────────────────────────────────
class HsnSummaryItem {
  final String hsnCode;
  final String description;
  final double gstPercent;
  final int productCount;
  final int totalQuantity;
  final double taxableValue;
  final double totalGst;

  HsnSummaryItem({
    this.hsnCode = '',
    this.description = '',
    this.gstPercent = 0,
    this.productCount = 0,
    this.totalQuantity = 0,
    this.taxableValue = 0,
    this.totalGst = 0,
  });

  factory HsnSummaryItem.fromJson(Map<String, dynamic> json) => HsnSummaryItem(
    hsnCode: json['hsnCode']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    gstPercent: parseDouble(json['gstPercent']),
    productCount: parseInt(json['productCount']),
    totalQuantity: parseInt(json['totalQuantity']),
    taxableValue: parseDouble(json['taxableValue']),
    totalGst: parseDouble(json['totalGst']),
  );
}

class HsnSummaryResponse {
  final List<HsnSummaryItem>? data;
  HsnSummaryResponse({this.data});
  factory HsnSummaryResponse.fromJson(Map<String, dynamic> json) =>
      HsnSummaryResponse(
        data: json['data'] != null
            ? (json['data'] as List)
                  .map((e) => HsnSummaryItem.fromJson(e))
                  .toList()
            : null,
      );
}

// ─── GSTR-1 / GSTR-3B ─────────────────────────────────────────────────────────
class GstrRateRow {
  final double rate;
  final int invoiceCount;
  final double taxableValue;
  final double cgst;
  final double sgst;
  final double igst;
  final double totalTax;

  GstrRateRow({
    this.rate = 0,
    this.invoiceCount = 0,
    this.taxableValue = 0,
    this.cgst = 0,
    this.sgst = 0,
    this.igst = 0,
    this.totalTax = 0,
  });

  factory GstrRateRow.fromJson(Map<String, dynamic> json) => GstrRateRow(
    rate: parseDouble(json['rate']),
    invoiceCount: parseInt(json['invoiceCount']),
    taxableValue: parseDouble(json['taxableValue']),
    cgst: parseDouble(json['cgst']),
    sgst: parseDouble(json['sgst']),
    igst: parseDouble(json['igst']),
    totalTax: parseDouble(json['totalTax']),
  );
}

class Gstr1Response {
  final Gstr1Data? data;
  Gstr1Response({this.data});
  factory Gstr1Response.fromJson(Map<String, dynamic> json) => Gstr1Response(
    data: json['data'] != null ? Gstr1Data.fromJson(json['data']) : null,
  );
}

class Gstr1Data {
  final int month;
  final int year;
  final int totalInvoices;
  final double totalTaxable;
  final double totalTax;
  final List<GstrRateRow> ratewise;

  Gstr1Data({
    this.month = 0,
    this.year = 0,
    this.totalInvoices = 0,
    this.totalTaxable = 0,
    this.totalTax = 0,
    this.ratewise = const [],
  });

  factory Gstr1Data.fromJson(Map<String, dynamic> json) {
    final period = json['period'] ?? {};
    final summary = json['summary'] ?? {};
    return Gstr1Data(
      month: parseInt(period['month']),
      year: parseInt(period['year']),
      totalInvoices: parseInt(summary['totalInvoices']),
      totalTaxable: parseDouble(summary['totalTaxable']),
      totalTax: parseDouble(summary['totalTax']),
      ratewise: json['ratewise'] != null
          ? (json['ratewise'] as List)
                .map((e) => GstrRateRow.fromJson(e))
                .toList()
          : [],
    );
  }
}

class Gstr3bData {
  final int month;
  final int year;
  final double taxableValue;
  final double cgst;
  final double sgst;
  final double igst;
  final double totalTax;

  Gstr3bData({
    this.month = 0,
    this.year = 0,
    this.taxableValue = 0,
    this.cgst = 0,
    this.sgst = 0,
    this.igst = 0,
    this.totalTax = 0,
  });

  factory Gstr3bData.fromJson(Map<String, dynamic> json) {
    final period = json['period'] ?? {};
    final outward = json['outwardSupplies'] ?? {};
    return Gstr3bData(
      month: parseInt(period['month']),
      year: parseInt(period['year']),
      taxableValue: parseDouble(outward['taxableValue']),
      cgst: parseDouble(outward['cgst']),
      sgst: parseDouble(outward['sgst']),
      igst: parseDouble(outward['igst']),
      totalTax: parseDouble(outward['totalTax']),
    );
  }
}

class Gstr3bResponse {
  final Gstr3bData? data;
  Gstr3bResponse({this.data});
  factory Gstr3bResponse.fromJson(Map<String, dynamic> json) => Gstr3bResponse(
    data: json['data'] != null ? Gstr3bData.fromJson(json['data']) : null,
  );
}

// ─── Tax Settings ─────────────────────────────────────────────────────────────
class TaxSettings {
  final double defaultGstPercent;
  final String? invoiceTaxNote;
  final String? gstInvoiceFooter;
  final String? gstDeclaration;
  final Map<String, dynamic>? stateTaxMapping;

  TaxSettings({
    this.defaultGstPercent = 18,
    this.invoiceTaxNote,
    this.gstInvoiceFooter,
    this.gstDeclaration,
    this.stateTaxMapping,
  });

  factory TaxSettings.fromJson(Map<String, dynamic> json) => TaxSettings(
    defaultGstPercent: parseDouble(json['defaultGstPercent'], defaultValue: 18),
    invoiceTaxNote: json['invoiceTaxNote']?.toString(),
    gstInvoiceFooter: json['gstInvoiceFooter']?.toString(),
    gstDeclaration: json['gstDeclaration']?.toString(),
    stateTaxMapping: json['stateTaxMapping'] is Map
        ? Map<String, dynamic>.from(json['stateTaxMapping'])
        : null,
  );
}

class TaxSettingsResponse {
  final TaxSettings? data;
  TaxSettingsResponse({this.data});
  factory TaxSettingsResponse.fromJson(Map<String, dynamic> json) =>
      TaxSettingsResponse(
        data: json['data'] != null ? TaxSettings.fromJson(json['data']) : null,
      );
}
