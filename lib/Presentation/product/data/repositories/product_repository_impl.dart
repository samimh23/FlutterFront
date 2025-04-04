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
    final ProductModel productModel = ProductModel(
      id: product.id,
      name: product.name,
      price: product.price,
      stock: product.stock,
      originalPrice: product.originalPrice,
      images: product.images,
      description: product.description,
      category: product.category,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      ratings: product.ratings,
      isDiscounted: product.isDiscounted,
      discountValue: product.discountValue,
    );
    return _getMessage(() => remoteDataSource.addProduct(productModel));
  }

  @override
  Future<Either<Failure, Unit>> deleteProduct(String id) {
    return _getMessage(() => remoteDataSource.deleteProduct(id));
  }

  @override
  Future<Either<Failure, List<Product>>> getAllProducts() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProduct = await remoteDataSource.getAllProducts();
        localDataSource.chacheProducts(remoteProduct);
        return right(remoteProduct);
      } on ServerException {
        return left(ServerFailure());
      }
    } else {
      try {
        final localProduct = await localDataSource.getCachedProducts();
        return right(localProduct);
      } on EmptyCacheException {
        return left(EmptyCachedFailure());
      }
    }
  }

  @override
  Future<Either<Failure, Unit>> updateProduct(Product product) {
    final ProductModel productModel = ProductModel(
      id: product.id,
      name: product.name,
      price: product.price,
      stock: product.stock,
      originalPrice: product.originalPrice,
      images: product.images,
      description: product.description,
      category: product.category,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      ratings: product.ratings,
      isDiscounted: product.isDiscounted,
      discountValue: product.discountValue,
    );
    return _getMessage(() => remoteDataSource.updateProduct(productModel));
  }

  Future<Either<Failure, Unit>> _getMessage(
    deleteOrUpdateOrAddProduct deleteOrUpdateOrAddProduct,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        await deleteOrUpdateOrAddProduct();
        return right(unit);
      } on ServerException {
        return left(ServerFailure());
      }
    } else {
      return left(OfflineFailure());
    }
  }

  @override
Future<Either<Failure, Product>> getProductById(String id) async {
  if (await networkInfo.isConnected) {
    try {
      final product = await remoteDataSource.getProductById(id);
      return right(product);
    } on ServerException {
      return left(ServerFailure());
    }
  } else {
    return left(OfflineFailure());
  }
}

}
