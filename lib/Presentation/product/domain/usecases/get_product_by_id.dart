import 'package:dartz/dartz.dart';
import 'package:hanouty/Core/errors/failuresconection.dart';
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/domain/repositories/product_repositry.dart';

class GetProductById {
  final ProductRepository repository;

  GetProductById(this.repository);

  Future<Either<Failure, Product>> call(String id) async {
    return await repository.getProductById(id);
  }
}