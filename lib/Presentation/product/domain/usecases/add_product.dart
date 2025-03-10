import 'package:dartz/dartz.dart';
import 'package:hanouty/Core/errors/failuresconection.dart';
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/domain/repositories/product_repositry.dart';

class AddProductUseCase {
  final ProductRepository repository;

   AddProductUseCase(this.repository);
  
  Future<Either<Failure, Unit>> call(Product product) async {
    return await repository.addProduct(product);
  }
}