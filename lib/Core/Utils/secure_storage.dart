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
  static const String _hederaAccountIdKey = 'hedera_account_id';
  static const String _hederaPrivateKeyKey = 'hedera_private_key';


  // Authentication token methods
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: accessTokenKey, value: token);
  }

  Future<void> saveUserRole(String role) async {
    await _storage.write(key: 'user_role', value: role);
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: 'user_role');
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

  Future<void> saveHederaAccountId(String accountId) async {
    await _storage.write(key: _hederaAccountIdKey, value: accountId);
    print("✅ Saved Hedera Account ID to secure storage."); // For debugging
  }

  Future<String?> getHederaAccountId() async {
    return await _storage.read(key: _hederaAccountIdKey);
  }

  Future<void> saveHederaPrivateKey(String privateKey) async {
    // Ensure you understand the security risks of storing private keys on the client
    await _storage.write(key: _hederaPrivateKeyKey, value: privateKey);
    print("🔒 Saved Hedera Private Key to secure storage. (Handle with extreme care!)"); // For debugging
  }

  Future<String?> getHederaPrivateKey() async {
    print("🔑 Retrieving Hedera Private Key from secure storage."); // For debugging
    return await _storage.read(key: _hederaPrivateKeyKey);
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
  Future<void> clearHederaCredentials() async {
    await _storage.delete(key: _hederaAccountIdKey);
    await _storage.delete(key: _hederaPrivateKeyKey);
    print("🗑️ Cleared Hedera credentials from secure storage."); // For debugging
  }

  // Clear everything (used for logout)
  Future<void> clearAll() async {
    await clearTokens();
    await clearSavedCredentials();
    await clearHederaCredentials();
  }
}