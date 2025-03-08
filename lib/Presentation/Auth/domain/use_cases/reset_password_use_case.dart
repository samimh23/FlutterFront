import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository _authRepository;

  ResetPasswordUseCase(this._authRepository);

  Future<Map<String, dynamic>> execute({
    required String verifiedToken,
    required String newPassword,
  }) async {
    return await _authRepository.resetPassword(
      verifiedToken: verifiedToken,
      newPassword: newPassword,
    );
  }
}