import 'package:dartz/dartz.dart';
import '../repositories/sale_repository.dart';
import '../../../../core/errors/failure.dart';
class DeleteSale {
  final SaleRepository repository;

  DeleteSale(this.repository);

  Future<Either<Failure, Unit>> call(String id) async {
    return await repository.deleteSale(id);
  }
}