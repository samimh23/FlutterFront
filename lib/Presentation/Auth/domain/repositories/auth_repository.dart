import '../../data/models/create_user_dto.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });

  Future<User> registerUser(CreateUserDto createUserDto);

  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  });

  Future<Map<String, dynamic>> verifyResetCode({
    required String resetToken,
    required String code,
  });

  Future<Map<String, dynamic>> resetPassword({
    required String verifiedToken,
    required String newPassword,
  });

  // Add get profile method
  Future<Map<String, dynamic>> getProfile();
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> updatedData);
  Future<Map<String, dynamic>> deleteProfilePicture();


  Future<Map<String, dynamic>> verifyTwoFactorAuth({
    required String userId,
    required String twoFactorCode,
  });

  // These 2FA methods require authentication (token)
  Future<Map<String, dynamic>> generateTwoFactorSecret();
  Future<Map<String, dynamic>> enableTwoFactor(String verificationCode);
  Future<Map<String, dynamic>> disableTwoFactor();
  }
