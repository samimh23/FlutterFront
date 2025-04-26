import 'dart:convert';
// Ensure RoleExtension is here if User.fromJson uses it (which it should)
import '../../../../Core/Enums/role_enum.dart';
import '../../domain/entities/user.dart'; // Ensure User class is defined correctly

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User? user; // Your User entity

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Get tokens from the top level
    final String accessToken = json['accessToken'] ?? json['access_token'] ?? '';
    final String refreshToken = json['refreshToken'] ?? '';

    User? parsedUser;

    // --- PARSE USER OBJECT FROM RESPONSE BODY ---
    // Check if the 'user' key exists and is a map
    if (json.containsKey('user') && json['user'] is Map<String, dynamic>) {
      try {
        // Call the User.fromJson factory constructor
        // Pass the user map directly to it
        parsedUser = User.fromJson(json['user'] as Map<String, dynamic>);
        print('✅ Successfully parsed User object from response body.');
        // Optional: Print some details for verification
        print('   - User ID: ${parsedUser.id}');
        print('   - User Role: ${parsedUser.role}'); // Or parsedUser.role.value
        print('   - Hedera Account ID: ${parsedUser.headerAccountId ?? 'Not Found in User Object'}');

      } catch (e) {
        print('❌ Error parsing User object from response body: $e');
        print('   - Raw user data received: ${json['user']}');
        parsedUser = null;
      }
    } else {
      print('⚠️ "user" object not found or not a map in the AuthResponse JSON.');
      // parsedUser remains null
    }

    // --- JWT DECODING LOGIC IS REMOVED ---

    return AuthResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: parsedUser, // Assign the user parsed from the body (or null)
    );
  }
}