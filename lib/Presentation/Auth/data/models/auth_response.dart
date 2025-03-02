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
    User? user;
    if (json.containsKey('user')) {
      final userData = json['user'];
      user = User(
        id: userData['id'] ?? userData['_id'] ?? '',
        email: userData['email'] ?? '',
        firstName: userData['firstName'],
        lastName: userData['lastName'],
        role: userData['role'] ?? '',
      );
    }

    return AuthResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      user: user,
    );
  }
}