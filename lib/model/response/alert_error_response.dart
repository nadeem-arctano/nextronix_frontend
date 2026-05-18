import 'package:dio/dio.dart';

class AlertErrorResponse {
  final String alertHeading;
  final String alertMessage;

  /// The structured error code returned by the API (e.g.
  /// `MISSING_FIELD`, `INVALID_MASTER_REFERENCE`, `INACTIVE_MASTER_REFERENCE`).
  final String? code;

  /// The field name the error relates to (e.g. `categoryId`, `colorId`).
  final String? field;

  AlertErrorResponse({
    required this.alertHeading,
    required this.alertMessage,
    this.code,
    this.field,
  });

  /// Whether this error is a master validation error that should be surfaced
  /// inline next to a form field.
  bool get isMasterValidationError =>
      code == 'MISSING_FIELD' ||
      code == 'INVALID_MASTER_REFERENCE' ||
      code == 'INACTIVE_MASTER_REFERENCE';

  /// Extracts a user-friendly error from a caught exception
  static AlertErrorResponse getErrorResponse(dynamic e) {
    if (e is DioException) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        return AlertErrorResponse(
          alertHeading: "Error!",
          alertMessage:
              responseData["message"]?.toString() ?? "Something went wrong",
          code: responseData["code"]?.toString(),
          field: responseData["field"]?.toString(),
        );
      }
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return AlertErrorResponse(
            alertHeading: "Timeout!",
            alertMessage: "Connection timed out. Please try again.",
          );
        case DioExceptionType.connectionError:
          return AlertErrorResponse(
            alertHeading: "No Connection!",
            alertMessage: "Unable to connect to server. Check your internet.",
          );
        default:
          return AlertErrorResponse(
            alertHeading: "Error!",
            alertMessage: e.message ?? "Something went wrong",
          );
      }
    }
    return AlertErrorResponse(
      alertHeading: "Error!",
      alertMessage: e.toString(),
    );
  }
}
