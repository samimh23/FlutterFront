class ApiEndpoints {
  static const String baseUrl = 'http://localhost:3000';



  // Auth endpoints matching your NestJS controller
  static const String loginEndpoint = '/users/login';
  static const String signupEndpint ='/users/signup';


  // Request timeout duration
  static const int timeoutSeconds = 30;
}

