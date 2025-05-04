import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/sale.dart';
import '../repositories/Sale_Repository.dart';

class GetSalesByFarmMarket {
  final SaleRepository repository;

  GetSalesByFarmMarket(this.repository);

  Future<Either<Failure, List<Sale>>> call(String farmMarketId) async {
    return await repository.getSalesByFarmMarket(farmMarketId);
  }
}