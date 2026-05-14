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
}
