import '../../core/utils/parsers.dart';

// ─── Daily Sales Response ─────────────────────────────────────────────────────
class DailySalesResponse {
  final bool? success;
  final String? message;
  final DailySalesData? data;

  DailySalesResponse({this.success, this.message, this.data});

  factory DailySalesResponse.fromJson(Map<String, dynamic> json) =>
      DailySalesResponse(
        success: json['success'],
        message: json['message'],
        data: json['data'] != null
            ? DailySalesData.fromJson(json['data'])
            : null,
      );
}

class DailySalesData {
  final DailySalesSummary? summary;
  final List<DailySalesItem> data;
  final PaginationData? pagination;

  DailySalesData({this.summary, this.data = const [], this.pagination});

  factory DailySalesData.fromJson(Map<String, dynamic> json) => DailySalesData(
    summary: json['summary'] != null
        ? DailySalesSummary.fromJson(json['summary'])
        : null,
    data: json['data'] != null
        ? (json['data'] as List).map((e) => DailySalesItem.fromJson(e)).toList()
        : [],
    pagination: json['pagination'] != null
        ? PaginationData.fromJson(json['pagination'])
        : null,
  );
}

class DailySalesSummary {
  final int totalOrders;
  final double totalRevenue;
  final double totalGST;
  final double totalDiscount;
  final int codOrders;
  final int onlineOrders;

  DailySalesSummary({
    this.totalOrders = 0,
    this.totalRevenue = 0,
    this.totalGST = 0,
    this.totalDiscount = 0,
    this.codOrders = 0,
    this.onlineOrders = 0,
  });

  factory DailySalesSummary.fromJson(Map<String, dynamic> json) =>
      DailySalesSummary(
        totalOrders: parseInt(json['totalOrders']),
        totalRevenue: parseDouble(json['totalRevenue']),
        totalGST: parseDouble(json['totalGST']),
        totalDiscount: parseDouble(json['totalDiscount']),
        codOrders: parseInt(json['codOrders']),
        onlineOrders: parseInt(json['onlineOrders']),
      );
}

class DailySalesItem {
  final String? date;
  final int orders;
  final double revenue;
  final double gst;
  final double discount;
  final int codOrders;
  final int onlineOrders;

  DailySalesItem({
    this.date,
    this.orders = 0,
    this.revenue = 0,
    this.gst = 0,
    this.discount = 0,
    this.codOrders = 0,
    this.onlineOrders = 0,
  });

  factory DailySalesItem.fromJson(Map<String, dynamic> json) => DailySalesItem(
    date: json['date']?.toString(),
    orders: parseInt(json['orders']),
    revenue: parseDouble(json['revenue']),
    gst: parseDouble(json['gst']),
    discount: parseDouble(json['discount']),
    codOrders: parseInt(json['codOrders']),
    onlineOrders: parseInt(json['onlineOrders']),
  );
}

// ─── Monthly Sales Response ───────────────────────────────────────────────────
class MonthlySalesResponse {
  final bool? success;
  final String? message;
  final List<MonthlySalesItem>? data;

  MonthlySalesResponse({this.success, this.message, this.data});

  factory MonthlySalesResponse.fromJson(Map<String, dynamic> json) =>
      MonthlySalesResponse(
        success: json['success'],
        message: json['message'],
        data: json['data'] != null
            ? (json['data'] as List)
                  .map((e) => MonthlySalesItem.fromJson(e))
                  .toList()
            : null,
      );
}

class MonthlySalesItem {
  final int year;
  final int month;
  final int orderCount;
  final double revenue;
  final double tax;
  final double averageOrderValue;
  final double totalDiscount;
  final double growthPercent;

  MonthlySalesItem({
    this.year = 0,
    this.month = 0,
    this.orderCount = 0,
    this.revenue = 0,
    this.tax = 0,
    this.averageOrderValue = 0,
    this.totalDiscount = 0,
    this.growthPercent = 0,
  });

  factory MonthlySalesItem.fromJson(Map<String, dynamic> json) =>
      MonthlySalesItem(
        year: parseInt(json['year']),
        month: parseInt(json['month']),
        orderCount: parseInt(json['orderCount']),
        revenue: parseDouble(json['revenue']),
        tax: parseDouble(json['tax']),
        averageOrderValue: parseDouble(json['averageOrderValue']),
        totalDiscount: parseDouble(json['totalDiscount']),
        growthPercent: parseDouble(json['growthPercent']),
      );
}

// ─── GST Report Response ──────────────────────────────────────────────────────
class GstReportResponse {
  final bool? success;
  final String? message;
  final GstReportData? data;

  GstReportResponse({this.success, this.message, this.data});

  factory GstReportResponse.fromJson(Map<String, dynamic> json) =>
      GstReportResponse(
        success: json['success'],
        message: json['message'],
        data: json['data'] != null
            ? GstReportData.fromJson(json['data'])
            : null,
      );
}

class GstReportData {
  final List<GstRateItem> gstByRate;
  final GstInvoiceSummary? invoiceSummary;

  GstReportData({this.gstByRate = const [], this.invoiceSummary});

  factory GstReportData.fromJson(Map<String, dynamic> json) => GstReportData(
    gstByRate: json['gstByRate'] != null
        ? (json['gstByRate'] as List)
              .map((e) => GstRateItem.fromJson(e))
              .toList()
        : [],
    invoiceSummary: json['invoiceSummary'] != null
        ? GstInvoiceSummary.fromJson(json['invoiceSummary'])
        : null,
  );
}

class GstRateItem {
  final double gstPercent;
  final int invoiceCount;
  final double taxableAmount;
  final double cgst;
  final double sgst;
  final double igst;
  final double totalAmount;

  GstRateItem({
    this.gstPercent = 0,
    this.invoiceCount = 0,
    this.taxableAmount = 0,
    this.cgst = 0,
    this.sgst = 0,
    this.igst = 0,
    this.totalAmount = 0,
  });

  factory GstRateItem.fromJson(Map<String, dynamic> json) => GstRateItem(
    gstPercent: parseDouble(json['gstPercent']),
    invoiceCount: parseInt(json['invoiceCount']),
    taxableAmount: parseDouble(json['taxableAmount']),
    cgst: parseDouble(json['cgst']),
    sgst: parseDouble(json['sgst']),
    igst: parseDouble(json['igst']),
    totalAmount: parseDouble(json['totalAmount']),
  );
}

class GstInvoiceSummary {
  final int totalInvoices;
  final double totalRevenue;
  final double totalGST;

  GstInvoiceSummary({
    this.totalInvoices = 0,
    this.totalRevenue = 0,
    this.totalGST = 0,
  });

  factory GstInvoiceSummary.fromJson(Map<String, dynamic> json) =>
      GstInvoiceSummary(
        totalInvoices: parseInt(json['totalInvoices']),
        totalRevenue: parseDouble(json['totalRevenue']),
        totalGST: parseDouble(json['totalGST']),
      );
}

// ─── Coupon Report Response ───────────────────────────────────────────────────
class CouponReportResponse {
  final bool? success;
  final String? message;
  final List<CouponReportItem>? data;

  CouponReportResponse({this.success, this.message, this.data});

  factory CouponReportResponse.fromJson(Map<String, dynamic> json) =>
      CouponReportResponse(
        success: json['success'],
        message: json['message'],
        data: json['data'] != null
            ? (json['data'] as List)
                  .map((e) => CouponReportItem.fromJson(e))
                  .toList()
            : null,
      );
}

class CouponReportItem {
  final int id;
  final String code;
  final String discountType;
  final double discountValue;
  final int totalUsage;
  final int? usageLimit;
  final String status;
  final String? expiryDate;
  final double totalDiscountGiven;
  final double revenueGenerated;
  final int orderCount;

  CouponReportItem({
    this.id = 0,
    this.code = '',
    this.discountType = '',
    this.discountValue = 0,
    this.totalUsage = 0,
    this.usageLimit,
    this.status = '',
    this.expiryDate,
    this.totalDiscountGiven = 0,
    this.revenueGenerated = 0,
    this.orderCount = 0,
  });

  factory CouponReportItem.fromJson(Map<String, dynamic> json) =>
      CouponReportItem(
        id: parseInt(json['id']),
        code: json['code']?.toString() ?? '',
        discountType: json['discountType']?.toString() ?? '',
        discountValue: parseDouble(json['discountValue']),
        totalUsage: parseInt(json['totalUsage']),
        usageLimit: json['usageLimit'] != null
            ? parseInt(json['usageLimit'])
            : null,
        status: json['status']?.toString() ?? '',
        expiryDate: json['expiryDate']?.toString(),
        totalDiscountGiven: parseDouble(json['totalDiscountGiven']),
        revenueGenerated: parseDouble(json['revenueGenerated']),
        orderCount: parseInt(json['orderCount']),
      );
}

// ─── Top Customers Response ───────────────────────────────────────────────────
class TopCustomersResponse {
  final bool? success;
  final String? message;
  final List<TopCustomerItem>? data;

  TopCustomersResponse({this.success, this.message, this.data});

  factory TopCustomersResponse.fromJson(Map<String, dynamic> json) =>
      TopCustomersResponse(
        success: json['success'],
        message: json['message'],
        data: json['data'] != null
            ? (json['data'] as List)
                  .map((e) => TopCustomerItem.fromJson(e))
                  .toList()
            : null,
      );
}

class TopCustomerItem {
  final int id;
  final String? name;
  final String? email;
  final String? mobile;
  final int totalOrders;
  final double totalSpending;
  final String? lastOrderDate;

  TopCustomerItem({
    this.id = 0,
    this.name,
    this.email,
    this.mobile,
    this.totalOrders = 0,
    this.totalSpending = 0,
    this.lastOrderDate,
  });

  factory TopCustomerItem.fromJson(Map<String, dynamic> json) =>
      TopCustomerItem(
        id: parseInt(json['id']),
        name: json['name']?.toString(),
        email: json['email']?.toString(),
        mobile: json['mobile']?.toString(),
        totalOrders: parseInt(json['totalOrders']),
        totalSpending: parseDouble(json['totalSpending']),
        lastOrderDate: json['lastOrderDate']?.toString(),
      );
}

// ─── Best Products Response ───────────────────────────────────────────────────
class BestProductsResponse {
  final bool? success;
  final String? message;
  final List<BestProductItem>? data;

  BestProductsResponse({this.success, this.message, this.data});

  factory BestProductsResponse.fromJson(Map<String, dynamic> json) =>
      BestProductsResponse(
        success: json['success'],
        message: json['message'],
        data: json['data'] != null
            ? (json['data'] as List)
                  .map((e) => BestProductItem.fromJson(e))
                  .toList()
            : null,
      );
}

class BestProductItem {
  final int id;
  final String? productName;
  final String? sku;
  final String? thumbnailImage;
  final int quantitySold;
  final double totalRevenue;
  final int totalOrders;
  final int stockRemaining;

  BestProductItem({
    this.id = 0,
    this.productName,
    this.sku,
    this.thumbnailImage,
    this.quantitySold = 0,
    this.totalRevenue = 0,
    this.totalOrders = 0,
    this.stockRemaining = 0,
  });

  factory BestProductItem.fromJson(Map<String, dynamic> json) =>
      BestProductItem(
        id: parseInt(json['id']),
        productName: json['productName']?.toString(),
        sku: json['sku']?.toString(),
        thumbnailImage: json['thumbnailImage']?.toString(),
        quantitySold: parseInt(json['quantitySold']),
        totalRevenue: parseDouble(json['totalRevenue']),
        totalOrders: parseInt(json['totalOrders']),
        stockRemaining: parseInt(json['stockRemaining']),
      );
}

// ─── Pagination ───────────────────────────────────────────────────────────────
class PaginationData {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  PaginationData({
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.itemsPerPage = 10,
  });

  factory PaginationData.fromJson(Map<String, dynamic> json) => PaginationData(
    currentPage: parseInt(json['currentPage'], defaultValue: 1),
    totalPages: parseInt(json['totalPages'], defaultValue: 1),
    totalItems: parseInt(json['totalItems']),
    itemsPerPage: parseInt(json['itemsPerPage'], defaultValue: 10),
  );
}
