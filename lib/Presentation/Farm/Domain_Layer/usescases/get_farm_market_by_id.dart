import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entity/farm.dart';
import '../repositories/farm_repository.dart';

class GetFarmMarketById {
  final FarmMarketRepository repository;

  GetFarmMarketById(this.repository);

  Future<Either<Failure, Farm>> call(String id) {
    return repository.getFarmMarketById(id);
  }
}