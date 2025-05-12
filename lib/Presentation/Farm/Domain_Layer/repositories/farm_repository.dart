import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../Sales/Domain_Layer/entities/sale.dart';
import '../entity/farm.dart';

abstract class FarmMarketRepository {
  Future<Either<Failure, List<Farm>>> getAllFarmMarkets();
  Future<Either<Failure, Farm>> getFarmMarketById(String id);
  Future<Either<Failure, void>> addFarmMarket(Farm farm);
  Future<Either<Failure, void>> updateFarmMarket(Farm farm);
  Future<Either<Failure, void>> deleteFarmMarket(String id);
  Future<Either<Failure, List<Sale>>> getSalesByFarmMarketId(String farmMarketId);
  Future<Either<Failure, List<Farm>>> getFarmsByOwner(String owner);
  Future<Either<Failure, List<dynamic>>> getFarmProducts(String farmId);
  Future<Either<Failure, String>> uploadFarmImage(String farmId, String imagePath);
  Future<Either<Failure, List<String>>> getFarmImages(String farmId);
}