import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hanouty/Core/api/api_exceptions.dart';
import 'package:hanouty/Presentation/Auth/data/models/auth_response.dart';
import 'package:hanouty/Presentation/Auth/domain/use_cases/login_usecase.dart';
import 'package:hanouty/Presentation/Auth/presentation/controller/role_based_roter.dart';
import '../../../../Core/Utils/secure_storage.dart';
import 'GoogleAuthService.dart';

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
  late final GoogleAuthService _googleAuthService;

  // Text controllers for form fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController twoFactorCodeController =
      TextEditingController(); // New controller for 2FA code

  // Remember checkbox state
  bool rememberMe = false;

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  AuthResponse?
      _authResponse; // Store the auth response to access the user data
  String? _userId; // Store user ID for 2FA verification

  // Getters
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  AuthResponse? get authResponse => _authResponse;
  String? get userId => _userId;

  AuthProvider({
    required LoginUseCase loginUseCase,
    SecureStorageService? secureStorageService,
  })  : _loginUseCase = loginUseCase,
        _secureStorageService = secureStorageService ?? SecureStorageService() {
    _checkSavedCredentials();
    _googleAuthService = GoogleAuthService();
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
        final result = await _loginUseCase.execute(email: email, password: password);

        // Check if 2FA is required
        if (result.containsKey('requireTwoFactor') && result['requireTwoFactor'] == true) {
            _userId = result['userId'];
            // Save user ID for 2FA verification
            await _secureStorageService.saveUserId(_userId!); // Save the user ID
            _status = AuthStatus.requiresTwoFactor;
            notifyListeners();
            return true;
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

        // Save user ID after successful login
        await _secureStorageService.saveUserId(_authResponse!.user!.id ?? '');

        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
    } on ApiException catch (e) {
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
// New method for 2FA verification with improved logging
  Future<bool> verifyTwoFactorCode() async {
    if (_userId == null) {
      print('❌ ERROR: userId is null during 2FA verification');
      _status = AuthStatus.error;
      _errorMessage = 'Authentication session expired';
      notifyListeners();
      return false;
    }

    // Clean up the 2FA code - remove spaces and ensure digits only
    final enteredCode = twoFactorCodeController.text.trim();
    final twoFactorCode = enteredCode.replaceAll(RegExp(r'\s+'), '');

    // Validate the code
    final digitRegex = RegExp(r'^\d+$');
    if (twoFactorCode.isEmpty) {
      print('❌ ERROR: 2FA code is empty');
      _status = AuthStatus.error;
      _errorMessage = 'Please enter the verification code';
      notifyListeners();
      return false;
    }

    if (!digitRegex.hasMatch(twoFactorCode)) {
      print('❌ ERROR: 2FA code should only contain digits');
      _status = AuthStatus.error;
      _errorMessage = 'Verification code should only contain digits';
      notifyListeners();
      return false;
    }

    if (twoFactorCode.length != 6) {
      print('❌ ERROR: 2FA code should be 6 digits');
      _status = AuthStatus.error;
      _errorMessage = 'Verification code should be 6 digits';
      notifyListeners();
      return false;
    }

    print('🔄 Verifying 2FA code: $twoFactorCode for user: $_userId');
    _status = AuthStatus.twoFactorVerifying;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call your 2FA verification API
      print('📡 Sending 2FA verification request...');
      final result = await _loginUseCase.verifyTwoFactorAuth(
        userId: _userId!,
        twoFactorCode: twoFactorCode,
      );

      print('✅ 2FA verification response: $result');

      _authResponse = AuthResponse.fromJson(result);
      print(
          '✅ Access token received: ${_authResponse!.accessToken.substring(0, min(10, _authResponse!.accessToken.length))}...');

      await _secureStorageService.saveAccessToken(_authResponse!.accessToken);
      await _secureStorageService.saveRefreshToken(_authResponse!.refreshToken);

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      print('❌ ApiException during 2FA verification: ${e.message}');
      _status = AuthStatus.requiresTwoFactor; // Keep in 2FA state
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ Unexpected error during 2FA verification: $e');
      _status = AuthStatus.requiresTwoFactor; // Keep in 2FA state
      _errorMessage = 'Failed to verify code';
      notifyListeners();
      return false;
    }
  }

  void signInWithGoogle(BuildContext context) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      await _googleAuthService.signInWithGoogle(context);

      // The actual authentication will happen after redirect
      // Reset status after launching the external auth flow
      _status = AuthStatus.initial;
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Failed to launch Google Sign-In';
      notifyListeners();
    }
  }

// Methods for 2FA setup
  Future<Map<String, dynamic>> generateTwoFactorSecret() async {
    try {
      print('🔄 Generating 2FA secret...');
      final result = await _loginUseCase.generateTwoFactorSecret();
      print('✅ 2FA secret generated successfully: $result');
      return result;
    } on ApiException catch (e) {
      print('❌ ApiException generating 2FA secret: ${e.message}');
      _errorMessage = e.message;
      notifyListeners();
      throw e;
    } catch (e) {
      print('❌ Error generating 2FA secret: $e');
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
    } on ApiException catch (e) {
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
    } on ApiException catch (e) {
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
    _authResponse = null; // Clear the auth response
    _userId = null; // Clear the user ID
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
