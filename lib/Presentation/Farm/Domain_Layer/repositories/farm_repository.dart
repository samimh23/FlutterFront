import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entity/farm.dart';

abstract class FarmMarketRepository {
  Future<Either<Failure, List<Farm>>> getAllFarmMarkets();
  Future<Either<Failure, Farm>> getFarmMarketById(String id);
  Future<Either<Failure, void>> addFarmMarket(Farm farm);
  Future<Either<Failure, void>> updateFarmMarket(Farm farm);
  Future<Either<Failure, void>> deleteFarmMarket(String id);
}