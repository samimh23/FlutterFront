import 'package:flutter/material.dart';
import 'package:hanouty/Core/Utils/secure_storage.dart';
import 'package:hanouty/responsive/Homepage.dart';
import 'package:provider/provider.dart';
import 'Core/api/Api_Serice.dart';  // Updated to match your actual file name
import 'Presentation/Auth/data/repositories/auth_repository_impl.dart';
import 'Presentation/Auth/domain/repositories/auth_repository.dart';
import 'Presentation/Auth/domain/use_cases/login_usecase.dart';  // Updated case
import 'Presentation/Auth/presentation/controller/login_controller.dart';
import 'Presentation/Auth/presentation/pages/login_page.dart';
// Assuming similar case pattern

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create instances of dependencies
    final ApiClient apiClient = ApiClient();
    final AuthRepository authRepository = AuthRepositoryImpl(apiClient: apiClient);
    final LoginUseCase loginUseCase = LoginUseCase( authRepository);
    


    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            loginUseCase: loginUseCase,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Hanouty',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const LoginPage(),
        routes: {
          '/home': (context) => const Homepage(),
        },
      ),
    );
  }
}