import 'package:flutter/material.dart';
import 'package:hanouty/Core/Utils/secure_storage.dart';
import 'package:hanouty/responsive/Homepage.dart';
import 'package:provider/provider.dart';
import 'Core/api/Api_Serice.dart';  // Updated to match your actual file name
import 'Presentation/Auth/data/repositories/auth_repository_impl.dart';
import 'Presentation/Auth/domain/repositories/auth_repository.dart';
import 'Presentation/Auth/domain/use_cases/login_usecase.dart';
import 'Presentation/Auth/domain/use_cases/register_use_case.dart';
import 'Presentation/Auth/presentation/controller/login_controller.dart';
import 'Presentation/Auth/presentation/controller/register_controler.dart';
import 'Presentation/Auth/presentation/pages/login_page.dart';
import 'Presentation/Auth/presentation/pages/signup_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create instances of dependencies
    final ApiClient apiClient = ApiClient();

    // Auth dependencies for login
    final AuthRepository authRepository = AuthRepositoryImpl(apiClient: apiClient);
    final LoginUseCase loginUseCase = LoginUseCase(authRepository);

    // Register dependencies for user creation

    final RegisterUseCase registerUseCase = RegisterUseCase(authRepository);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            loginUseCase: loginUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => RegisterProvider(
            registerUseCase: registerUseCase,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Hanouty',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
              TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        initialRoute: '/register',
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const Homepage(),
        },
      ),
    );
  }
}