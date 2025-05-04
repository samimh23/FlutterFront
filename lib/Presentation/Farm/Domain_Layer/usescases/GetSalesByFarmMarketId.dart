import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../Sales/Domain_Layer/entities/sale.dart';
import '../repositories/farm_repository.dart';

class GetSalesByFarmMarketId {
  final FarmMarketRepository repository;

  GetSalesByFarmMarketId(this.repository);

  Future<Either<Failure, List<Sale>>> call(String farmMarketId) async {
    return await repository.getSalesByFarmMarketId(farmMarketId);
  }
}