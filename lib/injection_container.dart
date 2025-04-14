import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:get_it/get_it.dart';
import 'package:hanouty/Core/Utils/secure_storage.dart';
import 'package:hanouty/Core/network/network_info.dart';
import 'package:hanouty/Presentation/order/data/datasources/order_remote_data_source.dart';
import 'package:hanouty/Presentation/order/data/repsitories/order_repository_impl.dart';
import 'package:hanouty/Presentation/order/domain/repositories/order_repositories.dart';
import 'package:hanouty/Presentation/order/domain/usecases/cancel_order.dart';
import 'package:hanouty/Presentation/order/domain/usecases/confirm_order.dart';
import 'package:hanouty/Presentation/order/domain/usecases/create_order.dart';
import 'package:hanouty/Presentation/order/domain/usecases/find_order_by_user_id.dart';
import 'package:hanouty/Presentation/order/domain/usecases/send_package.dart';
import 'package:hanouty/Presentation/order/domain/usecases/update_order.dart';
import 'package:hanouty/Presentation/order/presentation/provider/order_provider.dart';
import 'package:hanouty/Presentation/product/data/datasources/product_local_data_source.dart';
import 'package:hanouty/Presentation/product/data/datasources/product_remote_data_source.dart';
import 'package:hanouty/Presentation/product/data/repositories/product_repository_impl.dart';
import 'package:hanouty/Presentation/product/domain/repositories/product_repositry.dart';
import 'package:hanouty/Presentation/product/domain/usecases/add_product.dart';
import 'package:hanouty/Presentation/product/domain/usecases/get_all_product.dart';
import 'package:hanouty/Presentation/product/domain/usecases/get_product_by_id.dart';
import 'package:hanouty/Presentation/product/domain/usecases/update_product.dart';
import 'package:hanouty/Presentation/product/presentation/provider/cart_provider.dart';
import 'package:hanouty/Presentation/product/presentation/provider/product_provider.dart';
import 'package:hanouty/Presentation/review/data/datasources/review_remote_data_source.dart';
import 'package:hanouty/Presentation/review/data/repositories/review_repository_impl.dart';
import 'package:hanouty/Presentation/review/domain/repositories/review_repository.dart';
import 'package:hanouty/Presentation/review/domain/usecases/create_review_usecase.dart';
import 'package:hanouty/Presentation/review/domain/usecases/get_reviews_by_user_id_usecase.dart';
import 'package:hanouty/Presentation/review/domain/usecases/update_review_usecase.dart';
import 'package:hanouty/Presentation/review/presentation/provider/review_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'Presentation/order/domain/usecases/FindOrderByShopId.dart';

final sl = GetIt.instance;
Future<void> init() async {
  //order
  // Register Order Remote Data Source
  sl.registerLazySingleton<OrderRemoteDataSource>(
        () => OrderRemoteDataSourceImpl(client: sl()),
  );

  // Register Order Repository
  sl.registerLazySingleton<OrderRepository>(
        () => OrderRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<ReviewRemoteDataSource>(
        () => ReviewRemoteDataSourceImpl(client: sl()),
  );

  // Register Order Repository
  sl.registerLazySingleton<ReviewRepository>(
        () => ReviewRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton(() => CreateReviewUsecase(sl()));
  sl.registerLazySingleton(() => UpdateReviewUsecase(sl()));
  sl.registerLazySingleton(() => GetReviewsByUserId(sl()));
  sl.registerFactory<ReviewProvider>(
        () => ReviewProvider(
      createReviewUsecase: sl(),
      updateReviewUsecase: sl(),
      getReviewsByUserId: sl(),
    ),
  );

  // Register Order Use Cases
  sl.registerLazySingleton(() => CreateOrder(sl()));
  sl.registerLazySingleton(() => ConfirmOrder(sl()));
  sl.registerLazySingleton(() => CancelOrder(sl()));
  sl.registerLazySingleton(() => UpdateOrder(sl()));
  sl.registerLazySingleton(() => FindOrderByUserId(sl()));
  sl.registerLazySingleton(() => FindOrderByShopId(sl())); // Add this line
  sl.registerLazySingleton(() => SendPackage(sl()));

  // Register OrderProvider
  sl.registerFactory<OrderProvider>(
        () => OrderProvider(
      createOrderUseCase: sl(),
      confirmOrderUseCase: sl(),
      cancelOrderUseCase: sl(),
      findOrderByUserIdUseCase: sl(),
      findOrderByShopIdUseCase: sl(), sendPackageUseCase: sl(), // Add this parameter
    ),
  );

  // Register your CartProvider
  sl.registerFactory<CartProvider>(() => CartProvider());
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());

  //product
  sl.registerFactory(() => ProductProvider(
      sl<SecureStorageService>(), // Pass the SecureStorageService
      getAllProductUseCase: sl(),
      getProductById: sl(),
      addProductUseCase: sl(),
      updateProductUseCase: sl()
  ));
  sl.registerLazySingleton(() => AddProductUseCase(sl()));
  sl.registerLazySingleton(() => GetAllProductUseCase(sl()));
  sl.registerLazySingleton(() => GetProductById(sl()));
  sl.registerLazySingleton(() => UpdateProductUseCase(sl()));

  sl.registerLazySingleton<ProductRepository>(
        () => ProductRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<ProductRemoteDataSource>(
        () => ProductRemoteDataSourceImpl(
      client: sl(),
      authService: sl<SecureStorageService>(), // Use the registered SecureStorageService
    ),
  );

  sl.registerLazySingleton<ProductLocalDataSource>(
        () => ProductLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  final sharedPreferences = await SharedPreferences.getInstance();

  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton(() => http.Client());

  sl.registerLazySingleton(() => Connectivity());
}