import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../model/response/response.dart';

part 'super_admin_api.g.dart';

/// Retrofit client wrapping all `/api/super-admin/*` endpoints.
///
/// Covers:
/// - Dashboard KPIs (Requirement 9.1)
/// - Admin lifecycle CRUD + paginated list (Requirements 8.1, 10.1)
/// - Masters CRUD for categories, HSN, colors, materials (Requirement 5.1)
@RestApi()
abstract class SuperAdminApi {
  factory SuperAdminApi(Dio dio, {String baseUrl}) = _SuperAdminApi;

  // ─── Dashboard (Requirement 9.1) ────────────────────────────────────────────
  @GET("super-admin/dashboard")
  Future<CommonResponse> getDashboard();

  // ─── Admins (Requirements 8.1, 10.1) ───────────────────────────────────────
  @GET("super-admin/admins")
  Future<CommonResponse> getAdmins(@Queries() Map<String, dynamic> queries);

  @GET("super-admin/admins/{id}")
  Future<CommonResponse> getAdminById(@Path('id') int id);

  @POST("super-admin/admins")
  Future<CommonResponse> createAdmin(@Body() Map<String, dynamic> body);

  @PUT("super-admin/admins/{id}")
  Future<CommonResponse> updateAdmin(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE("super-admin/admins/{id}")
  Future<CommonResponse> deleteAdmin(@Path('id') int id);

  // ─── Masters: Categories (Requirement 5.1) ─────────────────────────────────
  @GET("super-admin/masters/categories")
  Future<CategoryListResponse> getCategories();

  @POST("super-admin/masters/categories")
  Future<CommonResponse> createCategory(@Body() Map<String, dynamic> body);

  @PUT("super-admin/masters/categories/{id}")
  Future<CommonResponse> updateCategory(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE("super-admin/masters/categories/{id}")
  Future<CommonResponse> deleteCategory(@Path('id') int id);

  // ─── Masters: HSN (Requirement 5.1) ────────────────────────────────────────
  @GET("super-admin/masters/hsn")
  Future<HsnListResponse> getHsnCodes();

  @POST("super-admin/masters/hsn")
  Future<CommonResponse> createHsn(@Body() Map<String, dynamic> body);

  @PUT("super-admin/masters/hsn/{id}")
  Future<CommonResponse> updateHsn(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE("super-admin/masters/hsn/{id}")
  Future<CommonResponse> deleteHsn(@Path('id') int id);

  // ─── Masters: Colors (Requirement 5.1) ─────────────────────────────────────
  @GET("super-admin/masters/colors")
  Future<ColorListResponse> getColors();

  @POST("super-admin/masters/colors")
  Future<CommonResponse> createColor(@Body() Map<String, dynamic> body);

  @PUT("super-admin/masters/colors/{id}")
  Future<CommonResponse> updateColor(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE("super-admin/masters/colors/{id}")
  Future<CommonResponse> deleteColor(@Path('id') int id);

  // ─── Masters: Materials (Requirement 5.1) ───────────────────────────────────
  @GET("super-admin/masters/materials")
  Future<MaterialListResponse> getMaterials();

  @POST("super-admin/masters/materials")
  Future<CommonResponse> createMaterial(@Body() Map<String, dynamic> body);

  @PUT("super-admin/masters/materials/{id}")
  Future<CommonResponse> updateMaterial(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE("super-admin/masters/materials/{id}")
  Future<CommonResponse> deleteMaterial(@Path('id') int id);
}
