import 'package:dio/dio.dart';

import '../Utils/Api_EndPoints.dart';
import '../Utils/secure_storage.dart';
import 'api_exceptions.dart';


class ApiClient {
  late Dio _dio;
  final SecureStorageService _secureStorageService = SecureStorageService();

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
  Future<Map<String, dynamic>> get({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // General method for PUT requests
  Future<Map<String, dynamic>> put({
    required String endpoint,
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final accessToken = await _secureStorageService.getAccessToken();
      final response = await _dio.get(
        ApiEndpoints.getProfileEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // General method for DELETE requests
  Future<Map<String, dynamic>> delete({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
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

  Future<Options> _getAuthOptions() async {
    final accessToken = await _secureStorageService.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw UnauthorizedException('Authentication token not available');
    }
    return Options(headers: {'Authorization': 'Bearer $accessToken'});
  }

  // 2FA Methods
  Future<Map<String, dynamic>> generateTwoFactorSecret() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        ApiEndpoints.generateTwoFactorSecretEndpoint,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      print('Error generating 2FA secret: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> enableTwoFactor(String verificationCode) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        ApiEndpoints.enableTwoFactorEndpoint,
        data: {'twoFactorCode': verificationCode},
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      print('Error enabling 2FA: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> disableTwoFactor() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        ApiEndpoints.disableTwoFactorEndpoint,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      print('Error disabling 2FA: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> verifyTwoFactorAuth({
    required String userId,
    required String twoFactorCode,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.verifyTwoFactorEndpoint,
        data: {
          'userId': userId,
          'twoFactorCode': twoFactorCode,
        },
      );

      // If verification is successful and returns tokens, save them
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('accessToken')) {
          await _secureStorageService.saveAccessToken(data['accessToken']);
        }
        if (data.containsKey('refreshToken')) {
          await _secureStorageService.saveRefreshToken(data['refreshToken']);
        }
      }

      return response.data;
    } on DioException catch (e) {
      print('Error verifying 2FA: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  // Error handling

}