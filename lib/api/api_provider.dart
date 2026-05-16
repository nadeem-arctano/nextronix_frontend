import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../model/request/request.dart';
import '../model/response/response.dart';
part 'api_provider.g.dart';

@RestApi()
abstract class ApiProvider {
  factory ApiProvider(Dio dio, {String baseUrl}) = _ApiProvider;

  // ─── Auth ───────────────────────────────────────────────────────────────────
  @POST("auth/login")
  Future<LoginResponse> userLogin(@Body() LoginRequest loginRequest);

  @POST("auth/register")
  Future<CommonResponse> register(@Body() RegisterRequest registerRequest);

  @POST("auth/refresh")
  Future<LoginResponse> refreshAccessToken(@Body() RefreshTokenRequest body);

  @POST("auth/logout")
  Future<CommonResponse> logout(@Body() LogoutRequest body);

  @GET("auth/me")
  Future<ProfileResponse> getProfile();

  // ─── Categories ─────────────────────────────────────────────────────────────
  @GET("categories")
  Future<CategoryListResponse> getCategories();

  @POST("categories")
  Future<CommonResponse> createCategory(@Body() FormData formData);

  @POST("categories/{id}")
  Future<CommonResponse> updateCategory(
    @Path('id') int id,
    @Body() FormData formData,
  );

  @DELETE("categories/{id}")
  Future<CommonResponse> deleteCategory(@Path('id') int id);

  @PATCH("categories/{id}/status")
  Future<CommonResponse> updateCategoryStatus(
    @Path('id') int id,
    @Body() StatusRequest statusRequest,
  );

  // ─── Products ───────────────────────────────────────────────────────────────
  @GET("products")
  Future<ProductListResponse> getProducts(
    @Queries() Map<String, dynamic> queries,
  );

  @GET("products/{id}")
  Future<ProductDetailResponse> getProductById(@Path('id') int id);

  @POST("products")
  @MultiPart()
  Future<CommonResponse> createProduct(@Body() FormData formData);

  @PUT("products/{id}")
  @MultiPart()
  Future<CommonResponse> updateProduct(
    @Path('id') int id,
    @Body() FormData formData,
  );

  @DELETE("products/{id}")
  Future<CommonResponse> deleteProduct(@Path('id') int id);

  @PATCH("products/{id}/status")
  Future<CommonResponse> updateProductStatus(
    @Path('id') int id,
    @Body() StatusRequest statusRequest,
  );

  @PATCH("products/{id}/featured")
  Future<CommonResponse> toggleProductFeatured(@Path('id') int id);

  @PATCH("products/{id}/price")
  Future<CommonResponse> updateProductPrice(
    @Path('id') int id,
    @Body() PriceUpdateRequest body,
  );

  @PATCH("products/{id}/stock")
  Future<CommonResponse> updateProductStock(
    @Path('id') int id,
    @Body() StockUpdateRequest body,
  );

  @GET("products/search")
  Future<ProductListResponse> searchProducts(
    @Queries() Map<String, dynamic> queries,
  );

  @GET("products/low-stock")
  Future<ProductListResponse> getLowStockProducts();

  @POST("products/bulk/delete")
  Future<CommonResponse> bulkDeleteProducts(
    @Body() BulkIdsRequest bulkIdsRequest,
  );

  @POST("products/bulk/status")
  Future<CommonResponse> bulkUpdateProductStatus(
    @Body() BulkStatusRequest bulkStatusRequest,
  );

  // ─── Orders ─────────────────────────────────────────────────────────────────
  @GET("orders")
  Future<OrderListResponse> getOrders(@Queries() Map<String, dynamic> queries);

  @GET("orders/{id}")
  Future<OrderDetailResponse> getOrderById(@Path('id') int id);

  @PATCH("orders/{id}/status")
  Future<CommonResponse> updateOrderStatus(
    @Path('id') int id,
    @Body() StatusRequest statusRequest,
  );

  @PATCH("orders/{id}/payment-status")
  Future<CommonResponse> updatePaymentStatus(
    @Path('id') int id,
    @Body() PaymentStatusRequest paymentStatusRequest,
  );

  @GET("orders/stats")
  Future<OrderStatsResponse> getOrderStats();

  // ─── Dashboard ──────────────────────────────────────────────────────────────
  @GET("dashboard/stats")
  Future<DashboardStatsResponse> getDashboardStats();

  @GET("dashboard/revenue")
  Future<RevenueListResponse> getDashboardRevenue(@Query('period') int period);

  @GET("dashboard/recent-orders")
  Future<OrderListResponse> getDashboardRecentOrders(@Query('limit') int limit);

  @GET("dashboard/top-products")
  Future<ProductListResponse> getDashboardTopProducts(
    @Query('limit') int limit,
  );

  @GET("dashboard/low-stock")
  Future<ProductListResponse> getDashboardLowStock();

  @GET("dashboard/order-chart")
  Future<OrderChartResponse> getDashboardOrderChart();

  @GET("dashboard/category-stats")
  Future<CategoryStatsResponse> getDashboardCategoryStats();

  @GET("dashboard/recent-users")
  Future<UserListResponse> getDashboardRecentUsers(@Query('limit') int limit);

  // ─── Coupons ────────────────────────────────────────────────────────────────
  @GET("coupons")
  Future<CouponListResponse> getCoupons();

  @GET("coupons/{id}")
  Future<CouponDetailResponse> getCouponById(@Path('id') int id);

  @POST("coupons")
  Future<CommonResponse> createCoupon(@Body() CouponRequest couponRequest);

  @PUT("coupons/{id}")
  Future<CommonResponse> updateCoupon(
    @Path('id') int id,
    @Body() CouponRequest couponRequest,
  );

  @DELETE("coupons/{id}")
  Future<CommonResponse> deleteCoupon(@Path('id') int id);

  @PATCH("coupons/{id}/status")
  Future<CommonResponse> updateCouponStatus(
    @Path('id') int id,
    @Body() StatusRequest statusRequest,
  );

  // ─── Users ──────────────────────────────────────────────────────────────────
  @GET("users")
  Future<UserListResponse> getUsers(@Queries() Map<String, dynamic> queries);

  @PATCH("users/{id}/status")
  Future<CommonResponse> updateUserStatus(
    @Path('id') int id,
    @Body() StatusRequest statusRequest,
  );

  // ─── HSN Codes ─────────────────────────────────────────────────────────────
  @GET("hsn")
  Future<HsnListResponse> getHsnCodes();

  @POST("hsn")
  Future<CommonResponse> createHsn(@Body() HsnRequest body);

  @PUT("hsn/{id}")
  Future<CommonResponse> updateHsn(@Path('id') int id, @Body() HsnRequest body);

  @DELETE("hsn/{id}")
  Future<CommonResponse> deleteHsn(@Path('id') int id);

  // ─── Business Settings ──────────────────────────────────────────────────────
  @GET("business-settings")
  Future<BusinessSettingsResponse> getBusinessSettings();

  // Section: Business Info
  @GET("business-settings/business-info")
  Future<BusinessSettingsResponse> getBusinessInfoSection();

  @PUT("business-settings/business-info")
  Future<BusinessSettingsResponse> updateBusinessInfoSection(
    @Body() BusinessInfoSectionRequest body,
  );

  // Section: Contact
  @GET("business-settings/contact")
  Future<BusinessSettingsResponse> getContactSection();

  @PUT("business-settings/contact")
  Future<BusinessSettingsResponse> updateContactSection(
    @Body() ContactSectionRequest body,
  );

  // Section: Address
  @GET("business-settings/address")
  Future<BusinessSettingsResponse> getAddressSection();

  @PUT("business-settings/address")
  Future<BusinessSettingsResponse> updateAddressSection(
    @Body() AddressSectionRequest body,
  );

  // Section: Branding
  @GET("business-settings/branding")
  Future<BusinessSettingsResponse> getBrandingSection();

  @POST("business-settings/branding/logo")
  @MultiPart()
  Future<BusinessSettingsResponse> uploadBusinessLogo(
    @Body() FormData formData,
  );

  @POST("business-settings/branding/favicon")
  @MultiPart()
  Future<BusinessSettingsResponse> uploadBusinessFavicon(
    @Body() FormData formData,
  );

  // Section: Bank
  @GET("business-settings/bank")
  Future<BusinessSettingsResponse> getBankSection();

  @PUT("business-settings/bank")
  Future<BusinessSettingsResponse> updateBankSection(
    @Body() BankSectionRequest body,
  );

  // Section: Payment
  @GET("business-settings/payment")
  Future<BusinessSettingsResponse> getPaymentSection();

  @PUT("business-settings/payment")
  Future<BusinessSettingsResponse> updatePaymentSection(
    @Body() PaymentSectionRequest body,
  );

  // Section: Invoice
  @GET("business-settings/invoice")
  Future<BusinessSettingsResponse> getInvoiceSection();

  @PUT("business-settings/invoice")
  Future<BusinessSettingsResponse> updateInvoiceSection(
    @Body() InvoiceSectionRequest body,
  );

  // Section: Social
  @GET("business-settings/social")
  Future<BusinessSettingsResponse> getSocialSection();

  @PUT("business-settings/social")
  Future<BusinessSettingsResponse> updateSocialSection(
    @Body() SocialSectionRequest body,
  );

  // ─── Support: Tickets ───────────────────────────────────────────────────────
  @GET("support/tickets")
  Future<TicketListResponse> getTickets(
    @Queries() Map<String, dynamic> queries,
  );

  @GET("support/tickets/stats")
  Future<TicketStatsResponse> getTicketStats();

  @GET("support/tickets/{id}")
  Future<TicketDetailResponse> getTicketById(@Path('id') int id);

  @POST("support/tickets/{id}/reply")
  Future<CommonResponse> replyToTicket(
    @Path('id') int id,
    @Body() TicketReplyRequest body,
  );

  @PATCH("support/tickets/{id}/status")
  Future<CommonResponse> updateTicketStatus(
    @Path('id') int id,
    @Body() StatusRequest body,
  );

  @PATCH("support/tickets/{id}/priority")
  Future<CommonResponse> updateTicketPriority(
    @Path('id') int id,
    @Body() PriorityRequest body,
  );

  // ─── Support: Contact Messages ──────────────────────────────────────────────
  @GET("support/contact-messages")
  Future<ContactMessageListResponse> getContactMessages(
    @Queries() Map<String, dynamic> queries,
  );

  @PATCH("support/contact-messages/{id}/status")
  Future<CommonResponse> updateContactMessageStatus(
    @Path('id') int id,
    @Body() StatusRequest body,
  );

  // ─── Returns ───────────────────────────────────────────────────────────────
  @GET("returns")
  Future<ReturnListResponse> getReturns(
    @Queries() Map<String, dynamic> queries,
  );

  @GET("returns/stats")
  Future<ReturnStatsResponse> getReturnStats();

  @GET("returns/{id}")
  Future<ReturnDetailResponse> getReturnById(@Path('id') int id);

  @PATCH("returns/{id}/status")
  Future<CommonResponse> updateReturnStatus(
    @Path('id') int id,
    @Body() ReturnStatusUpdateRequest body,
  );

  // ─── Notifications ─────────────────────────────────────────────────────────
  @GET("notifications")
  Future<NotificationListResponse> getNotifications(
    @Queries() Map<String, dynamic> queries,
  );

  @GET("notifications/stats")
  Future<NotificationStatsResponse> getNotificationStats();

  @PATCH("notifications/{id}/read")
  Future<CommonResponse> markNotificationRead(@Path('id') int id);

  @PATCH("notifications/read-all")
  Future<CommonResponse> markAllNotificationsRead();

  @DELETE("notifications/{id}")
  Future<CommonResponse> deleteNotification(@Path('id') int id);

  // ─── GST Management ────────────────────────────────────────────────────────
  @GET("gst/dashboard")
  Future<GstDashboardResponse> getGstDashboard(
    @Queries() Map<String, dynamic> queries,
  );

  @GET("gst/state-wise")
  Future<StateGstResponse> getStateWiseGst(
    @Queries() Map<String, dynamic> queries,
  );

  @GET("gst/invoice-breakup")
  Future<InvoiceBreakupResponse> getInvoiceBreakup(
    @Queries() Map<String, dynamic> queries,
  );

  @GET("gst/hsn-summary")
  Future<HsnSummaryResponse> getHsnSummary(
    @Queries() Map<String, dynamic> queries,
  );

  @GET("gst/gstr1")
  Future<Gstr1Response> getGstr1(@Queries() Map<String, dynamic> queries);

  @GET("gst/gstr3b")
  Future<Gstr3bResponse> getGstr3b(@Queries() Map<String, dynamic> queries);

  @GET("gst/export/monthly")
  @DioResponseType(ResponseType.bytes)
  Future<List<int>> exportGstMonthly(@Queries() Map<String, dynamic> queries);

  @GET("gst/settings")
  Future<TaxSettingsResponse> getTaxSettings();

  @PUT("gst/settings")
  Future<TaxSettingsResponse> updateTaxSettings(
    @Body() TaxSettingsRequest body,
  );

  // ─── Team / Managers ───────────────────────────────────────────────────────
  @GET("team/managers")
  Future<ManagerListResponse> getManagers();

  @GET("team/managers/{id}")
  Future<ManagerDetailResponse> getManagerById(@Path('id') int id);

  @POST("team/managers")
  Future<ManagerDetailResponse> createManager(
    @Body() CreateManagerRequest body,
  );

  @PUT("team/managers/{id}")
  Future<ManagerDetailResponse> updateManager(
    @Path('id') int id,
    @Body() UpdateManagerRequest body,
  );

  @DELETE("team/managers/{id}")
  Future<CommonResponse> deleteManager(@Path('id') int id);

  // ─── Audit Logs ────────────────────────────────────────────────────────────
  @GET("audit-logs")
  Future<AuditLogListResponse> getAuditLogs(
    @Queries() Map<String, dynamic> queries,
  );

  @GET("audit-logs/filters")
  Future<AuditFiltersResponse> getAuditFilters();

  @GET("audit-logs/{id}")
  Future<AuditLogDetailResponse> getAuditLogById(@Path('id') int id);

  // ─── Inventory Logs ────────────────────────────────────────────────────────
  @GET("inventory-logs")
  Future<InventoryLogListResponse> getInventoryLogs(
    @Queries() Map<String, dynamic> queries,
  );

  @GET("inventory-logs/product/{productId}")
  Future<InventoryLogHistoryResponse> getProductInventoryHistory(
    @Path('productId') int productId,
  );

  @POST("inventory-logs/adjust")
  Future<CommonResponse> adjustStock(@Body() StockAdjustRequest body);

  // ─── Variants ──────────────────────────────────────────────────────────────
  @GET("variants/products/{productId}")
  Future<VariantListResponse> getVariantsForProduct(
    @Path('productId') int productId,
  );

  @GET("variants/{id}")
  Future<VariantDetailResponse> getVariantById(@Path('id') int id);

  @POST("variants/products/{productId}")
  @MultiPart()
  Future<VariantDetailResponse> createVariant(
    @Path('productId') int productId,
    @Body() FormData formData,
  );

  @PUT("variants/{id}")
  @MultiPart()
  Future<VariantDetailResponse> updateVariant(
    @Path('id') int id,
    @Body() FormData formData,
  );

  @DELETE("variants/{id}")
  Future<CommonResponse> deleteVariant(@Path('id') int id);

  @PATCH("variants/{id}/stock")
  Future<CommonResponse> updateVariantStock(
    @Path('id') int id,
    @Body() VariantStockRequest body,
  );

  @POST("variants/bulk")
  Future<CommonResponse> bulkUpdateVariants(@Body() VariantBulkRequest body);

  // ─── Permissions ───────────────────────────────────────────────────────────
  @GET("permissions/catalog")
  Future<PermissionCatalogResponse> getPermissionCatalog();

  @GET("permissions/managers/{userId}")
  Future<ManagerPermissionsResponse> getManagerPermissions(
    @Path('userId') int userId,
  );

  @PUT("permissions/managers/{userId}")
  Future<CommonResponse> replaceManagerPermissions(
    @Path('userId') int userId,
    @Body() PermissionReplaceRequest body,
  );

  @POST("permissions/managers/{userId}/grant")
  Future<CommonResponse> grantPermission(
    @Path('userId') int userId,
    @Body() PermissionKeyRequest body,
  );

  @POST("permissions/managers/{userId}/revoke")
  Future<CommonResponse> revokePermission(
    @Path('userId') int userId,
    @Body() PermissionKeyRequest body,
  );
}
