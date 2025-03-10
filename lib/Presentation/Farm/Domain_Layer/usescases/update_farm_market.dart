import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entity/farm.dart';
import '../repositories/farm_repository.dart';

class UpdateFarmMarket {
  final FarmMarketRepository repository;

  UpdateFarmMarket(this.repository);

  Future<Either<Failure, void>> call(Farm farmMarket) {
    return repository.updateFarmMarket(farmMarket);
  }
}