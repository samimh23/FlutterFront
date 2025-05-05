import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hanouty/Core/Utils/secure_storage.dart';
import 'package:hanouty/Presentation/Auth/domain/use_cases/verify_reset_code_usecase.dart';
import 'package:hanouty/Presentation/Auth/presentation/controller/password_reset_controller.dart';
import 'package:hanouty/Presentation/Auth/presentation/pages/SetupTwoFactorAuthScreen.dart';
import 'package:hanouty/Presentation/Farm/Data_Layer/datasources/farm_remote_data_source.dart';
import 'package:hanouty/Presentation/Farm/Data_Layer/repositories/farm_repository_impl.dart';
import 'package:hanouty/Presentation/Farm/Domain_Layer/usescases/addfarm.dart';
import 'package:hanouty/Presentation/Farm/Domain_Layer/usescases/delete_farm_market.dart';
import 'package:hanouty/Presentation/Farm/Domain_Layer/usescases/get_all_farm_markets.dart';
import 'package:hanouty/Presentation/Farm/Domain_Layer/usescases/get_farm_market_by_id.dart';
import 'package:hanouty/Presentation/Farm/Domain_Layer/usescases/update_farm_market.dart';
import 'package:hanouty/Presentation/Farm/Presentation_Layer/viewmodels/farmviewmodel.dart';
import 'package:hanouty/Presentation/normalmarket/Data/datasources/market_remote_datasources.dart';
import 'package:hanouty/Presentation/normalmarket/Data/repositories/normalmarket_data_repository.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/repositories/normamarket_domain_repository.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/usecases/create_fractional_nft.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/usecases/get_my_market.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/usecases/give_shares.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/usecases/market_add.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/usecases/market_delete.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/usecases/market_getall.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/usecases/market_getbyid.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/usecases/market_update.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Pages/dashboard_page.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Provider/normal_market_provider.dart';
import 'package:hanouty/Presentation/order/presentation/provider/delivery_tracking_service.dart';
import 'package:hanouty/Presentation/order/presentation/provider/order_provider.dart';
import 'package:hanouty/Presentation/product/presentation/pages/cart_screen.dart';
import 'package:hanouty/Presentation/product/presentation/pages/home_screen.dart';
import 'package:hanouty/Presentation/product/presentation/provider/cart_provider.dart';
import 'package:hanouty/Presentation/product/presentation/provider/product_provider.dart';
import 'package:hanouty/Presentation/review/presentation/provider/review_provider.dart';
import 'package:hanouty/nav_bar.dart';
import 'package:provider/provider.dart';
import 'Core/api/Api_Serice.dart';
import 'Presentation/AIForBussines/DashboardViewModel.dart';
import 'Presentation/AIForBussines/apiservice.dart';
import 'Presentation/Auth/data/repositories/auth_repository_impl.dart';
import 'Presentation/Auth/domain/repositories/auth_repository.dart';
import 'Presentation/Auth/domain/use_cases/forget_password_usecase.dart';
import 'Presentation/Auth/domain/use_cases/login_usecase.dart';
import 'Presentation/Auth/domain/use_cases/register_use_case.dart';
import 'Presentation/Auth/domain/use_cases/reset_password_use_case.dart';
import 'Presentation/Auth/presentation/controller/login_controller.dart';
import 'Presentation/Auth/presentation/controller/profilep^rovider.dart';
import 'Presentation/Auth/presentation/controller/register_controler.dart';
import 'Presentation/Auth/presentation/pages/farmerscreen.dart';
import 'Presentation/Auth/presentation/pages/login_page.dart';
import 'Presentation/Auth/presentation/pages/signup_page.dart';
import 'Presentation/Auth/presentation/pages/wholesalerscrren.dart';
import 'Presentation/DiseaseDetection/Presentation_Layer/viewmodels/productVM.dart' show DiseaseDetectionViewModel;
import 'Presentation/Farm/Domain_Layer/usescases/GetSalesByFarmMarketId.dart' show GetSalesByFarmMarketId;
import 'Presentation/Farm/Domain_Layer/usescases/get_farm_by_owner.dart';
import 'Presentation/Farm/Domain_Layer/usescases/get_farm_products.dart';
import 'Presentation/Farm/Presentation_Layer/pages/mobile/FarmMobileNavigation.dart';
import 'Presentation/Farm_Crop/Data_Layer/datasources/farm_crop_remote_data_source.dart';
import 'Presentation/Farm_Crop/Data_Layer/repositories/farm_crop_repository_impl.dart';
import 'Presentation/Farm_Crop/Domain_Layer/usecases/TransformCropProd/ConfirmAndConvertFarmCrop.dart';
import 'Presentation/Farm_Crop/Domain_Layer/usecases/TransformCropProd/ConvertFarmCropToProduct.dart';
import 'Presentation/Farm_Crop/Domain_Layer/usecases/TransformCropProd/ProcessAllConfirmedFarmCrops.dart';
import 'Presentation/Farm_Crop/Domain_Layer/usecases/add_farm_crop.dart';
import 'Presentation/Farm_Crop/Domain_Layer/usecases/calculate_total_expenses.dart';
import 'Presentation/Farm_Crop/Domain_Layer/usecases/delete_farm_crop.dart';
import 'Presentation/Farm_Crop/Domain_Layer/usecases/get_all_farm_crops.dart';
import 'Presentation/Farm_Crop/Domain_Layer/usecases/get_farm_crop_by_farm.dart';
import 'Presentation/Farm_Crop/Domain_Layer/usecases/get_farm_crop_by_id.dart';
import 'Presentation/Farm_Crop/Domain_Layer/usecases/update_farm_crop.dart';
import 'Presentation/Farm_Crop/Presentation_Layer/viewmodels/farm_crop_viewmodel.dart';
import 'Presentation/Sales/Data_Layer/datasources/Sale_Remote_DataSource.dart';
import 'Presentation/Sales/Data_Layer/repositories/sale_repository_impl.dart';
import 'Presentation/Sales/Domain_Layer/usecases/add_sale.dart';
import 'Presentation/Sales/Domain_Layer/usecases/delete_sale.dart';
import 'Presentation/Sales/Domain_Layer/usecases/getSalesByFarmMarket.dart' show GetSalesByFarmMarket;
import 'Presentation/Sales/Domain_Layer/usecases/get_all_sales.dart';
import 'Presentation/Sales/Domain_Layer/usecases/get_sale_by_id.dart';
import 'Presentation/Sales/Domain_Layer/usecases/get_sales_by_crop_id.dart';
import 'Presentation/Sales/Domain_Layer/usecases/update_sale.dart';
import 'Presentation/Sales/Presentation_Layer/viewmodels/sale_viewmodel.dart';
import 'injection_container.dart' as di;

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  final deliveryService = DeliveryTrackingService();
  await di.init();

  // Check for saved credentials
  final secureStorageService = SecureStorageService();
  final rememberMe = await secureStorageService.getRememberMe();
  final accessToken = await secureStorageService.getAccessToken();

  print('Remember Me: $rememberMe');
  print('Access Token: $accessToken');

  // Determine initial route based on saved credentials
  final String initialRoute =
      (rememberMe == 'true' && accessToken != null) ? '/home' : '/login';

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
    final AuthRepository authRepository =
        AuthRepositoryImpl(apiClient: apiClient);
    final LoginUseCase loginUseCase = LoginUseCase(
        authRepository: authRepository,
        secureStorageService: secureStorageService);
    final RegisterUseCase registerUseCase = RegisterUseCase(authRepository);
    final ForgotPasswordUseCase forgotPasswordUseCase =
        ForgotPasswordUseCase(authRepository);
    final VerifyResetCodeUseCase verifyResetCodeUseCase =
        VerifyResetCodeUseCase(authRepository);
    final ResetPasswordUseCase resetPasswordUseCase =
        ResetPasswordUseCase(authRepository);
    final ApiService apiService = ApiService(
      baseUrl: 'https://flask-analytics-api.onrender.com',  // Replace with your Flask server IP
    );
    return MultiProvider(
      providers: [
        //alaaa
        Provider<Dio>(
          create: (_) => Dio(BaseOptions(
            // For web deployment, using relative URL to match the hosting domain
            baseUrl: 'http://localhost:3000/normal',
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 10),
            contentType: 'application/json',
          )),
        ),

        // Data sources
        Provider<NormalMarketRemoteDataSource>(
          create: (context) => NormalMarketRemoteDataSourceImpl(
              dio: context.read<Dio>(), secureStorageService),
        ),

        // Repositories
        Provider<NormalMarketRepository>(
          create: (context) => NormalMarketRepositoryImpl(
            remoteDataSource: context.read<NormalMarketRemoteDataSource>(),
          ),
        ),

        // Use cases for normal markets
        Provider<GetNormalMarkets>(
          create: (context) =>
              GetNormalMarkets(context.read<NormalMarketRepository>()),
        ),
        Provider<GetMyNormalMarkets>(
          create: (context) =>
              GetMyNormalMarkets(context.read<NormalMarketRepository>()),
        ),
        Provider<GetNormalMarketById>(
          create: (context) =>
              GetNormalMarketById(context.read<NormalMarketRepository>()),
        ),
        Provider<CreateNormalMarket>(
          create: (context) =>
              CreateNormalMarket(context.read<NormalMarketRepository>()),
        ),
        Provider<UpdateNormalMarket>(
          create: (context) =>
              UpdateNormalMarket(context.read<NormalMarketRepository>()),
        ),
        Provider<DeleteNormalMarket>(
          create: (context) =>
              DeleteNormalMarket(context.read<NormalMarketRepository>()),
        ),
        Provider<ShareFractionalNFT>(
          create: (context) =>
              ShareFractionalNFT(context.read<NormalMarketRepository>()),
        ),
        Provider<CreateFractionalNFT>(
          create: (context) =>
              CreateFractionalNFT(context.read<NormalMarketRepository>()),
        ),

        // Application state provider - initialized immediately with lazy: false
        ChangeNotifierProvider<NormalMarketProvider>(
          create: (context) => NormalMarketProvider(
            getNormalMarkets: context.read<GetNormalMarkets>(),
            getNormalMarketById: context.read<GetNormalMarketById>(),
            getMyNormalMarkets: context.read<GetMyNormalMarkets>(),
            createNormalMarket: context.read<CreateNormalMarket>(),
            updateNormalMarket: context.read<UpdateNormalMarket>(),
            deleteNormalMarket: context.read<DeleteNormalMarket>(),
            shareFractionalNFT: context.read<ShareFractionalNFT>(),
            createFractionalNFT: context.read<CreateFractionalNFT>(),
            secureStorageService: secureStorageService,
          ),
          lazy: false,
        ),

        //alaaaa

        //ouseema

        ChangeNotifierProvider(
          create: (_) => di.sl<ProductProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<CartProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<OrderProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<ReviewProvider>(),
        ),

        // oussema

        //ahmed

        Provider<FarmMarketRemoteDataSource>(
          create: (_) => FarmMarketRemoteDataSource(authService: SecureStorageService(),),
        ),
        Provider<FarmMarketRepositoryImpl>(
          create: (context) => FarmMarketRepositoryImpl(
            remoteDataSource: context.read<FarmMarketRemoteDataSource>(),
          ),
        ),
        Provider<GetAllFarmMarkets>(
          create: (context) =>
              GetAllFarmMarkets(context.read<FarmMarketRepositoryImpl>()),
        ),
        Provider<GetFarmMarketById>(
          create: (context) =>
              GetFarmMarketById(context.read<FarmMarketRepositoryImpl>()),
        ),
        Provider<AddFarmMarket>(
          create: (context) =>
              AddFarmMarket(context.read<FarmMarketRepositoryImpl>()),
        ),
        Provider<UpdateFarmMarket>(
          create: (context) =>
              UpdateFarmMarket(context.read<FarmMarketRepositoryImpl>()),
        ),
        Provider<DeleteFarmMarket>(
          create: (context) =>
              DeleteFarmMarket(context.read<FarmMarketRepositoryImpl>()),
        ),
         Provider<GetSalesByFarmMarketId>(
          create: (context) => GetSalesByFarmMarketId(context.read<FarmMarketRepositoryImpl>()),
        ),
        Provider<GetFarmsByOwner>(
          create: (context) => GetFarmsByOwner(context.read<FarmMarketRepositoryImpl>()),
        ),
        Provider<GetFarmProducts>(
          create: (context) => GetFarmProducts(context.read<FarmMarketRepositoryImpl>()),
        ),
        ChangeNotifierProvider<FarmMarketViewModel>(
          create: (context) => FarmMarketViewModel(
            getAllFarmMarkets: context.read<GetAllFarmMarkets>(),
            getFarmMarketById: context.read<GetFarmMarketById>(),
            addFarmMarket: context.read<AddFarmMarket>(),
            updateFarmMarket: context.read<UpdateFarmMarket>(),
            deleteFarmMarket: context.read<DeleteFarmMarket>(),
            getSalesByFarmMarketId: context.read<GetSalesByFarmMarketId>(),
            getFarmsByOwner: context.read<GetFarmsByOwner>(),
            getFarmProducts: context.read<GetFarmProducts>(),


          ),
          lazy: false,
        ),


         ChangeNotifierProvider<DiseaseDetectionViewModel>(
          create: (_) => DiseaseDetectionViewModel(),
        ),


        // Farm crop providers
        Provider<FarmCropRemoteDataSource>(
          create: (_) => FarmCropRemoteDataSource(authService: SecureStorageService(),),
        ),
        Provider<FarmCropRepositoryImpl>(
          create: (context) => FarmCropRepositoryImpl(
            remoteDataSource: context.read<FarmCropRemoteDataSource>(),
          ),
        ),
        Provider<GetAllFarmCrops>(
          create: (context) =>
              GetAllFarmCrops(context.read<FarmCropRepositoryImpl>()),
        ),
        Provider<GetFarmCropById>(
          create: (context) =>
              GetFarmCropById(context.read<FarmCropRepositoryImpl>()),
        ),
        Provider<AddFarmCrop>(
          create: (context) =>
              AddFarmCrop(context.read<FarmCropRepositoryImpl>()),
        ),
        Provider<UpdateFarmCrop>(
          create: (context) =>
              UpdateFarmCrop(context.read<FarmCropRepositoryImpl>()),
        ),
        Provider<DeleteFarmCrop>(
          create: (context) =>
              DeleteFarmCrop(context.read<FarmCropRepositoryImpl>()),
        ),
        Provider<CalculateTotalExpenses>(
          create: (context) => CalculateTotalExpenses(),
        ),
        Provider<GetFarmCropsByFarmMarketId>(
          create: (context) => GetFarmCropsByFarmMarketId(context.read<FarmCropRepositoryImpl>()),
        ),
        Provider<ProcessAllConfirmedFarmCrops>(
          create: (context) => ProcessAllConfirmedFarmCrops(context.read<FarmCropRepositoryImpl>()),
        ),
        Provider<ConvertFarmCropToProduct>(
          create: (context) => ConvertFarmCropToProduct(context.read<FarmCropRepositoryImpl>()),
        ),
        Provider<ConfirmAndConvertFarmCrop>(
          create: (context) => ConfirmAndConvertFarmCrop(context.read<FarmCropRepositoryImpl>()),
        ),
        ChangeNotifierProvider<FarmCropViewModel>(
          create: (context) => FarmCropViewModel(
            getAllFarmCrops: context.read<GetAllFarmCrops>(),
            getFarmCropById: context.read<GetFarmCropById>(),
            addFarmCrop: context.read<AddFarmCrop>(),
            updateFarmCrop: context.read<UpdateFarmCrop>(),
            deleteFarmCrop: context.read<DeleteFarmCrop>(),
            getFarmCropsByFarmMarketId: context.read<GetFarmCropsByFarmMarketId>(),
            confirmAndConvertFarmCrop: context.read<ConfirmAndConvertFarmCrop>(),
            convertFarmCropToProduct: context.read<ConvertFarmCropToProduct>(),
            processAllConfirmedFarmCrops: context.read<ProcessAllConfirmedFarmCrops>(),

            // calculateTotalExpenses: context.read<CalculateTotalExpenses>(),
          ),
          lazy: false,
        ),


        // Sale providers
        Provider<SaleRemoteDataSource>(
          create: (_) => SaleRemoteDataSource(),
        ),
        Provider<SaleRepositoryImpl>(
          create: (context) => SaleRepositoryImpl(
            remoteDataSource: context.read<SaleRemoteDataSource>(),
          ),
        ),
        Provider<GetAllSales>(
          create: (context) => GetAllSales(context.read<SaleRepositoryImpl>()),
        ),
        Provider<GetSaleById>(
          create: (context) => GetSaleById(context.read<SaleRepositoryImpl>()),
        ),
        Provider<GetSalesByCropId>(
          create: (context) => GetSalesByCropId(context.read<SaleRepositoryImpl>()),
        ),
        Provider<AddSale>(
          create: (context) => AddSale(context.read<SaleRepositoryImpl>()),
        ),
        Provider<UpdateSale>(
          create: (context) => UpdateSale(context.read<SaleRepositoryImpl>()),
        ),
        Provider<DeleteSale>(
          create: (context) => DeleteSale(context.read<SaleRepositoryImpl>()),
        ),
        // Add new GetSalesByFarmMarket provider
        Provider<GetSalesByFarmMarket>(
          create: (context) => GetSalesByFarmMarket(context.read<SaleRepositoryImpl>()),
        ),
        

        ChangeNotifierProvider<SaleViewModel>(
          create: (context) => SaleViewModel(
            getAllSales: context.read<GetAllSales>(),
            getSaleById: context.read<GetSaleById>(),
            getSalesByCropId: context.read<GetSalesByCropId>(),
            addSale: context.read<AddSale>(),
            updateSale: context.read<UpdateSale>(),
            deleteSale: context.read<DeleteSale>(),
            getFarmCropById: context.read<GetFarmCropById>(),
            getSalesByFarmMarket: context.read<GetSalesByFarmMarket>(),
          ),
        ),

        //ahmedd

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
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(),
        ),
    ChangeNotifierProvider(
    create: (_) => DashboardViewModel(apiService),)
      ],
      child: Builder(builder: (context) {
      

          return MaterialApp(
            title: 'Hanouty',
          //  theme: lightTheme,
          //  themeMode: themeProvider.themeMode,
          //  darkTheme: darkTheme,
            debugShowCheckedModeBanner: false,
            initialRoute: initialRoute,
            routes: {
              '/login': (context) => const LoginPage(),
              '/register': (context) => const RegisterPage(),
              '/home': (context) => const MainScreen(),
              '/farmer': (context) => const FarmMobileNavigation(),
              '/merchant': (context) => const DashboardPage(),
              '/setup-2fa': (context) => const SetupTwoFactorAuthScreen(),
              '/cart': (context) => const CartScreen(),
             
            },
          );
        },
      ),
    );
  }
}
