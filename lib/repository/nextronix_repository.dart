import 'package:dio/dio.dart';
import '../api/api_provider.dart';
import '../api/base_url.dart';
import '../core/services/auth_storage.dart';
import '../model/request/request.dart';
import '../model/response/response.dart';
import '../static_values/static_values.dart';

class NextronixRepository {
  late ApiProvider _apiProvider;
  late Dio _dio;

  /// Single in-flight refresh future so concurrent 401s share one request.
  static Future<String?>? _refreshFuture;

  NextronixRepository() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Interceptor: attaches access token, transparently refreshes on 401.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (globalAccessToken != null) {
            options.headers["Authorization"] = "Bearer $globalAccessToken";
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          // Skip retry for the refresh endpoint itself (would loop)
          final reqPath = e.requestOptions.path;
          final isAuthCall =
              reqPath.contains('/auth/login') ||
              reqPath.contains('/auth/refresh') ||
              reqPath.contains('/auth/register');

          if (e.response?.statusCode == 401 &&
              !isAuthCall &&
              globalRefreshToken != null &&
              !(e.requestOptions.extra['_retried'] == true)) {
            try {
              final newToken = await _refreshAccessToken();
              if (newToken != null) {
                final opts = e.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newToken';
                opts.extra['_retried'] = true;
                final clone = await _dio.fetch(opts);
                return handler.resolve(clone);
              }
            } catch (_) {
              // fall through to forced logout below
            }
          }

          if (e.response?.statusCode == 401 && !isAuthCall) {
            await _forceLogout();
          }

          handler.next(e);
        },
      ),
    );

    _apiProvider = ApiProvider(_dio, baseUrl: BaseUrl.baseurl);
  }

  /// Coalesces concurrent refresh attempts onto a single network call.
  Future<String?> _refreshAccessToken() async {
    final inflight = _refreshFuture;
    if (inflight != null) return inflight;

    _refreshFuture = _doRefresh();
    try {
      final token = await _refreshFuture;
      return token;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<String?> _doRefresh() async {
    if (globalRefreshToken == null) return null;
    // Use a separate Dio so the refresh call doesn't loop through our
    // interceptor (no auth header attached, no retry-on-401).
    final raw = Dio(
      BaseOptions(
        baseUrl: BaseUrl.baseurl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    final res = await raw.post(
      'auth/refresh',
      data: {'refreshToken': globalRefreshToken},
    );
    final data = res.data?['data'] as Map<String, dynamic>?;
    final access = data?['accessToken'] as String?;
    final refresh = data?['refreshToken'] as String?;
    if (access == null || refresh == null) return null;

    globalAccessToken = access;
    globalRefreshToken = refresh;
    await AuthStorage.updateAccessToken(access);
    await AuthStorage.updateRefreshToken(refresh);
    return access;
  }

  Future<void> _forceLogout() async {
    globalAccessToken = null;
    globalRefreshToken = null;
    globalPermissions = const [];
    try {
      await AuthStorage.clear();
    } catch (_) {}
    if (!sessionEvents.isClosed) {
      sessionEvents.add(SessionEvent.forceLogout);
    }
  }

  // ─── Auth ───────────────────────────────────────────────────────────────────
  Future<LoginResponse> userLogin({
    required String email,
    required String password,
  }) async {
    return await _apiProvider.userLogin(
      LoginRequest(email: email, password: password),
    );
  }

  Future<CommonResponse> register({
    required String name,
    required String email,
    required String password,
    String? mobile,
  }) async {
    return await _apiProvider.register(
      RegisterRequest(
        name: name,
        email: email,
        password: password,
        mobile: mobile,
      ),
    );
  }

  Future<ProfileResponse> getProfile() async {
    return await _apiProvider.getProfile();
  }

  // ─── Categories ─────────────────────────────────────────────────────────────
  Future<CategoryListResponse> getCategories() async {
    return await _apiProvider.getCategories();
  }

  Future<CommonResponse> createCategory({
    required String name,
    String? description,
    String? status,
    MultipartFile? image,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'description': description,
      'status': status,
      'image': image,
    });
    return await _apiProvider.createCategory(formData);
  }

  Future<CommonResponse> updateCategory({
    required int id,
    required String name,
    String? description,
    String? status,
    MultipartFile? image,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'description': description,
      'status': status,
      'image': image,
    });
    return await _apiProvider.updateCategory(id, formData);
  }

  Future<CommonResponse> deleteCategory({required int id}) async {
    return await _apiProvider.deleteCategory(id);
  }

  Future<CommonResponse> updateCategoryStatus({
    required int id,
    required String status,
  }) async {
    return await _apiProvider.updateCategoryStatus(
      id,
      StatusRequest(status: status),
    );
  }

  // ─── Products ───────────────────────────────────────────────────────────────
  Future<ProductListResponse> getProducts({
    int page = 1,
    int limit = 10,
    String? search,
    String? category,
    String? status,
    String? sortBy,
    String? stock,
    bool? featured,
    double? minPrice,
    double? maxPrice,
  }) async {
    final queries = <String, dynamic>{'page': page, 'limit': limit};
    if (search != null && search.isNotEmpty) queries['search'] = search;
    if (category != null) queries['category'] = category;
    if (status != null) queries['status'] = status;
    if (sortBy != null) queries['sortBy'] = sortBy;
    if (stock != null) queries['stock'] = stock;
    if (featured == true) queries['featured'] = 'true';
    if (minPrice != null) queries['minPrice'] = minPrice;
    if (maxPrice != null) queries['maxPrice'] = maxPrice;
    return await _apiProvider.getProducts(queries);
  }

  Future<ProductDetailResponse> getProductById({required int id}) async {
    return await _apiProvider.getProductById(id);
  }

  Future<CommonResponse> createProduct({required FormData formData}) async {
    return await _apiProvider.createProduct(formData);
  }

  Future<CommonResponse> updateProduct({
    required int id,
    required FormData formData,
  }) async {
    return await _apiProvider.updateProduct(id, formData);
  }

  Future<CommonResponse> deleteProduct({required int id}) async {
    return await _apiProvider.deleteProduct(id);
  }

  Future<CommonResponse> updateProductStatus({
    required int id,
    required String status,
  }) async {
    return await _apiProvider.updateProductStatus(
      id,
      StatusRequest(status: status),
    );
  }

  Future<CommonResponse> toggleProductFeatured({required int id}) async {
    return await _apiProvider.toggleProductFeatured(id);
  }

  Future<CommonResponse> updateProductPrice({
    required int id,
    required double mrpPrice,
    required double sellingPrice,
  }) async {
    return await _apiProvider.updateProductPrice(
      id,
      PriceUpdateRequest(mrpPrice: mrpPrice, sellingPrice: sellingPrice),
    );
  }

  Future<CommonResponse> updateProductStock({
    required int id,
    required int stockQuantity,
  }) async {
    return await _apiProvider.updateProductStock(
      id,
      StockUpdateRequest(stockQuantity: stockQuantity),
    );
  }

  Future<ProductListResponse> getLowStockProducts() async {
    return await _apiProvider.getLowStockProducts();
  }

  Future<CommonResponse> bulkDeleteProducts({required List<int> ids}) async {
    return await _apiProvider.bulkDeleteProducts(BulkIdsRequest(ids: ids));
  }

  Future<CommonResponse> bulkUpdateProductStatus({
    required List<int> ids,
    required String status,
  }) async {
    return await _apiProvider.bulkUpdateProductStatus(
      BulkStatusRequest(ids: ids, status: status),
    );
  }

  // ─── Orders ─────────────────────────────────────────────────────────────────
  Future<OrderListResponse> getOrders({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final queries = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null) queries['status'] = status;
    return await _apiProvider.getOrders(queries);
  }

  Future<OrderDetailResponse> getOrderById({required int id}) async {
    return await _apiProvider.getOrderById(id);
  }

  Future<CommonResponse> updateOrderStatus({
    required int id,
    required String status,
  }) async {
    return await _apiProvider.updateOrderStatus(
      id,
      StatusRequest(status: status),
    );
  }

  Future<CommonResponse> updatePaymentStatus({
    required int id,
    required String paymentStatus,
  }) async {
    return await _apiProvider.updatePaymentStatus(
      id,
      PaymentStatusRequest(paymentStatus: paymentStatus),
    );
  }

  // ─── Dashboard ──────────────────────────────────────────────────────────────
  Future<DashboardStatsResponse> getDashboardStats() async {
    return await _apiProvider.getDashboardStats();
  }

  Future<RevenueListResponse> getDashboardRevenue({int period = 30}) async {
    return await _apiProvider.getDashboardRevenue(period);
  }

  Future<OrderListResponse> getDashboardRecentOrders({int limit = 5}) async {
    return await _apiProvider.getDashboardRecentOrders(limit);
  }

  Future<ProductListResponse> getDashboardTopProducts({int limit = 5}) async {
    return await _apiProvider.getDashboardTopProducts(limit);
  }

  Future<ProductListResponse> getDashboardLowStock() async {
    return await _apiProvider.getDashboardLowStock();
  }

  Future<UserListResponse> getDashboardRecentUsers({int limit = 10}) async {
    return await _apiProvider.getDashboardRecentUsers(limit);
  }

  // ─── Users ────────────────────────────────────────────────────────────────
  Future<UserListResponse> getUsers({
    int page = 1,
    int limit = 10,
    String? search,
    String? startDate,
    String? endDate,
    String? role,
    String? status,
  }) async {
    final queries = <String, dynamic>{'page': page, 'limit': limit};
    if (search != null && search.isNotEmpty) queries['search'] = search;
    if (startDate != null) queries['startDate'] = startDate;
    if (endDate != null) queries['endDate'] = endDate;
    if (role != null) queries['role'] = role;
    if (status != null) queries['status'] = status;
    return await _apiProvider.getUsers(queries);
  }

  Future<CommonResponse> updateUserStatus({
    required int id,
    required String status,
  }) async {
    return await _apiProvider.updateUserStatus(
      id,
      StatusRequest(status: status),
    );
  }

  // ─── HSN Codes ──────────────────────────────────────────────────────────────
  Future<HsnListResponse> getHsnCodes() async {
    return await _apiProvider.getHsnCodes();
  }

  Future<CommonResponse> createHsn({
    required String hsnCode,
    required double gstPercent,
    String? description,
  }) async {
    return await _apiProvider.createHsn(
      HsnRequest(
        hsnCode: hsnCode,
        gstPercent: gstPercent,
        description: description,
      ),
    );
  }

  Future<CommonResponse> updateHsn({
    required int id,
    required String hsnCode,
    required double gstPercent,
    String? description,
  }) async {
    return await _apiProvider.updateHsn(
      id,
      HsnRequest(
        hsnCode: hsnCode,
        gstPercent: gstPercent,
        description: description,
      ),
    );
  }

  Future<CommonResponse> deleteHsn({required int id}) async {
    return await _apiProvider.deleteHsn(id);
  }

  // ─── Business Settings ──────────────────────────────────────────────────────
  Future<BusinessSettingsResponse> getBusinessSettings() async {
    return await _apiProvider.getBusinessSettings();
  }

  // Section getters
  Future<BusinessSettingsResponse> getSettingsSection(String section) async {
    switch (section) {
      case 'business-info':
        return await _apiProvider.getBusinessInfoSection();
      case 'contact':
        return await _apiProvider.getContactSection();
      case 'address':
        return await _apiProvider.getAddressSection();
      case 'branding':
        return await _apiProvider.getBrandingSection();
      case 'bank':
        return await _apiProvider.getBankSection();
      case 'payment':
        return await _apiProvider.getPaymentSection();
      case 'invoice':
        return await _apiProvider.getInvoiceSection();
      case 'social':
        return await _apiProvider.getSocialSection();
      default:
        throw ArgumentError('Unknown settings section: $section');
    }
  }

  // Section updaters — accepts a String→String form map and dispatches to the
  // appropriate typed request body for the given section.
  Future<BusinessSettingsResponse> updateSettingsSection({
    required String section,
    required Map<String, String> body,
  }) async {
    String? s(String key) => body.containsKey(key) ? body[key] : null;
    int? i(String key) => body.containsKey(key) && body[key]!.isNotEmpty
        ? int.tryParse(body[key]!)
        : null;
    double? d(String key) => body.containsKey(key) && body[key]!.isNotEmpty
        ? double.tryParse(body[key]!)
        : null;

    switch (section) {
      case 'business-info':
        return await _apiProvider.updateBusinessInfoSection(
          BusinessInfoSectionRequest(
            businessName: s('businessName'),
            legalBusinessName: s('legalBusinessName'),
            gstNumber: s('gstNumber'),
            panNumber: s('panNumber'),
            websiteUrl: s('websiteUrl'),
          ),
        );
      case 'contact':
        return await _apiProvider.updateContactSection(
          ContactSectionRequest(
            businessEmail: s('businessEmail'),
            businessPhone: s('businessPhone'),
            supportEmail: s('supportEmail'),
            supportPhone: s('supportPhone'),
          ),
        );
      case 'address':
        return await _apiProvider.updateAddressSection(
          AddressSectionRequest(
            addressLine1: s('addressLine1'),
            addressLine2: s('addressLine2'),
            city: s('city'),
            state: s('state'),
            country: s('country'),
            pincode: s('pincode'),
          ),
        );
      case 'bank':
        return await _apiProvider.updateBankSection(
          BankSectionRequest(
            accountHolderName: s('accountHolderName'),
            bankName: s('bankName'),
            accountNumber: s('accountNumber'),
            ifscCode: s('ifscCode'),
            branchName: s('branchName'),
          ),
        );
      case 'payment':
        return await _apiProvider.updatePaymentSection(
          PaymentSectionRequest(
            upiId: s('upiId'),
            razorpayKey: s('razorpayKey'),
            razorpaySecret: s('razorpaySecret'),
            stripePublicKey: s('stripePublicKey'),
            stripeSecretKey: s('stripeSecretKey'),
          ),
        );
      case 'invoice':
        return await _apiProvider.updateInvoiceSection(
          InvoiceSectionRequest(
            invoicePrefix: s('invoicePrefix'),
            invoiceStartNumber: i('invoiceStartNumber'),
            gstPercentage: d('gstPercentage'),
            invoiceFooter: s('invoiceFooter'),
            invoiceTerms: s('invoiceTerms'),
          ),
        );
      case 'social':
        return await _apiProvider.updateSocialSection(
          SocialSectionRequest(
            instagramUrl: s('instagramUrl'),
            facebookUrl: s('facebookUrl'),
            youtubeUrl: s('youtubeUrl'),
            twitterUrl: s('twitterUrl'),
          ),
        );
      default:
        throw ArgumentError('Unknown settings section: $section');
    }
  }

  Future<BusinessSettingsResponse> uploadBusinessLogo({
    required MultipartFile file,
  }) async {
    final formData = FormData.fromMap({'logo': file});
    return await _apiProvider.uploadBusinessLogo(formData);
  }

  Future<BusinessSettingsResponse> uploadBusinessFavicon({
    required MultipartFile file,
  }) async {
    final formData = FormData.fromMap({'favicon': file});
    return await _apiProvider.uploadBusinessFavicon(formData);
  }

  // ─── Support: Tickets ────────────────────────────────────────────────────
  Future<TicketListResponse> getTickets({
    int page = 1,
    int limit = 15,
    String? status,
    String? priority,
    String? search,
  }) async {
    final queries = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null) queries['status'] = status;
    if (priority != null) queries['priority'] = priority;
    if (search != null && search.isNotEmpty) queries['search'] = search;
    return await _apiProvider.getTickets(queries);
  }

  Future<TicketStatsResponse> getTicketStats() async {
    return await _apiProvider.getTicketStats();
  }

  Future<TicketDetailResponse> getTicketById({required int id}) async {
    return await _apiProvider.getTicketById(id);
  }

  Future<CommonResponse> replyToTicket({
    required int id,
    required String message,
    String senderType = 'admin',
    String? attachment,
  }) async {
    return await _apiProvider.replyToTicket(
      id,
      TicketReplyRequest(
        message: message,
        senderType: senderType,
        attachment: attachment,
      ),
    );
  }

  Future<CommonResponse> updateTicketStatus({
    required int id,
    required String status,
  }) async {
    return await _apiProvider.updateTicketStatus(
      id,
      StatusRequest(status: status),
    );
  }

  Future<CommonResponse> updateTicketPriority({
    required int id,
    required String priority,
  }) async {
    return await _apiProvider.updateTicketPriority(
      id,
      PriorityRequest(priority: priority),
    );
  }

  // ─── Support: Contact Messages ───────────────────────────────────────────
  Future<ContactMessageListResponse> getContactMessages({
    int page = 1,
    int limit = 15,
    String? status,
  }) async {
    final queries = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null) queries['status'] = status;
    return await _apiProvider.getContactMessages(queries);
  }

  Future<CommonResponse> updateContactMessageStatus({
    required int id,
    required String status,
  }) async {
    return await _apiProvider.updateContactMessageStatus(
      id,
      StatusRequest(status: status),
    );
  }

  // ─── Returns ─────────────────────────────────────────────────────────────
  Future<ReturnListResponse> getReturns({
    int page = 1,
    int limit = 15,
    String? status,
    String? search,
  }) async {
    final queries = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null) queries['status'] = status;
    if (search != null && search.isNotEmpty) queries['search'] = search;
    return await _apiProvider.getReturns(queries);
  }

  Future<ReturnStatsResponse> getReturnStats() async {
    return await _apiProvider.getReturnStats();
  }

  Future<ReturnDetailResponse> getReturnById({required int id}) async {
    return await _apiProvider.getReturnById(id);
  }

  Future<CommonResponse> updateReturnStatus({
    required int id,
    required String status,
    String? adminRemark,
    double? refundAmount,
    String? refundMethod,
  }) async {
    return await _apiProvider.updateReturnStatus(
      id,
      ReturnStatusUpdateRequest(
        status: status,
        adminRemark: adminRemark,
        refundAmount: refundAmount,
        refundMethod: refundMethod,
      ),
    );
  }

  // ─── Notifications ───────────────────────────────────────────────────────
  Future<NotificationListResponse> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    bool? isRead,
  }) async {
    final queries = <String, dynamic>{'page': page, 'limit': limit};
    if (type != null) queries['type'] = type;
    if (isRead != null) queries['isRead'] = isRead.toString();
    return await _apiProvider.getNotifications(queries);
  }

  Future<NotificationStatsResponse> getNotificationStats() async {
    return await _apiProvider.getNotificationStats();
  }

  Future<CommonResponse> markNotificationRead({required int id}) async {
    return await _apiProvider.markNotificationRead(id);
  }

  Future<CommonResponse> markAllNotificationsRead() async {
    return await _apiProvider.markAllNotificationsRead();
  }

  Future<CommonResponse> deleteNotification({required int id}) async {
    return await _apiProvider.deleteNotification(id);
  }

  // ─── GST Management ──────────────────────────────────────────────────────
  Future<GstDashboardResponse> getGstDashboard({
    String? startDate,
    String? endDate,
  }) async {
    final queries = <String, dynamic>{};
    if (startDate != null) queries['startDate'] = startDate;
    if (endDate != null) queries['endDate'] = endDate;
    return await _apiProvider.getGstDashboard(queries);
  }

  Future<StateGstResponse> getStateWiseGst({
    String? startDate,
    String? endDate,
  }) async {
    final queries = <String, dynamic>{};
    if (startDate != null) queries['startDate'] = startDate;
    if (endDate != null) queries['endDate'] = endDate;
    return await _apiProvider.getStateWiseGst(queries);
  }

  Future<InvoiceBreakupResponse> getInvoiceBreakup({
    int page = 1,
    int limit = 20,
    String? startDate,
    String? endDate,
  }) async {
    final queries = <String, dynamic>{'page': page, 'limit': limit};
    if (startDate != null) queries['startDate'] = startDate;
    if (endDate != null) queries['endDate'] = endDate;
    return await _apiProvider.getInvoiceBreakup(queries);
  }

  Future<HsnSummaryResponse> getHsnSummary({
    String? startDate,
    String? endDate,
  }) async {
    final queries = <String, dynamic>{};
    if (startDate != null) queries['startDate'] = startDate;
    if (endDate != null) queries['endDate'] = endDate;
    return await _apiProvider.getHsnSummary(queries);
  }

  Future<Gstr1Response> getGstr1({
    required int year,
    required int month,
  }) async {
    return await _apiProvider.getGstr1({'year': year, 'month': month});
  }

  Future<Gstr3bResponse> getGstr3b({
    required int year,
    required int month,
  }) async {
    return await _apiProvider.getGstr3b({'year': year, 'month': month});
  }

  Future<List<int>> exportGstMonthly({
    required int year,
    required int month,
    required String format,
  }) async {
    return await _apiProvider.exportGstMonthly({
      'year': year,
      'month': month,
      'format': format,
    });
  }

  Future<TaxSettingsResponse> getTaxSettings() async {
    return await _apiProvider.getTaxSettings();
  }

  Future<TaxSettingsResponse> updateTaxSettings({
    double? defaultGstPercent,
    String? invoiceTaxNote,
    String? gstInvoiceFooter,
    String? gstDeclaration,
  }) async {
    return await _apiProvider.updateTaxSettings(
      TaxSettingsRequest(
        defaultGstPercent: defaultGstPercent,
        invoiceTaxNote: invoiceTaxNote,
        gstInvoiceFooter: gstInvoiceFooter,
        gstDeclaration: gstDeclaration,
      ),
    );
  }

  // ─── Team / Managers ───────────────────────────────────────────────────────
  Future<ManagerListResponse> getManagers() async {
    return await _apiProvider.getManagers();
  }

  Future<ManagerDetailResponse> getManagerById({required int id}) async {
    return await _apiProvider.getManagerById(id);
  }

  Future<ManagerDetailResponse> createManager({
    required String name,
    required String email,
    required String password,
    String? mobile,
  }) async {
    return await _apiProvider.createManager(
      CreateManagerRequest(
        name: name,
        email: email,
        password: password,
        mobile: mobile,
      ),
    );
  }

  Future<ManagerDetailResponse> updateManager({
    required int id,
    String? name,
    String? email,
    String? mobile,
    String? password,
    String? status,
  }) async {
    return await _apiProvider.updateManager(
      id,
      UpdateManagerRequest(
        name: name,
        email: email,
        mobile: mobile,
        password: password,
        status: status,
      ),
    );
  }

  Future<CommonResponse> deleteManager({required int id}) async {
    return await _apiProvider.deleteManager(id);
  }

  // ─── Auth: refresh + logout ───────────────────────────────────────────────
  Future<CommonResponse> logout({
    String? refreshToken,
    bool? allDevices,
  }) async {
    return await _apiProvider.logout(
      LogoutRequest(refreshToken: refreshToken, allDevices: allDevices),
    );
  }

  // ─── Audit Logs ───────────────────────────────────────────────────────────
  Future<AuditLogListResponse> getAuditLogs({
    int page = 1,
    int limit = 20,
    String? module,
    String? action,
    String? entityType,
    int? userId,
    String? search,
    String? startDate,
    String? endDate,
  }) async {
    final queries = <String, dynamic>{'page': page, 'limit': limit};
    if (module != null) queries['module'] = module;
    if (action != null) queries['action'] = action;
    if (entityType != null) queries['entityType'] = entityType;
    if (userId != null) queries['userId'] = userId;
    if (search != null && search.isNotEmpty) queries['search'] = search;
    if (startDate != null) queries['startDate'] = startDate;
    if (endDate != null) queries['endDate'] = endDate;
    return await _apiProvider.getAuditLogs(queries);
  }

  Future<AuditFiltersResponse> getAuditFilters() async {
    return await _apiProvider.getAuditFilters();
  }

  Future<AuditLogDetailResponse> getAuditLogById({required int id}) async {
    return await _apiProvider.getAuditLogById(id);
  }

  // ─── Inventory Logs ───────────────────────────────────────────────────────
  Future<InventoryLogListResponse> getInventoryLogs({
    int page = 1,
    int limit = 20,
    int? productId,
    int? variantId,
    String? reason,
    int? userId,
    String? search,
    String? startDate,
    String? endDate,
  }) async {
    final queries = <String, dynamic>{'page': page, 'limit': limit};
    if (productId != null) queries['productId'] = productId;
    if (variantId != null) queries['variantId'] = variantId;
    if (reason != null) queries['reason'] = reason;
    if (userId != null) queries['userId'] = userId;
    if (search != null && search.isNotEmpty) queries['search'] = search;
    if (startDate != null) queries['startDate'] = startDate;
    if (endDate != null) queries['endDate'] = endDate;
    return await _apiProvider.getInventoryLogs(queries);
  }

  Future<InventoryLogHistoryResponse> getProductInventoryHistory({
    required int productId,
  }) async {
    return await _apiProvider.getProductInventoryHistory(productId);
  }

  Future<CommonResponse> adjustStock({
    required int productId,
    int? variantId,
    required int quantityChanged,
    required String reason,
    String? note,
  }) async {
    return await _apiProvider.adjustStock(
      StockAdjustRequest(
        productId: productId,
        variantId: variantId,
        quantityChanged: quantityChanged,
        reason: reason,
        note: note,
      ),
    );
  }

  // ─── Variants ─────────────────────────────────────────────────────────────
  Future<VariantListResponse> getVariantsForProduct({
    required int productId,
  }) async {
    return await _apiProvider.getVariantsForProduct(productId);
  }

  Future<VariantDetailResponse> getVariantById({required int id}) async {
    return await _apiProvider.getVariantById(id);
  }

  Future<VariantDetailResponse> createVariant({
    required int productId,
    required Map<String, dynamic> fields,
    MultipartFile? image,
  }) async {
    final map = <String, dynamic>{};
    fields.forEach((k, v) {
      if (v != null) map[k] = v.toString();
    });
    if (image != null) map['image'] = image;
    final formData = FormData.fromMap(map);
    return await _apiProvider.createVariant(productId, formData);
  }

  Future<VariantDetailResponse> updateVariant({
    required int id,
    required Map<String, dynamic> fields,
    MultipartFile? image,
  }) async {
    final map = <String, dynamic>{};
    fields.forEach((k, v) {
      if (v != null) map[k] = v.toString();
    });
    if (image != null) map['image'] = image;
    final formData = FormData.fromMap(map);
    return await _apiProvider.updateVariant(id, formData);
  }

  Future<CommonResponse> deleteVariant({required int id}) async {
    return await _apiProvider.deleteVariant(id);
  }

  Future<CommonResponse> updateVariantStock({
    required int id,
    required int stock,
  }) async {
    return await _apiProvider.updateVariantStock(
      id,
      VariantStockRequest(stock: stock),
    );
  }

  Future<CommonResponse> bulkUpdateVariants({
    required List<int> ids,
    required String op,
    dynamic value,
    double? mrp,
    double? sellingPrice,
  }) async {
    return await _apiProvider.bulkUpdateVariants(
      VariantBulkRequest(
        ids: ids,
        op: op,
        value: value,
        mrp: mrp,
        sellingPrice: sellingPrice,
      ),
    );
  }

  // ─── Permissions ──────────────────────────────────────────────────────────
  Future<PermissionCatalogResponse> getPermissionCatalog() async {
    return await _apiProvider.getPermissionCatalog();
  }

  Future<ManagerPermissionsResponse> getManagerPermissions({
    required int userId,
  }) async {
    return await _apiProvider.getManagerPermissions(userId);
  }

  Future<CommonResponse> replaceManagerPermissions({
    required int userId,
    required List<String> keys,
  }) async {
    return await _apiProvider.replaceManagerPermissions(
      userId,
      PermissionReplaceRequest(keys: keys),
    );
  }

  Future<CommonResponse> grantPermission({
    required int userId,
    required String key,
  }) async {
    return await _apiProvider.grantPermission(
      userId,
      PermissionKeyRequest(key: key),
    );
  }

  Future<CommonResponse> revokePermission({
    required int userId,
    required String key,
  }) async {
    return await _apiProvider.revokePermission(
      userId,
      PermissionKeyRequest(key: key),
    );
  }

  // ─── Coupons ───────────────────────────────────────────────────────────────
  Future<CouponListResponse> getCoupons() async {
    return await _apiProvider.getCoupons();
  }

  Future<CommonResponse> createCoupon({
    required String code,
    required String discountType,
    required double discountValue,
    double? minOrderAmount,
    String? expiryDate,
    int? usageLimit,
    String? status,
  }) async {
    return await _apiProvider.createCoupon(
      CouponRequest(
        code: code,
        discountType: discountType,
        discountValue: discountValue,
        minOrderAmount: minOrderAmount,
        expiryDate: expiryDate,
        usageLimit: usageLimit,
        status: status ?? 'active',
      ),
    );
  }

  Future<CommonResponse> updateCoupon({
    required int id,
    required String code,
    required String discountType,
    required double discountValue,
    double? minOrderAmount,
    String? expiryDate,
    int? usageLimit,
    String? status,
  }) async {
    return await _apiProvider.updateCoupon(
      id,
      CouponRequest(
        code: code,
        discountType: discountType,
        discountValue: discountValue,
        minOrderAmount: minOrderAmount,
        expiryDate: expiryDate,
        usageLimit: usageLimit,
        status: status ?? 'active',
      ),
    );
  }

  Future<CommonResponse> deleteCoupon({required int id}) async {
    return await _apiProvider.deleteCoupon(id);
  }

  Future<CommonResponse> updateCouponStatus({
    required int id,
    required String status,
  }) async {
    return await _apiProvider.updateCouponStatus(
      id,
      StatusRequest(status: status),
    );
  }

  // ─── Variant Groups ────────────────────────────────────────────────────────
  Future<VariantGroupResponse> createVariantGroup({
    required int parentId,
    required List<int> childIds,
    required Map<int, VariantGroupOption> optionsByProduct,
  }) async {
    return await _apiProvider.createVariantGroup(
      CreateVariantGroupRequest(
        parentId: parentId,
        childIds: childIds,
        optionsByProduct: optionsByProduct.map(
          (k, v) => MapEntry(k.toString(), v),
        ),
      ),
    );
  }

  Future<GroupableListResponse> getGroupableProducts({
    required int categoryId,
    int? excludeProductId,
    String? search,
  }) async {
    final queries = <String, dynamic>{'categoryId': categoryId};
    if (excludeProductId != null)
      queries['excludeProductId'] = excludeProductId;
    if (search != null && search.isNotEmpty) queries['search'] = search;
    return await _apiProvider.getGroupableProducts(queries);
  }

  Future<VariantGroupResponse> getProductGroup({required int id}) async {
    return await _apiProvider.getProductGroup(id);
  }

  Future<VariantGroupResponse> addToVariantGroup({
    required int anchorId,
    required int childId,
    String? color,
    String? size,
  }) async {
    return await _apiProvider.addToVariantGroup(
      anchorId,
      AddToVariantGroupRequest(childId: childId, color: color, size: size),
    );
  }

  Future<CommonResponse> removeFromVariantGroup({required int id}) async {
    return await _apiProvider.removeFromVariantGroup(id);
  }

  Future<VariantGroupResponse> promoteVariantToParent({required int id}) async {
    return await _apiProvider.promoteVariantToParent(id);
  }

  Future<CommonResponse> updateVariantGroupOptions({
    required int id,
    String? color,
    String? size,
  }) async {
    return await _apiProvider.updateVariantGroupOptions(
      id,
      VariantGroupOption(color: color, size: size),
    );
  }

  // ─── Super Admin: Colors Master ──────────────────────────────────────────────
  Future<ColorListResponse> getSuperAdminColors() async {
    return await _apiProvider.getSuperAdminColors();
  }

  Future<CommonResponse> createSuperAdminColor({
    required String name,
    String? hexCode,
    String? status,
  }) async {
    final body = <String, dynamic>{'name': name};
    if (hexCode != null) body['hexCode'] = hexCode;
    if (status != null) body['status'] = status;
    return await _apiProvider.createSuperAdminColor(body);
  }

  Future<CommonResponse> updateSuperAdminColor({
    required int id,
    String? name,
    String? hexCode,
    String? status,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (hexCode != null) body['hexCode'] = hexCode;
    if (status != null) body['status'] = status;
    return await _apiProvider.updateSuperAdminColor(id, body);
  }

  Future<CommonResponse> deleteSuperAdminColor({required int id}) async {
    return await _apiProvider.deleteSuperAdminColor(id);
  }

  // ─── Super Admin: Materials Master ─────────────────────────────────────────
  Future<MaterialListResponse> getSuperAdminMaterials() async {
    return await _apiProvider.getSuperAdminMaterials();
  }

  Future<CommonResponse> createSuperAdminMaterial({
    required String name,
    String? description,
    String? status,
  }) async {
    final body = <String, dynamic>{'name': name};
    if (description != null) body['description'] = description;
    if (status != null) body['status'] = status;
    return await _apiProvider.createSuperAdminMaterial(body);
  }

  Future<CommonResponse> updateSuperAdminMaterial({
    required int id,
    String? name,
    String? description,
    String? status,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (status != null) body['status'] = status;
    return await _apiProvider.updateSuperAdminMaterial(id, body);
  }

  Future<CommonResponse> deleteSuperAdminMaterial({required int id}) async {
    return await _apiProvider.deleteSuperAdminMaterial(id);
  }

  // ─── Masters (read-only for brand users) ───────────────────────────────────
  Future<ColorListResponse> getMasterColors() async {
    return await _apiProvider.getMasterColors();
  }

  Future<MaterialListResponse> getMasterMaterials() async {
    return await _apiProvider.getMasterMaterials();
  }

  // ─── Super Admin: Themes ──────────────────────────────────────────────────
  Future<CommonResponse> createTheme({required FormData formData}) async {
    return await _apiProvider.createTheme(formData);
  }

  Future<ThemeListResponse> listThemes({
    int page = 1,
    int limit = 10,
    String? search,
    String? mode,
    String? status,
  }) async {
    final queries = <String, dynamic>{'page': page, 'limit': limit};
    if (search != null && search.isNotEmpty) queries['search'] = search;
    if (mode != null) queries['mode'] = mode;
    if (status != null) queries['status'] = status;
    return await _apiProvider.listThemes(queries);
  }

  Future<ThemeDetailResponse> getTheme({required int id}) async {
    return await _apiProvider.getTheme(id);
  }

  Future<CommonResponse> updateTheme({
    required int id,
    required FormData formData,
  }) async {
    return await _apiProvider.updateTheme(id, formData);
  }

  Future<CommonResponse> deleteTheme({required int id}) async {
    return await _apiProvider.deleteTheme(id);
  }

  Future<CommonResponse> setDefaultTheme({required int id}) async {
    return await _apiProvider.setDefaultTheme(id);
  }

  Future<CommonResponse> toggleThemeStatus({required int id}) async {
    return await _apiProvider.toggleThemeStatus(id);
  }

  // ─── Super Admin: Theme Preview Sections ──────────────────────────────────
  Future<CommonResponse> createPreviewSection({
    required int themeId,
    required ThemePreviewSectionRequest body,
  }) async {
    return await _apiProvider.createPreviewSection(themeId, body);
  }

  Future<ThemeListResponse> listPreviewSections({required int themeId}) async {
    return await _apiProvider.listPreviewSections(themeId);
  }

  Future<CommonResponse> updatePreviewSection({
    required int themeId,
    required int id,
    required ThemePreviewSectionRequest body,
  }) async {
    return await _apiProvider.updatePreviewSection(themeId, id, body);
  }

  Future<CommonResponse> deletePreviewSection({
    required int themeId,
    required int id,
  }) async {
    return await _apiProvider.deletePreviewSection(themeId, id);
  }

  // ─── Masters: Themes ──────────────────────────────────────────────────────
  Future<ThemeListResponse> listActiveThemes() async {
    return await _apiProvider.listActiveThemes();
  }

  // ─── Admin Theme ──────────────────────────────────────────────────────────
  Future<CommonResponse> selectTheme({required ThemeSelectRequest body}) async {
    return await _apiProvider.selectTheme(body);
  }

  Future<CurrentThemeResponse> getCurrentTheme() async {
    return await _apiProvider.getCurrentTheme();
  }
}
