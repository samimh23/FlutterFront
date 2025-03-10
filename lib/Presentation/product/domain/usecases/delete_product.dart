import 'package:dartz/dartz.dart';
import 'package:hanouty/Core/errors/failuresconection.dart';
import 'package:hanouty/Presentation/product/domain/repositories/product_repositry.dart';

class DeleteProductUseCase {
  final ProductRepository repository;

  DeleteProductUseCase(this.repository);
  
  Future<Either<Failure, Unit>> call(int id) async {
    return await repository.deleteProduct(id);
  }
}