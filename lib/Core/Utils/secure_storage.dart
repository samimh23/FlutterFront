import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  factory SecureStorageService() {
    return _instance;
  }

  SecureStorageService._internal();

  // Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String emailKey = 'user_email';
  static const String passwordKey = 'user_password';
  static const String rememberMeKey = 'remember_me';
  static const String userIdKey = 'user_id'; // Added for user ID


  // Authentication token methods
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: accessTokenKey, value: token);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: refreshTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: refreshTokenKey);
  }
  // User ID methods
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: userIdKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: accessTokenKey);
    await _storage.delete(key: refreshTokenKey);
    await _storage.delete(key: userIdKey); // Clear user ID as well

  }

  // Remember Me functionality method^)s
  Future<void> saveEmail(String email) async {
    await _storage.write(key: emailKey, value: email);
  }

  Future<void> savePassword(String password) async {
    await _storage.write(key: passwordKey, value: password);
  }

  Future<void> saveRememberMe(String value) async {
    await _storage.write(key: rememberMeKey, value: value);
  }

  Future<String?> getEmail() async {
    return await _storage.read(key: emailKey);
  }

  Future<String?> getPassword() async {
    return await _storage.read(key: passwordKey);
  }

  Future<String?> getRememberMe() async {
    return await _storage.read(key: rememberMeKey);
  }

  Future<void> clearSavedCredentials() async {
    await _storage.delete(key: emailKey);
    await _storage.delete(key: passwordKey);
    await _storage.delete(key: rememberMeKey);
  }

  // Clear everything (used for logout)
  Future<void> clearAll() async {
    await clearTokens();
    await clearSavedCredentials();
  }
}