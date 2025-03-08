class ApiEndpoints {
  static const String baseUrl = 'http://localhost:3000';



  // Auth endpoints matching your NestJS controller
  static const String loginEndpoint = '/users/login';
  static const String signupEndpint ='/users/signup';

  // Password reset endpoints
  static const String forgetPasswordEndpoint = '/users/forgot-password';
  static const String verifyResetCodeEndpoint = '/users/verify-reset-code';
  static const String resetPasswordEndpoint = '/users/reset-password';


  // Request timeout duration
  static const int timeoutSeconds = 30;
}

