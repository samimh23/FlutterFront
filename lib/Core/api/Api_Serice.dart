import 'package:dio/dio.dart';

import '../Utils/Api_EndPoints.dart';
import 'api_exceptions.dart';


class ApiClient {
  late Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: Duration(seconds: ApiEndpoints.timeoutSeconds),
        receiveTimeout: Duration(seconds: ApiEndpoints.timeoutSeconds),
        contentType: 'application/json',
      ),
    );

    // Add logging interceptor for debugging
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // General method for POST requests
  Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  Exception _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final responseData = error.response!.data;

      switch (statusCode) {
        case 400:
          return BadRequestException(
            responseData['message'] ?? 'Bad request',
          );
        case 401:
          return UnauthorizedException(
            responseData['message'] ?? 'Unauthorized',
          );
        case 404:
          return NotFoundException(
            responseData['message'] ?? 'Resource not found',
          );
        default:
          return ApiException(
            responseData['message'] ?? 'Server error',
          );
      }
    }

    return NetworkException('Connection error: ${error.message}');
  }
}