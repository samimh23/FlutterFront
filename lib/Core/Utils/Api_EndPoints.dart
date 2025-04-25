class ApiEndpoints {
  static const String baseUrl = 'http://192.168.0.122:3000';



  // Auth endpoints matching your NestJS controller
  static const String loginEndpoint = '/users/login';
  static const String signupEndpint ='/users/signup';

  // Password reset endpoints
  static const String forgetPasswordEndpoint = '/users/forgot-password';
  static const String verifyResetCodeEndpoint = '/users/verify-reset-code';
  static const String resetPasswordEndpoint = '/users/reset-password';
  static const String getprofile = '/users/profile';
  // Profile-related endpoints
  static const String getProfileEndpoint = '/users/profile';
  static const String updateProfileEndpoint = '/users/profile';
  static const String removeProfilePictureEndpoint = '/users/profile/picture';

  // Google OAuth endpoints
  static const String googleAuthEndpoint = '/users/google-redirect';

  // 2FA endpoints
  static const String generateTwoFactorSecretEndpoint = '/2fa/generate';
  static const String enableTwoFactorEndpoint = '/2fa/enable';
  static const String disableTwoFactorEndpoint = '/2fa/disable';
  static const String verifyTwoFactorEndpoint = '/2fa/verify';

  // Request timeout duration
  static const int timeoutSeconds = 60;
}

