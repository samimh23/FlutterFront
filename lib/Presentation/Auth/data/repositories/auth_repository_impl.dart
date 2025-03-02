
import 'package:hanouty/Core/Utils/Api_EndPoints.dart';

import '../../../../Core/api/Api_Serice.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      endpoint: ApiEndpoints.loginEndpoint,
      data: {
        'email': email,
        'password': password,
      },
    );

    return response;
  }


}