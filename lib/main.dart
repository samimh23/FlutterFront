import 'package:flutter/material.dart';
import 'package:hanouty/Core/Utils/secure_storage.dart';
import 'package:hanouty/Presentation/Auth/domain/use_cases/verify_reset_code_usecase.dart';
import 'package:hanouty/Presentation/Auth/presentation/controller/password_reset_controller.dart';
import 'package:hanouty/responsive/Homepage.dart';
import 'package:provider/provider.dart';
import 'Core/api/Api_Serice.dart';
import 'Presentation/Auth/data/repositories/auth_repository_impl.dart';
import 'Presentation/Auth/domain/repositories/auth_repository.dart';
import 'Presentation/Auth/domain/use_cases/forget_password_usecase.dart';
import 'Presentation/Auth/domain/use_cases/login_usecase.dart';
import 'Presentation/Auth/domain/use_cases/register_use_case.dart';
import 'Presentation/Auth/domain/use_cases/reset_password_use_case.dart';
import 'Presentation/Auth/presentation/controller/login_controller.dart';
import 'Presentation/Auth/presentation/controller/register_controler.dart';
import 'Presentation/Auth/presentation/pages/login_page.dart';
import 'Presentation/Auth/presentation/pages/signup_page.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Check for saved credentials
  final secureStorageService = SecureStorageService();
  final rememberMe = await secureStorageService.getRememberMe();
  final accessToken = await secureStorageService.getAccessToken();

  print('Remember Me: $rememberMe');
  print('Access Token: $accessToken');

  // Determine initial route based on saved credentials
  final String initialRoute = (rememberMe == 'true' && accessToken != null)
      ? '/home'
      : '/login';

  runApp(MyApp(
    initialRoute: initialRoute,
    secureStorageService: secureStorageService,
  ));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final SecureStorageService secureStorageService;

  const MyApp({
    Key? key,
    required this.initialRoute,
    required this.secureStorageService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create instances of dependencies
    final ApiClient apiClient = ApiClient();
    final AuthRepository authRepository = AuthRepositoryImpl(apiClient: apiClient);
    final LoginUseCase loginUseCase = LoginUseCase(authRepository);
    final RegisterUseCase registerUseCase = RegisterUseCase(authRepository);
    final ForgotPasswordUseCase forgotPasswordUseCase = ForgotPasswordUseCase(authRepository);
    final VerifyResetCodeUseCase verifyResetCodeUseCase = VerifyResetCodeUseCase(authRepository);
    final ResetPasswordUseCase resetPasswordUseCase = ResetPasswordUseCase(authRepository);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            loginUseCase: loginUseCase,
            secureStorageService: secureStorageService,
          ),
        ),
        ChangeNotifierProvider(

          create: (context) => RegisterProvider(

            registerUseCase: registerUseCase,

          ),

        ),
        ChangeNotifierProvider(
          create: (context) => PasswordResetProvider(
            forgotPasswordUseCase: forgotPasswordUseCase,
            verifyResetCodeUseCase: verifyResetCodeUseCase,
            resetPasswordUseCase: resetPasswordUseCase,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Hanouty',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: initialRoute,
        routes: { 
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const Homepage(),
        },
      ),
    );
  }
}