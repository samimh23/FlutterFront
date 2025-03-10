import 'package:dartz/dartz.dart';
import 'package:hanouty/Core/errors/failuresconection.dart';
import 'package:hanouty/Presentation/product/domain/entities/product.dart';

abstract class ProductRepository {
Future<Either<Failure, List<Product>>> getAllProducts();
Future<Either<Failure, Unit>> deleteProduct (int id);
Future<Either<Failure, Unit>> updateProduct (Product product);
Future<Either<Failure, Unit>> addProduct (Product product);
}  