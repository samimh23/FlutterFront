import 'package:dartz/dartz.dart';
import 'package:hanouty/Core/errors/exceptions.dart';
import 'package:hanouty/Core/errors/failuresconection.dart';
import 'package:hanouty/Core/network/network_info.dart';
import 'package:hanouty/Presentation/product/data/datasources/product_local_data_source.dart';
import 'package:hanouty/Presentation/product/data/datasources/product_remote_data_source.dart';
import 'package:hanouty/Presentation/product/data/models/product_model.dart';
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/domain/repositories/product_repositry.dart';

typedef Future<Unit> deleteOrUpdateOrAddProduct();

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource localDataSource;
  final ProductRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Unit>> addProduct(Product product) async {
    print("\n🏢 REPOSITORY: Starting addProduct operation");
    print("🏢 REPOSITORY: Converting Product entity to ProductModel");

    try {
      final ProductModel productModel = ProductModel(
        id: product.id,
        name: product.name,
        price: product.price,
        stock: product.stock,
        originalPrice: product.originalPrice,
        image: product.image, // Already using singular image
        description: product.description,
        category: product.category,
        createdAt: product.createdAt,
        updatedAt: product.updatedAt,
        ratingsAverage: product.ratingsAverage,
        ratingsQuantity: product.ratingsQuantity,
        isDiscounted: product.isDiscounted,
        discountValue: product.discountValue, // Keep as is - handled in model toJson
        shop: product.shop,
      );

      print("🏢 REPOSITORY: Successfully converted to ProductModel");
      print("🏢 REPOSITORY: Product details: name=${productModel.name}, price=${productModel.price}, shop=${productModel.shop}");

      final result = await _getMessage(() => remoteDataSource.addProduct(productModel));

      result.fold(
              (failure) => print("🏢 REPOSITORY: addProduct operation FAILED with ${failure.runtimeType}"),
              (_) => print("🏢 REPOSITORY: addProduct operation SUCCEEDED")
      );

      print("🏢 REPOSITORY: Completed addProduct operation\n");
      return result;
    } catch (e, stackTrace) {
      print("🏢 REPOSITORY: ERROR during addProduct: ${e.toString()}");
      print("🏢 REPOSITORY: Stack trace:");
      print(stackTrace);
      print("🏢 REPOSITORY: addProduct operation FAILED due to exception\n");
      return left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProduct(int id) {
    print("🏢 REPOSITORY: Starting deleteProduct operation for ID: $id");
    return _getMessage(() => remoteDataSource.deleteProduct(id));
  }

  @override
  Future<Either<Failure, List<Product>>> getAllProducts() async {
    print("🏢 REPOSITORY: Starting getAllProducts operation");

    try {
      final isConnected = await networkInfo.isConnected;
      print("🏢 REPOSITORY: Network connection status: ${isConnected ? 'ONLINE' : 'OFFLINE'}");

      if (isConnected) {
        print("🏢 REPOSITORY: Fetching products from remote data source");
        try {
          final remoteProduct = await remoteDataSource.getAllProducts();
          print("🏢 REPOSITORY: Successfully retrieved ${remoteProduct.length} products from remote");
          print("🏢 REPOSITORY: Caching products locally");
          await localDataSource.chacheProducts(remoteProduct);
          print("🏢 REPOSITORY: Products cached successfully");
          return right(remoteProduct);
        } on ServerException catch (e) {
          print("🏢 REPOSITORY: ServerException caught in getAllProducts: ${e.message}");
          return left(ServerFailure());
        } catch (e) {
          print("🏢 REPOSITORY: Unexpected error in getAllProducts: ${e.toString()}");
          return left(ServerFailure());
        }
      } else {
        print("🏢 REPOSITORY: Offline mode - fetching products from local cache");
        try {
          final localProduct = await localDataSource.getCachedProducts();
          print("🏢 REPOSITORY: Successfully retrieved ${localProduct.length} products from cache");
          return right(localProduct);
        } on EmptyCacheException {
          print("🏢 REPOSITORY: EmptyCacheException - No products found in cache");
          return left(EmptyCachedFailure());
        } catch (e) {
          print("🏢 REPOSITORY: Unexpected error getting cached products: ${e.toString()}");
          return left(EmptyCachedFailure());
        }
      }
    } catch (e) {
      print("🏢 REPOSITORY: Critical error in getAllProducts: ${e.toString()}");
      return left(ServerFailure());
    } finally {
      print("🏢 REPOSITORY: Completed getAllProducts operation");
    }
  }

  @override
  Future<Either<Failure, Unit>> updateProduct(Product product) {
    print("\n🏢 REPOSITORY: Starting updateProduct operation for product: ${product.id}");
    try {
      print("🏢 REPOSITORY: Converting Product entity to ProductModel");
      final ProductModel productModel = ProductModel(
        id: product.id,
        name: product.name,
        price: product.price,
        stock: product.stock,
        originalPrice: product.originalPrice,
        image: product.image, // Already using singular image
        description: product.description,
        category: product.category,
        createdAt: product.createdAt,
        updatedAt: product.updatedAt,
        ratingsAverage: product.ratingsAverage,
        ratingsQuantity: product.ratingsQuantity,
        isDiscounted: product.isDiscounted,
        discountValue: product.discountValue, // Keep as is - handled in model toJson
        shop: product.shop,
      );
      print("🏢 REPOSITORY: Successfully converted to ProductModel");
      return _getMessage(() => remoteDataSource.updateProduct(productModel));
    } catch (e) {
      print("🏢 REPOSITORY: Error in updateProduct: ${e.toString()}");
      return Future.value(left(ServerFailure()));
    }
  }

  Future<Either<Failure, Unit>> _getMessage(
      deleteOrUpdateOrAddProduct deleteOrUpdateOrAddProduct,
      ) async {
    print("🏢 REPOSITORY: _getMessage helper function called");
    try {
      final isConnected = await networkInfo.isConnected;
      print("🏢 REPOSITORY: Network connection status: ${isConnected ? 'ONLINE' : 'OFFLINE'}");

      if (isConnected) {
        print("🏢 REPOSITORY: Network available, proceeding with operation");
        try {
          print("🏢 REPOSITORY: Calling data source method");
          await deleteOrUpdateOrAddProduct();
          print("🏢 REPOSITORY: Data source operation completed successfully");
          return right(unit);
        } on ServerException catch (e) {
          print("🏢 REPOSITORY: ServerException caught: ${e.message}");
          return left(ServerFailure());
        } catch (e, stackTrace) {
          print("🏢 REPOSITORY: Unexpected error in data source operation: ${e.toString()}");
          print(stackTrace);
          return left(ServerFailure());
        }
      } else {
        print("🏢 REPOSITORY: Network unavailable, returning offline failure");
        return left(OfflineFailure());
      }
    } catch (e) {
      print("🏢 REPOSITORY: Critical error in _getMessage: ${e.toString()}");
      return left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Product>> getProductById(String id) async {
    print("🏢 REPOSITORY: Starting getProductById for ID: $id");
    try {
      final isConnected = await networkInfo.isConnected;
      print("🏢 REPOSITORY: Network connection status: ${isConnected ? 'ONLINE' : 'OFFLINE'}");

      if (isConnected) {
        try {
          print("🏢 REPOSITORY: Fetching product from remote data source");
          final product = await remoteDataSource.getProductById(id);
          print("🏢 REPOSITORY: Successfully retrieved product: ${product.name}");
          return right(product);
        } on ServerException catch (e) {
          print("🏢 REPOSITORY: ServerException fetching product: ${e.message}");
          return left(ServerFailure());
        } catch (e) {
          print("🏢 REPOSITORY: Error fetching product: ${e.toString()}");
          return left(ServerFailure());
        }
      } else {
        print("🏢 REPOSITORY: Network unavailable for getProductById");
        return left(OfflineFailure());
      }
    } catch (e) {
      print("🏢 REPOSITORY: Critical error in getProductById: ${e.toString()}");
      return left(ServerFailure());
    } finally {
      print("🏢 REPOSITORY: Completed getProductById operation");
    }
  }
}