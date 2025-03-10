import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entity/farm.dart';
import '../repositories/farm_repository.dart';


class AddFarmMarket {
  final FarmMarketRepository repository;

  AddFarmMarket(this.repository);

  Future<Either<Failure, void>> call(Farm farm) {
    return repository.addFarmMarket(farm);
  }
}