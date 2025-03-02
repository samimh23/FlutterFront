import 'package:flutter/material.dart';
import 'package:hanouty/Core/api/api_exceptions.dart';
import 'package:hanouty/Presentation/Auth/data/models/auth_response.dart';
import 'package:hanouty/Presentation/Auth/domain/use_cases/login_usecase.dart';

import '../../../../Core/Utils/secure_storage.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final SecureStorageService _secureStorageService;

  // Text controllers for form fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;

  AuthProvider({
    required LoginUseCase loginUseCase,
    SecureStorageService? secureStorageService,
  }) :
        _loginUseCase = loginUseCase,
        _secureStorageService = secureStorageService ?? SecureStorageService();

  // Clean up controllers when no longer needed
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<bool> login() async {
    // Get values from text controllers
    final email = emailController.text.trim();
    final password = passwordController.text;

    // Validate input
    if (email.isEmpty || password.isEmpty) {
      _status = AuthStatus.error;
      _errorMessage = 'Email and password cannot be empty';
      notifyListeners();
      return false;
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _loginUseCase.execute(
          email: email,
          password: password
      );
      final authresponse = AuthResponse.fromJson(result);

      await _secureStorageService.saveAccessToken(authresponse.accessToken);
      await _secureStorageService.saveRefreshToken(authresponse.refreshToken);

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch(e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'An unexpected error occurred';
      notifyListeners();
      return false;
    }
  }
}