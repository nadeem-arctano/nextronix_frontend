import 'package:dio/dio.dart';

class AlertErrorResponse {
  final String alertHeading;
  final String alertMessage;

  AlertErrorResponse({required this.alertHeading, required this.alertMessage});

  /// Extracts a user-friendly error from a caught exception
  static AlertErrorResponse getErrorResponse(dynamic e) {
    if (e is DioException) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        return AlertErrorResponse(
          alertHeading: "Error!",
          alertMessage:
              responseData["message"]?.toString() ?? "Something went wrong",
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
