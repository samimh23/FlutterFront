import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entity/farm.dart';
import '../repositories/farm_repository.dart';

class GetFarmsByOwner {
  final FarmMarketRepository repository;

  GetFarmsByOwner(this.repository);

  Future<Either<Failure, List<Farm>>> call(String owner) async {
    return await repository.getFarmsByOwner(owner);
  }
}