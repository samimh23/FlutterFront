import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/farm_repository.dart';

class GetFarmImages {
  final FarmMarketRepository repository;

  GetFarmImages(this.repository);

  Future<Either<Failure, List<String>>> call(String farmId) async {
    return await repository.getFarmImages(farmId);
  }
}