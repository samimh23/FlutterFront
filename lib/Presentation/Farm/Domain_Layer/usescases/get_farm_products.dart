import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/farm_repository.dart';

class GetFarmProducts {
  final FarmMarketRepository repository;

  GetFarmProducts(this.repository);

  Future<Either<Failure, List<dynamic>>> call(String farmId) async {
    return await repository.getFarmProducts(farmId);
  }
}