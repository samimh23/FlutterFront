import 'package:flutter/material.dart';
import 'package:hanouty/Core/api/api_exceptions.dart';
import 'package:hanouty/Presentation/Auth/domain/use_cases/verify_reset_code_usecase.dart';

import '../../domain/use_cases/forget_password_usecase.dart';
import '../../domain/use_cases/reset_password_use_case.dart';

enum PasswordResetStatus {
  initial,
  loading,
  emailSent,
  codeVerified,
  passwordReset,
  error,
}

class PasswordResetProvider extends ChangeNotifier {
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final VerifyResetCodeUseCase _verifyResetCodeUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  // Text controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController resetCodeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // State variables
  PasswordResetStatus _status = PasswordResetStatus.initial;
  String? _errorMessage;
  String? _resetToken;
  String? _verifiedToken;

  // Getters
  PasswordResetStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get canVerifyCode => _resetToken != null;
  bool get canResetPassword => _verifiedToken != null;

  PasswordResetProvider({
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required VerifyResetCodeUseCase verifyResetCodeUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
  }) :
        _forgotPasswordUseCase = forgotPasswordUseCase,
        _verifyResetCodeUseCase = verifyResetCodeUseCase,
        _resetPasswordUseCase = resetPasswordUseCase;

  // Clean up controllers when no longer needed
  @override
  void dispose() {
    emailController.dispose();
    resetCodeController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<bool> requestPasswordReset() async {
    final email = emailController.text.trim();

    // Validate input
    if (email.isEmpty) {
      _setError('Email cannot be empty');
      return false;
    }

    _setLoading();

    try {
      final result = await _forgotPasswordUseCase.execute(email: email);

      // Assuming the backend returns a resetToken
      _resetToken = result['resetToken'];
      _status = PasswordResetStatus.emailSent;
      notifyListeners();
      return true;
    } on ApiException catch(e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    }
  }

  Future<bool> verifyCode() async {
    final code = resetCodeController.text.trim();

    // Validate input
    if (code.isEmpty) {
      _setError('Code cannot be empty');
      return false;
    }

    if (_resetToken == null) {
      _setError('Reset token not found, please request a new code');
      return false;
    }

    _setLoading();

    try {
      final result = await _verifyResetCodeUseCase.execute(
        resetToken: _resetToken!,
        code: code,
      );

      // Assuming the backend returns a verifiedToken
      _verifiedToken = result['verifiedToken'];
      _status = PasswordResetStatus.codeVerified;
      notifyListeners();
      return true;
    } on ApiException catch(e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    }
  }

  Future<bool> resetPassword() async {
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Validate inputs
    if (newPassword.isEmpty) {
      _setError('New password cannot be empty');
      return false;
    }

    if (newPassword != confirmPassword) {
      _setError('Passwords do not match');
      return false;
    }

    if (_verifiedToken == null) {
      _setError('Verified token not found, please restart the process');
      return false;
    }

    _setLoading();

    try {
      await _resetPasswordUseCase.execute(
        verifiedToken: _verifiedToken!,
        newPassword: newPassword,
      );

      _status = PasswordResetStatus.passwordReset;
      notifyListeners();
      return true;
    } on ApiException catch(e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    }
  }

  void _setLoading() {
    _status = PasswordResetStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = PasswordResetStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void resetState() {
    _status = PasswordResetStatus.initial;
    _errorMessage = null;
    _resetToken = null;
    _verifiedToken = null;
    emailController.clear();
    resetCodeController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    notifyListeners();
  }
}