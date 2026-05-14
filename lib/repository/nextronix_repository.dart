import 'package:dio/dio.dart';

import '../api/api_provider.dart';
import '../api/base_url.dart';
import '../model/request/request.dart';
import '../model/response/response.dart';
import '../static_values/static_values.dart';

class NextronixRepository {
  late ApiProvider _apiProvider;
  late Dio _dio;

  NextronixRepository() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Interceptor: Injects auth token + handles 401 (JWT expired)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (globalAccessToken != null) {
            options.headers["Authorization"] = "Bearer $globalAccessToken";
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
            // Handle token expiry → redirect to login
            globalAccessToken = null;
          }
          handler.next(e);
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );

    _apiProvider = ApiProvider(_dio, baseUrl: BaseUrl.baseurl);
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
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (image != null) 'image': image,
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
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (image != null) 'image': image,
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
  }) async {
    final queries = <String, dynamic>{'page': page, 'limit': limit};
    if (search != null && search.isNotEmpty) queries['search'] = search;
    if (category != null) queries['category'] = category;
    if (status != null) queries['status'] = status;
    if (sortBy != null) queries['sortBy'] = sortBy;
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
}
