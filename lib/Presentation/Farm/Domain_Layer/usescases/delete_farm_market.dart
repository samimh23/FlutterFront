import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/farm_repository.dart';

class DeleteFarmMarket {
  final FarmMarketRepository repository;

  DeleteFarmMarket(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteFarmMarket(id);
  }
}