import 'package:dartz/dartz.dart';
import '../entities/sale.dart';
import '../repositories/sale_repository.dart';
import '../../../../core/errors/failure.dart';
class AddSale {
  final SaleRepository repository;

  AddSale(this.repository);

  Future<Either<Failure, Unit>> call(Sale sale) async {
    return await repository.addSale(sale);
  }
}