

import '../../../../Core/Utils/secure_storage.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _authRepository;
  final SecureStorageService _secureStorageService;
  LoginUseCase({
    required AuthRepository authRepository,
    SecureStorageService? secureStorageService,
  }) :
        _authRepository = authRepository,
        _secureStorageService = secureStorageService ?? SecureStorageService();

  Future<Map<String, dynamic>> execute({
    required String email,
    required String password,
  }) async {
    return await _authRepository.login(
      email: email,
      password: password,
    );
  }

  // Two-factor authentication methods
  Future<Map<String, dynamic>> verifyTwoFactorAuth({
    required String userId,
    required String twoFactorCode,
  }) async {
    return await _authRepository.verifyTwoFactorAuth(
      userId: userId,
      twoFactorCode: twoFactorCode,
    );
  }

  Future<Map<String, dynamic>> generateTwoFactorSecret() async {
    return await _authRepository.generateTwoFactorSecret();
  }

  Future<Map<String, dynamic>> enableTwoFactor(String verificationCode) async {
    return await _authRepository.enableTwoFactor(verificationCode);
  }

  Future<Map<String, dynamic>> disableTwoFactor() async {
    return await _authRepository.disableTwoFactor();
  }


}