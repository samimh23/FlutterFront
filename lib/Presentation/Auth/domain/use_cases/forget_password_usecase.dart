import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository _authRepository;

  ForgotPasswordUseCase(this._authRepository);

  Future<Map<String, dynamic>> execute({
    required String email,
  }) async {
    return await _authRepository.forgotPassword(
      email: email,
    );
  }
}
