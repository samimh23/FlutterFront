
import 'package:hanouty/Core/Utils/Api_EndPoints.dart';
import 'package:hanouty/Presentation/Auth/data/models/create_user_dto.dart';
import 'package:hanouty/Presentation/Auth/domain/entities/user.dart';

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

  @override
  Future<User> registerUser(CreateUserDto createUserDto) async {
    try {
      final response = await _apiClient.post(
        endpoint: ApiEndpoints.signupEndpint, // Adjust endpoint to match your NestJS route
        data: createUserDto.toJson(),
      );

      return User.fromJson(response);
    } catch (e) {
      rethrow; // Pass the error to be handled by the use case or controller
    }

   }


}