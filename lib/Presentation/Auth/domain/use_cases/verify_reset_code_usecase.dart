import '../repositories/auth_repository.dart';

class VerifyResetCodeUseCase {
  final AuthRepository _authRepository;

  VerifyResetCodeUseCase(this._authRepository);

  Future<Map<String, dynamic>> execute({
    required String resetToken,
    required String code,
  }) async {
    return await _authRepository.verifyResetCode(
      resetToken: resetToken,
      code: code,
    );
  }
}