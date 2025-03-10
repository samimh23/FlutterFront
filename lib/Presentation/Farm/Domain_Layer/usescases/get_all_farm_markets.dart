import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entity/farm.dart';
import '../repositories/farm_repository.dart';

class GetAllFarmMarkets {
  final FarmMarketRepository repository;

  GetAllFarmMarkets(this.repository);

  Future<Either<Failure, List<Farm>>> call() {
    return repository.getAllFarmMarkets();
  }
}