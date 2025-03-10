import '../../../../Core/Enums/role_enum.dart';
import '../../domain/entities/user.dart';

import 'dart:convert';

import 'dart:convert';
import '../../domain/entities/user.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User? user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final String token = json['accessToken'] ?? json['access_token'] ?? '';

    // Decode JWT token to get user data
    User? user;
    if (token.isNotEmpty) {
      try {
        final parts = token.split('.');
        if (parts.length > 1) {
          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final decoded = utf8.decode(base64Url.decode(normalized));
          final decodedJson = jsonDecode(decoded);

          print('Decoded JWT payload: $decodedJson'); // Debug print

          // Convert the role string to Role enum using your RoleExtension
          final roleString = decodedJson['role'] ?? 'Client';
          final role = RoleExtension.fromString(roleString);

          print('Converted role string "$roleString" to enum: ${role.value}'); // Debug print

          // Create user from JWT payload
          user = User(
            id: decodedJson['userId'] ?? '',
            email: decodedJson['email'] ?? '',
            name: decodedJson['name'],
            lastName: decodedJson['lastName'],
            role: role, // Pass the Role enum value
          );
          print('Created user with role: ${user.role.value}'); // Debug print
        }
      } catch (e) {
        print('Error decoding JWT: $e');
      }
    }

    return AuthResponse(
      accessToken: token,
      refreshToken: json['refreshToken'] ?? '',
      user: user,
    );
  }
}