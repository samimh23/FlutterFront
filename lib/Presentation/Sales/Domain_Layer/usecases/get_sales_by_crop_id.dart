import 'package:dartz/dartz.dart';
import '../entities/sale.dart';
import '../repositories/sale_repository.dart';
import '../../../../core/errors/failure.dart';
class GetSalesByCropId {
  final SaleRepository repository;

  GetSalesByCropId(this.repository);

  Future<Either<Failure, List<Sale>>> call(String cropId) async {
    return await repository.getSalesByCropId(cropId);
  }
}