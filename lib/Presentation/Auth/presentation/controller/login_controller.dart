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

  // emember checkbox  state
  bool rememberMe=false ;

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
        _secureStorageService = secureStorageService ?? SecureStorageService(){
    _checkSavedCredentials();

  }


  // Clean up controllers when no longer needed
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  void setRememberMe(bool value) {
    rememberMe = value;
    notifyListeners();
  }

  Future<void> _checkSavedCredentials() async {
    final savedEmail = await _secureStorageService.getEmail();
    final savedPassword = await _secureStorageService.getPassword();
    final isRemembered = await _secureStorageService.getRememberMe();

    if (isRemembered == 'true' && savedEmail != null && savedPassword != null) {
      emailController.text = savedEmail;
      passwordController.text = savedPassword;
      rememberMe = true;

      // Optionally auto-login the user
      // Uncomment the next line if you want to automatically log in the user
      // await login();

      notifyListeners();
    }
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

      if (rememberMe) {
        await _secureStorageService.saveEmail(email);
        await _secureStorageService.savePassword(password);
        await _secureStorageService.saveRememberMe('true');
        final savedEmail = await _secureStorageService.getEmail();
        final savedRememberMe = await _secureStorageService.getRememberMe();
        print('Verification - Email: $savedEmail, Remember Me: $savedRememberMe');
      } else {
        await _secureStorageService.clearSavedCredentials();
      }


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
  Future<void> logout() async {
    // Clear auth tokens
    await _secureStorageService.clearTokens();

    // If rememberMe is not checked, also clear the saved credentials
    if (!rememberMe) {
      await _secureStorageService.clearSavedCredentials();
    }

    _status = AuthStatus.initial;
    notifyListeners();
  }
}