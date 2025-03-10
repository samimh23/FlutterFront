import 'package:dartz/dartz.dart';
import 'package:hanouty/Core/errors/failuresconection.dart';
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/domain/repositories/product_repositry.dart';

class GetAllProductUseCase {
  final ProductRepository repository;

  GetAllProductUseCase(this.repository);

  Future<Either<Failure, List<Product>>> call() async {
    return await repository.getAllProducts();
  }
}