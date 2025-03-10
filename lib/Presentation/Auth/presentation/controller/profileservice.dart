import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../Core/Utils/secure_storage.dart';
import '../../../../Core/api/api_exceptions.dart';
import '../../data/models/user.dart';


class ProfileService {
  final SecureStorageService _secureStorageService;
  final String _baseUrl;

  ProfileService({
    required String baseUrl,
    SecureStorageService? secureStorageService,
  }) :
        _baseUrl = baseUrl,
        _secureStorageService = secureStorageService ?? SecureStorageService();

  Future<User> getProfile() async {
    final token = await _secureStorageService.getAccessToken();

    if (token == null) {
      throw ApiException('Authentication required');
    }

    try {
      // Simply call the profile endpoint exactly as in Postman
      final response = await http.get(
        Uri.parse('$_baseUrl/users/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Profile API Response Code: ${response.statusCode}');
      print('Profile API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        return User.fromJson(userData);
      } else if (response.statusCode == 401) {
        throw ApiException('Authentication failed');
      } else if (response.statusCode == 404) {
        throw ApiException('User not found');
      } else {
        throw ApiException('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Profile fetch error: $e');
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('An unexpected error occurred: ${e.toString()}');
    }
  }
}