import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:hanouty/Core/Utils/secure_storage.dart';
import 'package:hanouty/Core/network/network_info.dart';
import 'package:hanouty/Presentation/auction/data/datasource/auction_remote_datasource.dart';
import 'package:hanouty/Presentation/auction/data/repositories/auction_repository_impl.dart';
import 'package:hanouty/Presentation/auction/domain/repository/auction_repository.dart';
import 'package:hanouty/Presentation/auction/domain/usecases/create_auction_usecase.dart';
import 'package:hanouty/Presentation/auction/domain/usecases/get_active_auction_usecase.dart';
import 'package:hanouty/Presentation/auction/domain/usecases/get_auction_by_bidder_id_usecase.dart';
import 'package:hanouty/Presentation/auction/domain/usecases/get_auction_by_farmer_id_usecase.dart';
import 'package:hanouty/Presentation/auction/domain/usecases/get_auction_by_id_usecase.dart';
import 'package:hanouty/Presentation/auction/domain/usecases/get_bidders_by_auction_id_usecase.dart';
import 'package:hanouty/Presentation/auction/domain/usecases/place_bid_usecase.dart';
import 'package:hanouty/Presentation/auction/domain/usecases/update_auction_status_usecase.dart';
import 'package:hanouty/Presentation/auction/presentation/provider/auction_provider.dart';
import 'package:hanouty/Presentation/order/data/datasources/order_remote_data_source.dart';
import 'package:hanouty/Presentation/order/data/repsitories/order_repository_impl.dart';
import 'package:hanouty/Presentation/order/domain/repositories/order_repositories.dart';
import 'package:hanouty/Presentation/order/domain/usecases/cancel_order.dart';
import 'package:hanouty/Presentation/order/domain/usecases/confirm_order.dart';
import 'package:hanouty/Presentation/order/domain/usecases/create_order.dart';
import 'package:hanouty/Presentation/order/domain/usecases/find_order_by_id.dart';
import 'package:hanouty/Presentation/order/domain/usecases/find_order_by_user_id.dart';
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

import 'Presentation/auction/data/datasource/auction_remote_datasource.dart';
import 'Presentation/auction/data/repositories/auction_repository_impl.dart';
import 'Presentation/auction/domain/repository/auction_repository.dart';
import 'Presentation/auction/domain/usecases/create_auction_usecase.dart';
import 'Presentation/auction/domain/usecases/get_active_auction_usecase.dart';
import 'Presentation/auction/domain/usecases/get_auction_by_bidder_id_usecase.dart';
import 'Presentation/auction/domain/usecases/get_auction_by_farmer_id_usecase.dart';
import 'Presentation/auction/domain/usecases/get_auction_by_id_usecase.dart';
import 'Presentation/auction/domain/usecases/get_bidders_by_auction_id_usecase.dart';
import 'Presentation/auction/domain/usecases/place_bid_usecase.dart';
import 'Presentation/auction/domain/usecases/update_auction_status_usecase.dart';
import 'Presentation/auction/presentation/provider/auction_provider.dart';
import 'Presentation/order/domain/usecases/FindOrderByShopId.dart';
import 'Presentation/order/domain/usecases/send_package.dart';

final sl = GetIt.instance;
Future<void> init() async {
  //auction
  sl.registerLazySingleton<AuctionRemoteDataSource>(
        () => AuctionRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuctionRepository>(
        () => AuctionRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );
  sl.registerLazySingleton(() => CreateAuction(sl()));
  sl.registerLazySingleton(() => GetActiveAuctions(sl()));
  sl.registerLazySingleton(() => GetAuctionById(sl()));
  sl.registerLazySingleton(() => PlaceBid(sl()));
  sl.registerLazySingleton(() => UpdateAuctionStatus(sl()));
  sl.registerLazySingleton(() => GetAuctionsByBidderId(sl()));
  sl.registerLazySingleton(() => GetAuctionsByFarmerId(sl()));
  sl.registerLazySingleton(() => GetBiddersByAuctionId(sl()));

  sl.registerFactory<AuctionProvider>(
        () => AuctionProvider(
      createAuctionUseCase: sl(),
      getActiveAuctionsUseCase: sl(),
      getAuctionByIdUseCase: sl(),
      placeBidUseCase: sl(),
      updateAuctionStatusUseCase: sl(),
      getAuctionsByBidderIdUseCase: sl(),
      getBiddersByAuctionIdUseCase: sl(),
      getAuctionsByFarmerIdUseCase: sl(),
    ),
  );



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
  sl.registerLazySingleton<AuctionRemoteDataSource>(
        () => AuctionRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuctionRepository>(
        () => AuctionRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );
  sl.registerLazySingleton(() => CreateAuction(sl()));
  sl.registerLazySingleton(() => GetActiveAuctions(sl()));
  sl.registerLazySingleton(() => GetAuctionById(sl()));
  sl.registerLazySingleton(() => PlaceBid(sl()));
  sl.registerLazySingleton(() => UpdateAuctionStatus(sl()));
  sl.registerLazySingleton(() => GetAuctionsByBidderId(sl()));
  sl.registerLazySingleton(() => GetAuctionsByFarmerId(sl()));
  sl.registerLazySingleton(() => GetBiddersByAuctionId(sl()));

  sl.registerFactory<AuctionProvider>(
        () => AuctionProvider(
      createAuctionUseCase: sl(),
      getActiveAuctionsUseCase: sl(),
      getAuctionByIdUseCase: sl(),
      placeBidUseCase: sl(),
      updateAuctionStatusUseCase: sl(),
      getAuctionsByBidderIdUseCase: sl(),
      getBiddersByAuctionIdUseCase: sl(),
      getAuctionsByFarmerIdUseCase: sl(),
    ),
  );

  sl.registerFactory<ReviewProvider>(
    () => ReviewProvider(
      createReviewUsecase: sl(),
      updateReviewUsecase: sl(),
      getReviewsByUserId: sl(),
    ),);
  // Register Order Use Cases
  sl.registerLazySingleton(() => CreateOrder(sl()));
  sl.registerLazySingleton(() => ConfirmOrder(sl()));
  sl.registerLazySingleton(() => CancelOrder(sl()));
  sl.registerLazySingleton(() => UpdateOrder(sl()));
  sl.registerLazySingleton(() => FindOrderByUserId(sl()));
sl.registerLazySingleton(() => FindOrderById(sl()));
  sl.registerLazySingleton(() => FindOrderByShopId(sl())); // Add this line
  sl.registerLazySingleton(() => SendPackage(sl()));
  // Register OrderProvider
  sl.registerFactory<OrderProvider>(
    () => OrderProvider(
      createOrderUseCase: sl(),
      confirmOrderUseCase: sl(),
      cancelOrderUseCase: sl(),
      findOrderByUserIdUseCase: sl(),
      findOrderByIdUseCase: sl(),

        findOrderByShopIdUseCase: sl(), sendPackageUseCase: sl()
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
  )); sl.registerLazySingleton(() => AddProductUseCase(sl()));
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
    () => ProductRemoteDataSourceImpl(client: sl(),      authService: sl<SecureStorageService>(), // Use the registered SecureStorageService
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
