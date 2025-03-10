

import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  Future<Map<String, dynamic>> execute({
    required String email,
    required String password,
  }) async {
    return await _authRepository.login(
      email: email,
      password: password,
    );

  }

  Future<Map<String, dynamic>> verifyTwoFactorAuth({
    required String userId,
    required String twoFactorCode,
  }) async {
    try {
      final response = await _authRepository.verifyTwoFactorAuth(
        userId: userId,
        twoFactorCode: twoFactorCode,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

// Method to generate 2FA secret
  Future<Map<String, dynamic>> generateTwoFactorSecret() async {
    try {
      final response = await _authRepository.generateTwoFactorSecret();
      return response;
    } catch (e) {
      rethrow;
    }
  }

// Method to enable 2FA
  Future<void> enableTwoFactor(String verificationCode) async {
    try {
      await _authRepository.enableTwoFactor(verificationCode);
    } catch (e) {
      rethrow;
    }
  }

// Method to disable 2FA
  Future<void> disableTwoFactor() async {
    try {
      await _authRepository.disableTwoFactor();
    } catch (e) {
      rethrow;
    }
  }
}