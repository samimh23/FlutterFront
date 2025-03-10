import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hanouty/Core/api/api_exceptions.dart';
import 'package:hanouty/Presentation/Auth/data/models/auth_response.dart';
import 'package:hanouty/Presentation/Auth/domain/use_cases/login_usecase.dart';
import 'package:hanouty/Presentation/Auth/presentation/controller/role_based_roter.dart';
import '../../../../Core/Utils/secure_storage.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  requiresTwoFactor, // New status for 2FA
  twoFactorVerifying, // Status when verifying 2FA code
  error,
}

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final SecureStorageService _secureStorageService;

  // Text controllers for form fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController twoFactorCodeController = TextEditingController(); // New controller for 2FA code

  // Remember checkbox state
  bool rememberMe = false;

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  AuthResponse? _authResponse;  // Store the auth response to access the user data
  String? _userId; // Store user ID for 2FA verification

  // Getters
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  AuthResponse? get authResponse => _authResponse;
  String? get userId => _userId;

  AuthProvider({
    required LoginUseCase loginUseCase,
    SecureStorageService? secureStorageService,
  }) :
        _loginUseCase = loginUseCase,
        _secureStorageService = secureStorageService ?? SecureStorageService() {
    _checkSavedCredentials();
  }

  // Clean up controllers when no longer needed
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    twoFactorCodeController.dispose(); // Clean up the new controller
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

      // Check if 2FA is required
      if (result.containsKey('requireTwoFactor') && result['requireTwoFactor'] == true) {
        _userId = result['userId']; // Save user ID for 2FA verification
        _status = AuthStatus.requiresTwoFactor;
        notifyListeners();
        return true; // Return true to indicate successful first step
      }

      // Normal authentication flow
      _authResponse = AuthResponse.fromJson(result);
      print('User Role: ${_authResponse?.user?.role}');

      await _secureStorageService.saveAccessToken(_authResponse!.accessToken);
      await _secureStorageService.saveRefreshToken(_authResponse!.refreshToken);

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

  // New method for 2FA verification
  Future<bool> verifyTwoFactorCode() async {
    if (_userId == null) {
      _status = AuthStatus.error;
      _errorMessage = 'Authentication session expired';
      notifyListeners();
      return false;
    }

    final twoFactorCode = twoFactorCodeController.text.trim();
    if (twoFactorCode.isEmpty) {
      _status = AuthStatus.error;
      _errorMessage = 'Please enter the verification code';
      notifyListeners();
      return false;
    }

    _status = AuthStatus.twoFactorVerifying;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call your 2FA verification API
      final result = await _loginUseCase.verifyTwoFactorAuth(
        userId: _userId!,
        twoFactorCode: twoFactorCode,
      );

      _authResponse = AuthResponse.fromJson(result);

      await _secureStorageService.saveAccessToken(_authResponse!.accessToken);
      await _secureStorageService.saveRefreshToken(_authResponse!.refreshToken);

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch(e) {
      _status = AuthStatus.requiresTwoFactor; // Keep in 2FA state
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.requiresTwoFactor; // Keep in 2FA state
      _errorMessage = 'Failed to verify code';
      notifyListeners();
      return false;
    }
  }

  // Methods for 2FA setup
  Future<Map<String, dynamic>> generateTwoFactorSecret() async {
    try {
      // Call your API to generate 2FA secret
      final result = await _loginUseCase.generateTwoFactorSecret();
      return result;
    } on ApiException catch(e) {
      _errorMessage = e.message;
      notifyListeners();
      throw e;
    } catch (e) {
      _errorMessage = 'Failed to generate 2FA secret';
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }

  Future<bool> enableTwoFactor(String verificationCode) async {
    try {
      // Call your API to enable 2FA
      await _loginUseCase.enableTwoFactor(verificationCode);
      return true;
    } on ApiException catch(e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to enable 2FA';
      notifyListeners();
      return false;
    }
  }

  Future<bool> disableTwoFactor() async {
    try {
      // Call your API to disable 2FA
      await _loginUseCase.disableTwoFactor();
      return true;
    } on ApiException catch(e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to disable 2FA';
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
    _authResponse = null;  // Clear the auth response
    _userId = null;  // Clear the user ID
    notifyListeners();
  }

  // Method to navigate based on user role
  void navigateBasedOnRole(BuildContext context) {
    if (_authResponse != null && _authResponse!.user != null) {
      print(authResponse!.user!.role);
      RoleBasedRouter.navigateBasedOnRole(context, _authResponse!.user!.role);
    }
  }
}