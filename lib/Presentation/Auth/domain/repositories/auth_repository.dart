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



}