import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../Sales/Domain_Layer/entities/sale.dart';
import '../../Domain_Layer/entity/farm.dart';
import '../../Domain_Layer/repositories/farm_repository.dart';
import '../datasources/farm_remote_data_source.dart';


class FarmMarketRepositoryImpl implements FarmMarketRepository {
  final FarmMarketRemoteDataSource remoteDataSource;

  FarmMarketRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Farm>>> getAllFarmMarkets() async {
    try {
      final farmMarkets = await remoteDataSource.getAllFarmMarkets();
      return Right(farmMarkets);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Farm>>> getFarmsByOwner(String owner) async {
    try {
      final farms = await remoteDataSource.getFarmsByOwner(owner);
      return Right(farms);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Farm>> getFarmMarketById(String id) async {
    try {
      final farmMarket = await remoteDataSource.getFarmMarketById(id);
      return Right(farmMarket);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }


// 3. Implement the method in the repository implementation (farm_repository_impl.dart):
  @override
  Future<Either<Failure, List<dynamic>>> getFarmProducts(String farmId) async {
    try {
      final products = await remoteDataSource.getFarmProducts(farmId);
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addFarmMarket(Farm farmMarket) async {
    try {
      await remoteDataSource.addFarmMarket(farmMarket);
      return const Right(null);
    } catch (e) {
      print("Repository Error: $e");
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateFarmMarket(Farm farmMarket) async {
    if (farmMarket.id == null) {
      throw Exception('Cannot update farm market: ID is missing');
    }
    try {
      await remoteDataSource.updateFarmMarket(farmMarket);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFarmMarket(String id) async {
    try {
      await remoteDataSource.deleteFarmMarket(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Sale>>> getSalesByFarmMarketId(String farmMarketId) async {
    try {
      final remoteSales = await remoteDataSource.getSalesByFarmMarketId(farmMarketId);
      return Right(remoteSales);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadFarmImage(String farmId, String imagePath) async {
    try {
      final imageUrl = await remoteDataSource.uploadFarmImage(farmId, imagePath);
      return Right(imageUrl);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getFarmImages(String farmId) async {
    try {
      final images = await remoteDataSource.getFarmImages(farmId);
      return Right(images);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

}