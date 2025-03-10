import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:get_it/get_it.dart';
import 'package:hanouty/Core/network/network_info.dart';
import 'package:hanouty/Presentation/order/data/datasources/order_remote_data_source.dart';
import 'package:hanouty/Presentation/order/data/repsitories/order_repository_impl.dart';
import 'package:hanouty/Presentation/order/domain/repositories/order_repositories.dart';
import 'package:hanouty/Presentation/order/domain/usecases/cancel_order.dart';
import 'package:hanouty/Presentation/order/domain/usecases/confirm_order.dart';
import 'package:hanouty/Presentation/order/domain/usecases/create_order.dart';
import 'package:hanouty/Presentation/order/domain/usecases/find_order_by_user_id.dart';
import 'package:hanouty/Presentation/order/domain/usecases/update_order.dart';
import 'package:hanouty/Presentation/order/presentation/provider/order_provider.dart';
import 'package:hanouty/Presentation/product/data/datasources/product_local_data_source.dart';
import 'package:hanouty/Presentation/product/data/datasources/product_remote_data_source.dart';
import 'package:hanouty/Presentation/product/data/repositories/product_repository_impl.dart';
import 'package:hanouty/Presentation/product/domain/repositories/product_repositry.dart';
import 'package:hanouty/Presentation/product/domain/usecases/get_all_product.dart';
import 'package:hanouty/Presentation/product/presentation/provider/cart_provider.dart';
import 'package:hanouty/Presentation/product/presentation/provider/product_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  // Register Order Use Cases
  sl.registerLazySingleton(() => CreateOrder(sl()));
  sl.registerLazySingleton(() => ConfirmOrder(sl()));
  sl.registerLazySingleton(() => CancelOrder(sl()));
  sl.registerLazySingleton(() => UpdateOrder(sl()));
  sl.registerLazySingleton(() => FindOrderByUserId(sl()));

  // Register OrderProvider
  sl.registerFactory<OrderProvider>(
    () => OrderProvider(
      createOrderUseCase: sl(),
      confirmOrderUseCase: sl(),
      cancelOrderUseCase: sl(),
      findOrderByUserIdUseCase: sl(),
    ),
  );
  // Register your CartProvider
  sl.registerFactory<CartProvider>(() => CartProvider());

  //product
  sl.registerFactory(() => ProductProvider(getAllProductUseCase: sl()));

  sl.registerLazySingleton(() => GetAllProductUseCase(sl()));

  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(client: sl()),
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
